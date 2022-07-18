defmodule Sapiens.Cursos.Avaliacao do
  import Ecto.Changeset
  use Ecto.Schema

  embedded_schema do
    field(:nome, :string)
    field(:hora, :integer)
    field(:nota, :integer, default: 0)
    field(:local, :string)
    field(:ordem, :integer, default: 0)
    field(:total, :integer, default: 0)
  end

  @doc false
  def changeset(avaliacao, attrs) do
    avaliacao
    |> cast(attrs, [:nome, :hora, :nota, :local, :ordem, :total])
    |> validate_required([:nome, :hora, :local, :ordem, :total])
  end
end
