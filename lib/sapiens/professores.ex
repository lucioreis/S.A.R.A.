defmodule Sapiens.Professores do
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

  def by_id(id, list \\ []) do
    case Repo.get_by(Professor, id: id) do
      nil ->
        {:error, "Professor não encontrado: id=#{id}"}

      professor ->
        {:ok, Repo.preload(professor, list)}
    end
  end

  def get_turmas(professor) do
    Repo.preload(professor, :turmas).turmas
  end

  def get_horarios(professor) do
    Repo.preload(professor, :turmas)
    |> Map.get(:turmas)
    |> Sapiens.Professores.build_horario()
  end

  def get_disciplinas(professor) do
    Repo.preload(professor, :disciplinas)
    |> Map.get(:disciplinas)
  end

  def build_horario(turmas) do
    Enum.reduce(
      turmas,
      %{},
      fn turma, horarios ->
        Enum.reduce(
          Sapiens.Turmas.get_horarios(turma),
          horarios,
          fn {key, _value}, acc -> Map.put(acc, key, Repo.preload(turma, :disciplina)) end
        )
      end
    )
  end

  def adiciona_turma(professor, turma) do
    turma = Repo.preload(turma, :disciplina)
    professor = Repo.preload(professor, [:disciplinas, :turmas])

    professor
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(
      :disciplinas,
      Enum.dedup(professor.disciplinas ++ [turma.disciplina])
    )
    |> Ecto.Changeset.put_assoc(:turmas, Enum.dedup(professor.turmas ++ [turma]))
    |> Repo.update()
  end

  def remove_turma(_professor, turma) do
    turma
    |> Ecto.Changeset.change(%{
      professor_id: nil
    })
    |> Repo.update()
  end
end
