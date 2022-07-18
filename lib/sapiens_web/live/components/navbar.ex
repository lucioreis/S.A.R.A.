defmodule SapiensWeb.Components.Navbar do
  use SapiensWeb, :live_component
  alias SapiensWeb.Live.Components.Notifications

  @impl true
  def mount(socket) do
    {:ok, socket}
  end
end
