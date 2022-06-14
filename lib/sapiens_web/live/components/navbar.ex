defmodule SapiensWeb.Components.Navbar do
  use SapiensWeb, :live_component

  def mount(socket) do
    socket = 
      socket
      |> assign(navbar: "it's Working")
    {:ok, socket}
  end
end
