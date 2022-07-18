defmodule SapiensWeb.Components.Action do
  use Phoenix.Component

  @moduledoc """
  Botão de Ação
  Inclui estilos e comportamentos no botão de ação.
  (Adicionar, Remover e Trocar)
  """
  # prop target, :any

  # Retorna `bool` se a turma está entre as matriculas
  defp matriculado(turma, matriculas) do
    turma.id in for t <- matriculas, do: t.id
  end

  # Retorna `bool` se o aluno está metriculado em um turma de `disciplina`
  defp registrado(disciplina_id, matriculas) do
    disciplina_id in for t <- matriculas, do: t.disciplina_id
  end

  def button(assigns) do
    ~H"""
    <div>
      <%= if @turma.vagas_disponiveis > 0  do %>
        <%= if not registrado(@disciplina_id, @matriculas) and not matriculado(@turma, @matriculas) and @clean do %>
          <div
            phx-click="add"
            phx-target={@target}
            phx-value-turma_numero={@turma.numero}
            phx-value-disciplina_id={@disciplina_id}
            class="material-symbols-outlined cursor-pointer hover:text-highlight"
          >
            add_circle
          </div>
        <% end %>
        <%= if registrado(@disciplina_id, @matriculas) and not matriculado(@turma, @matriculas) and @clean do %>
          <div
            phx-click="change"
            phx-target={@target}
            phx-value-turma_numero={@turma.numero}
            phx-value-disciplina_id={@disciplina_id}
            class="material-symbols-outlined cursor-pointer hover:text-highlight"
          >
            sync
          </div>
        <% end %>
        <%= if registrado(@disciplina_id, @matriculas) and matriculado(@turma, @matriculas) and @clean do %>
          <div
            phx-click="remove"
            phx-target={@target}
            phx-value-turma_numero={@turma.numero}
            phx-value-disciplina_id={@disciplina_id}
          >
            <span class="material-symbols-outlined cursor-pointer hover:text-highlight">
              remove
            </span>
          </div>
        <% end %>
        <%= if not @clean do %>
          <div
            phx-click="undo"
            phx-target={@target}
            phx-value-turma_numero={@turma.numero}
            phx-value-disciplina_id={@disciplina_id}
          >
            <span class="material-symbols-outlined cursor-pointer hover:text-highlight">
              undo
            </span>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end
end
