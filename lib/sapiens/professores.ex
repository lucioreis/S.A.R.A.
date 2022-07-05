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

  def by_id(id) do
    case Repo.get_by(Professor, id: id) do
      nil -> {:error, "Professor não encontrado: id=#{id}"}
      professor -> {:ok, professor}
    end
  end
end
