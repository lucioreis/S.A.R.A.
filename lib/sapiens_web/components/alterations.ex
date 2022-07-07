defmodule SapiensWeb.Alterations do
  use Phoenix.Component

  defp alterations_to_string(alteration) do
    case alteration.action do
      :change ->
        "Trocando turma #{alteration.turma.numero} por #{alteration.turma.numero}"

      :add ->
        "Adicionando turma #{alteration.turma.numero}"

      :remove ->
        "Removendo turma #{alteration.turma.numero}"
      true -> ""
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
