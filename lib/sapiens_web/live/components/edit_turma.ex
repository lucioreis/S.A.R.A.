defmodule SapiensWeb.Live.Components.EditTurma do
  use SapiensWeb, :live_component

  @impl true
  def mount(socket) do
    avaliacao = Ecto.Changeset.change(%Sapiens.Cursos.Avaliacao{})
    socket = assign(socket, :changeset, avaliacao)
    {:ok, socket}
  end
end
