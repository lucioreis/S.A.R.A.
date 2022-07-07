defmodule Sapiens.Acerto do
  import Ecto.Query, only: [from: 2], warn: false
  use GenServer

  alias Sapiens.Cursos.{
          Estudante,
          Professor,
          Curso,
          Disciplina,
          Enem,
          Historico,
          Turma
        },
        warn: false

  alias Sapiens.{
          Estudantes,
          Turmas,
          Disciplinas,
          Alteracoes
        },
        warn: false

  alias Sapiens.Repo, warn: false


  def adiciona(estudante, turma) do
    case Repo.get_by(Sapiens.Cursos.EstudanteTurma,
           disciplina_id: turma.disciplina_id,
           estudante_id: estudante.id
         ) do
      nil ->
        from(
          t in Turma,
          update: [inc: [vagas_disponiveis: -1, vagas_preenchidas: +1]],
          where: t.id == ^turma.id
        )
        |> Repo.update_all([])

        %Sapiens.Cursos.EstudanteTurma{
          turma_id: turma.id,
          estudante_id: estudante.id,
          disciplina_id: turma.disciplina_id
        }
        |> Repo.insert()

      value ->
        {:ok, value}
    end
  end

  def remove(estudante, turma) do
    case Repo.get_by(Sapiens.Cursos.EstudanteTurma,
           disciplina_id: turma.disciplina_id,
           estudante_id: estudante.id
         ) do
      nil ->
        {:error, "Alguma coisa seria aconteceu"}

      estudante_turma ->
        from(
          t in Sapiens.Cursos.Turma,
          update: [inc: [vagas_disponiveis: +1, vagas_preenchidas: -1]],
          where: t.id == ^turma.id
        )
        |> Repo.update_all([])

        Repo.delete(estudante_turma)
    end
  end

  def troca(estudante, nova_turma) do
    case Repo.get_by(Sapiens.Cursos.EstudanteTurma,
           estudante_id: estudante.id,
           disciplina_id: nova_turma.disciplina_id
         ) do
      nil ->
        {:error, "Estudante não está na turma"}

      estudante_turma ->
        case Repo.get_by(Sapiens.Cursos.Turma, id: estudante_turma.turma_id) do
          nil ->
            {:error, "Há uma inconsistencia no banco de dados"}

          old_turma ->
            case Repo.get_by(Sapiens.Cursos.Turma,
                   numero: nova_turma.numero,
                   disciplina_id: nova_turma.disciplina_id
                 ) do
              nil ->
                {:erro, "Nova Turma não existe"}

              nova_turma ->
                remove(estudante, old_turma)
                adiciona(estudante, nova_turma)
                {:ok, nova_turma}
            end
        end
    end
  end

  def validar_horario(estudante, turma) do
    {:ok, horario} = Estudantes.get_horarios(estudante)

    collisions =
      Enum.reduce(horario, %{}, fn {{dia, hora}, body}, acc ->
        case Map.get(turma.horario, <<dia, hora>>) do
          nil ->
            acc

          value ->
            if body["codigo"] != value["codigo"] do
              Map.put(acc, {dia, hora}, body)
            else
              acc
            end
        end
      end)

    if Map.equal?(collisions, %{}), do: {:ok, horario}, else: {:error, collisions}
  end
end
