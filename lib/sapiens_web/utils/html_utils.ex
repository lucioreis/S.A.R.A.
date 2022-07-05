defmodule SapiensWeb.HtmlUtils do
  use Phoenix.Component

  def list(assigns) do
    ~H"""
    <%= for entry <- @entries do %>
      <%= render_slot(@inner_block, entry) %>
    <% end %>
    """
  end
end
