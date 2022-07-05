defmodule Sapiens.Cursos.Disciplina do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
    %Sapiens.Cursos.Disciplina{
      __meta__: #Ecto.Schema.Metadata<:loaded, "disciplinas">,
      carga: integer,
      co_requisitos: [string],
      codigo: "string",
      curso: #Ecto.Association.NotLoaded<association :curso is not loaded>,
      curso_id: integer,
      estudantes: #Ecto.Association.NotLoaded<association :estudantes is not loaded>,
      historicos: #Ecto.Association.NotLoaded<association :historicos is not loaded>,
      id: integer,
      inserted_at: DateTime,
      nome: "strign",
      pre_requisitos: [],
      turmas: #Ecto.Association.NotLoaded<association :turmas is not loaded>,
      updated_at: DateTime
    }
   
  """
  schema "disciplinas" do
    field :carga, :integer
    field :codigo, :string
    field :nome, :string
    field :pre_requisitos, {:array, :string}
    field :co_requisitos, {:array, :string}

    timestamps()

    many_to_many :estudantes, Sapiens.Cursos.Estudante, join_through: Sapiens.Cursos.Historico

    has_many :turmas, Sapiens.Cursos.Turma

    belongs_to :curso, Sapiens.Cursos.Curso
  end

  @doc false
  def changeset(disciplina, attrs) do
    disciplina
    |> cast(attrs, [:codigo, :nome, :carga, :pre_requisitos, :co_requisitos])
    |> validate_required([:codigo, :nome, :carga])
  end
end
