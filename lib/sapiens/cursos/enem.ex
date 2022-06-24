defmodule Sapiens.Cursos.Enem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "enems" do
    field :modalidade, :string
    field :nota, :decimal

    timestamps()

    belongs_to :estudante, Sapiens.Cursos.Estudante
  end

  @doc false
  def changeset(enem, attrs) do
    enem
    |> cast(attrs, [:nota, :modalidade])
    |> validate_required([:nota, :modalidade])
  end
end
