defmodule SapiensWeb.AdminLive.Index do
  use SapiensWeb, :live_view

  @impl true
  def mount(_p, _s, socket) do
    socket =
      socket
      |> assign(name: "Administrador")
      |> assign(menu_options: [])

    {:ok, socket}
  end
end
