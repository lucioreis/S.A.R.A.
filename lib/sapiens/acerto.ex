defmodule Sapiens.Acerto do
  import Ecto.Query, only: [from: 2], warn: false

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

  def reserva_vaga(turma) do
    vaga(turma, 1)
  end

  def libera_vaga(turma) do
    vaga(turma, -1)
  end

  defp vaga(turma, n) do
    from(
      t in Turma,
      update: [inc: [vagas_disponiveis: ^(-n), vagas_preenchidas: ^(+n)]],
      where: t.id == ^turma.id
    )
    |> Repo.update_all([])
  end

  def adiciona(estudante, turma) do
    case Repo.get_by(Sapiens.Cursos.EstudanteTurma,
           disciplina_id: turma.disciplina_id,
           estudante_id: estudante.id
         ) do
      nil ->
        reserva_vaga(turma)

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
        reserva_vaga(turma)
        Sapiens.Queue.change_vagas({turma.disciplina_id, turma.id}, +1)

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
