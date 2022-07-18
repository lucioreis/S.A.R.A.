defmodule Sapiens.Cursos.Notifications do
  use Ecto.Schema
  import Ecto.Changeset

    schema "notifications" do
    field(:read, :boolean)
    field(:message, :string)
    

    timestamps()

    belongs_to(:estudante, Sapiens.Cursos.Estudante)
    belongs_to(:professor, Sapiens.Cursos.Professor)
    belongs_to(:disciplina, Sapiens.Cursos.Disciplina)
  end

  @doc false
  def changeset(notification, attrs \\ %{}) do
    notification
    |> cast(
      attrs, 
      [
        :read,
        :message
      ]
    )
    |> validate_required([:message])
  end
end
