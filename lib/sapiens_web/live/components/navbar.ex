defmodule SapiensWeb.Components.Navbar do
  use SapiensWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
  end
end
