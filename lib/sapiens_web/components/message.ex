defmodule SapiensWeb.Components.Message do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div class={
      "bg-yellow-300 p-2 sticky z-10 top-0 right-0 flex justify-between item-center" <>
        if(@message, do: "hidden", else: "")
    }>
      <div>
        <%= @message %>
      </div>
      <div phx-click="dismiss_msg" class="cursor-pointer">
        <span class="material-symbols-outlined">close</span>
      </div>
    </div>
    """
  end
end
