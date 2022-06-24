defmodule SapiensWeb.Components.CardDisciplina do
  use SapiensWeb, :live_component

  @impl true
  def mount(socket) do
    # socket = assign(socket, disciplina: gen_disciplina())

    {:ok, socket}
  end

  @impl true
  def handle_event("add", %{"numero" => numero, "codigo" => codigo}, socket) do
    {
      :noreply,
      socket
    }
  end

  @impl true
  def handle_event("remove", %{"numero" => numero, "codigo" => codigo}, socket) do
    {
      :noreply,
      socket
    }
  end

  @impl true
  def handle_event("change", %{"numero" => numero, "codigo" => codigo}, socket) do
    {:noreply, socket}
  end

  defp remove(socket, numero, codigo) do
    {:noreply, socket}
  end

  defp add(socket, numero, codigo) do
    {:noreply, socket}
  end

  # @impl true
  # def update(_assigns, socket) do
  #   {:ok, socket}
  # end
end
