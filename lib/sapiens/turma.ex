defmodule Sapiens.Turma do
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

  alias Sapiens.Repo, warn: false

  def by_id(id) do
    case Repo.get_by(Turma, id: id) do
      nil -> {:error, "Turma não encontrada: id=#{id}"}
      turma -> {:ok, turma}
    end
  end

  def get_horarios(turma) do
    turma.horario
    |> Enum.reduce(%{}, fn {<<dia, hora>>, value}, acc -> Map.put_new(acc, {dia, hora}, value) end)
  end

  def adiciona_estudante(turma, estudante) do
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

  def remove_estudante(turma, estudante) do
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

  def troca_turma(disciplina, estudante, nova_turma_numero) do
    case Repo.get_by(Sapiens.Cursos.EstudanteTurma,
           estudante_id: estudante.id,
           disciplina_id: disciplina.id
         ) do
      nil ->
        {:error, "Estudante não está na turma"}

      estudante_turma ->
        case Repo.get_by(Sapiens.Cursos.Turma, id: estudante_turma.turma_id) do
          nil ->
            {:error, "Há uma inconsistencia no banco de dados"}

          old_turma ->
            case Repo.get_by(Sapiens.Cursos.Turma, numero: nova_turma_numero, disciplina_id: disciplina.id) do
              nil ->
                {:erro, "Nova Turma não existe"}

              nova_turma ->
                remove_estudante(old_turma, estudante)
                adiciona_estudante(nova_turma, estudante)
                {:ok, nova_turma}
            end
        end
    end
  end
end
