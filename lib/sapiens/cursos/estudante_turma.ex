
defmodule Sapiens.Cursos.EstudanteTurma do
  use Ecto.Schema

  schema "estudantes__turmas" do
    belongs_to :estudante, Sapiens.Cursos.Estudante
    belongs_to :turma, Sapiens.Cursos.Turma

  end

end
