defmodule Sapiens.Cursos.Professor do
  use Ecto.Schema
  import Ecto.Changeset
  @moduledoc"""
    %Professor{
      matricula: string,
      codigo: :integer,
      semestre: :integer,
      tipo_turma: :string,
      ano_ingresso: :integer,
      data_nascimento: :date,
      disciplinas: Sapiens.Cursos.Disciplina,
      turmas: Sapiens.Cursos.Turma,
      curso: Sapiens.Cursos.Curso
    }
  """

  schema "professores" do
    field :matricula, :string
    field :codigo, :integer
    field :semestre, :integer
    field :tipo_turma, :string
    field :ano_ingresso, :integer
    field :nome, :string
    field :data_nascimento, :date

    timestamps()

    many_to_many :disciplinas, Sapiens.Cursos.Disciplina, join_through: Sapiens.Cursos.DisciplinaProfessor

    has_many :turmas, Sapiens.Cursos.Turma
    belongs_to :curso, Sapiens.Cursos.Curso

  end

  @doc false
  def changeset(professor, attrs) do
    professor
    |> cast(attrs, [:matricula, :codigo, :semestre, :ano_ingresso,  :tipo_turma, :data_nascimento, :nome])
    |> validate_required([:matricula, :codigo, :semestre, :ano_ingresso, :nome, :data_nascimento])
  end
end
