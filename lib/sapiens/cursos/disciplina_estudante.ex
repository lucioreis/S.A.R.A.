defmodule Sapiens.Cursos.DisciplinaEstudante do
  use Ecto.Schema

  schema "disciplinas__estudantes" do
    field :estudante_id, :integer
    field :disciplina_id, :integer

    timestamps()
  end
end
