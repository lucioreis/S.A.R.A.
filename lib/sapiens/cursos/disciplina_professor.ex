defmodule Sapiens.Cursos.DisciplinaProfessor do
  use Ecto.Schema

  schema "disciplinas__professores" do
    field :disciplina_id, :integer
    field :professor_id, :integer
  end
end
