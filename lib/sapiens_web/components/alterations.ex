defmodule SapiensWeb.Alterations do
  use Phoenix.Component

  defp alterations_to_string(alteration) do
    case alteration.action do
      :change ->
        "#{alteration.turma.disciplina.codigo}: Trocando para turma #{alteration.turma.numero}"

      :add ->
        "#{alteration.turma.disciplina.codigo}: Adicionando turma #{alteration.turma.numero}"

      :remove ->
        "#{alteration.turma.disciplina.codigo}: Removendo turma #{alteration.turma.numero}"

      true ->
        ""
    end
  end

  def render(assigns) do
    ~H"""
      <div class="text-lg text-light mt-2 text-highlight"> Alteracoes: </div>
      <%= for alt <- @alteracoes do %>

      <div class=""> <%= alterations_to_string(alt) %> </div>
      <% end %>
    """
  end
end
