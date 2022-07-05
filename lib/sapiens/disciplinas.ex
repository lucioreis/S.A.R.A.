defmodule Sapiens.Disciplinas do
  import Ecto.Query, only: [from: 2], warn: false
  import Sapiens.Utils

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

  @spec by_id(integer, [{atom, atom}]) :: {:ok, Sapiens.Cursos.Disciplina.t()} | {:error, any()}
  def by_id(id, preload_fields) do
    case by_id(id) do
      {:error, msg} ->
        {:error, msg}

      {:ok, disciplina} ->
        {:ok,
         Enum.reduce(preload_fields, disciplina, fn {:preload, field}, acc ->
           case Repo.preload(disciplina, field) do
             nil -> acc
             value -> value
           end
         end)}
    end
  end

  def by_id(id) do
    case Repo.get_by(Disciplina, id: id) do
      nil -> {:error, "Disciplina não encontrada: id=#{id}"}
      disciplina -> {:ok, disciplina}
    end
  end

  def get_turmas(disciplina) do
    {:ok, Repo.preload(disciplina, :turmas).turmas}
  end

  def get_turma_by_numero(disciplina, numero) do
    case Repo.get_by(Turma, disciplina_id: disciplina.id, numero: numero) do
      nil -> {:error, "Turma numero: #{numero} não existe."}
      turma -> {:ok, turma}
    end
  end

  def preload(disciplina, field) do
    Repo.preload(disciplina, field)
  end
end
