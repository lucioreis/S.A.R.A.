defmodule SapiensWeb.Live.Components.Notifications do
  use SapiensWeb, :live_component

  def mount(socket) do
    notifications = 
          Sapiens.Notifications.get_all_notifications(1)

    {
      :ok,
      socket
      |> assign(notifications: notifications)
      |> assign(user_id: 1)
      |> assign(toggle: false)
    }
  end


  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(user_id: 1)
    }
  end

  def handle_event("toggle", _, socket) do
    notifications = Sapiens.Notifications.dismiss_all(socket.assigns.user_id) |> IO.inspect()
    {
      :noreply,
      socket
      |> assign(toggle: not socket.assigns.toggle)
      |> assign(notifications: notifications)
    }
  end
end
