defmodule Sapiens.Historico do
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
    case Repo.get_by(Hitorico, id: id) do
      nil -> {:error, "Disciplina não encontrada: id=#{id}"}
      historico -> {:ok, historico}
    end
  end
end
