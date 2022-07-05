defmodule Sapiens.Cursos.Curso do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
    %Sapiens.Cursos.Curso{
      __meta__: #Ecto.Schema.Metadata<:loaded, "cursos">,
      id: integer,
      codigo: integer,
      sigla: string,
      nome: "Ciência da Computação",
      disciplinas: #Ecto.Association.NotLoaded<association :disciplinas is not loaded>,
      estudantes: #Ecto.Association.NotLoaded<association :estudantes is not loaded>,
      inserted_at: ~N[2022-06-22 22:44:37],
      professores: #Ecto.Association.NotLoaded<association :professores is not loaded>,
      updated_at: ~N[2022-06-22 22:44:37]
    }
  """
  schema "cursos" do
    field :codigo, :integer
    field :nome, :string
    field :sigla, :string

    timestamps()

    has_many :estudantes, Sapiens.Cursos.Estudante
    has_many :professores, Sapiens.Cursos.Professor
    has_many :disciplinas, Sapiens.Cursos.Disciplina
  end

  @doc false
  def changeset(curso, attrs) do
    curso
    |> cast(attrs, [:codigo, :nome, :sigla])
    |> validate_required([:codigo, :nome, :sigla])
  end
end
