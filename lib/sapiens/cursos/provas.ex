defmodule Sapiens.Cursos.Provas do
  import Ecto.Changeset
  use Ecto.Schema

  embedded_schema do
    field(:p1, :integer, default: 0)
    field(:p2, :integer, default: 0)
    field(:p3, :integer, default: 0)
  end

  @doc false
  def changeset(provas, attrs) do
    provas
    |> cast(attrs, [:p1, :p2, :p2])
  end
end
