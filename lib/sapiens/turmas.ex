defmodule Sapiens.Turmas do
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

  def get_by(list_of_keys) do
    case Repo.get_by(Turma, list_of_keys) do
      nil -> {:error, "Turma não encontrada"}
      turma -> {:ok, turma}
    end
  end

  def get_horarios(turma) do
    turma.horario
    |> Enum.reduce(%{}, fn {<<dia, hora>>, value}, acc -> Map.put_new(acc, {dia, hora}, value) end)
  end

  def get_all_estudantes(turma) do
    turma = Repo.preload(turma, :estudantes)
    {:ok, turma.estudantes}
  end

  def preload_all(turmas, field) do
    Enum.map(turmas, &Repo.preload(&1, field))
  end

  def preload(turma, field) do
    Repo.preload(turma, field)
  end
end
