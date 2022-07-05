defmodule SapiensWeb.Components.ListItens do
  use Phoenix.Component

  def unordered(assigns) do
    ~H"""
      <ul>
        <%= for entry <- @entries do %>
          <li> <%= render_slot(@inner_block, entry) %> </li>
        <% end %>
      </ul>
    """
  end
end
