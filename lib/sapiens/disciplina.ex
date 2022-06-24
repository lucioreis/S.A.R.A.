defmodule Sapiens.Disciplina do
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


  @doc ~S"""
  
  """
  def get_turmas(disciplina_id) when disciplina_id |> is_integer do
    case Repo.get_by(Disciplina, id: disciplina_id) do
      nil -> {:error, "Disciplina não ecnotrada!"}
      disciplina -> {:ok, get_turmas(disciplina)}
    end
  end

  def get_turmas(disciplina) do
    Repo.preload(disciplina, :turmas).turmas
  end

end
