defmodule Sapiens.Cursos.Status do
  import Ecto.Changeset
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field(:nome, :string)
    field(:matricula, :string)
    field(:provas, :map, default: %{})
    field(:ft, :integer, default: 0)
    field(:fp, :integer, default: 0)
    field(:nf, :integer, default: 0)
    field(:total, :integer, default: 0)
    field(:ef, :integer, default: 0)
    field(:conceito, :string)
    field(:updated_at, :naive_datetime)
  end

  @doc false
  def changeset(provas, attrs) do
    provas
    |> cast(attrs, [:nome, :matricula, :provas, :ft, :fp, :ef, :conceito, :updated_at, :total])
  end
end
