defmodule SapiensWeb.Alterations do
  use Phoenix.Component

  defp alterations_to_string(alteration) do
    case alteration.action do
      :add -> "Adicionando turma #{alteration.target.numero}"
      :remove -> "Removendo turma #{alteration.target.numero}"
      :troca -> "Trocando turma #{alteration.target.numero}"
    end
  end

  def render(assigns) do
    ~H"""
      <div> Alteracoes: </div>
      <%= for alt <- @alteracoes do %>

      <div class=""> <%= alterations_to_string(alt) %> </div>
      <% end %>
    """
  end
end
