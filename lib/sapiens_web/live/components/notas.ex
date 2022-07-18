defmodule SapiensWeb.Live.Components.Notas do
  use SapiensWeb, :live_component

  def mount(socket) do 
    provas = %Sapiens.Cursos.Provas{p1: 34}
    notas = Ecto.Changeset.change(provas)


    {:ok, 
      socket
      |>assign(notas: notas)
      |> assign(provas: provas)
      |>assign(edit: false)}
  end

  def handle_event("post_notas", %{"provas" => form}, socket) do
    IO.inspect(form)

    {:noreply, assign(socket, :edit, not socket.assigns.edit)}
  end

  def handle_event("change_mode", _, socket) do
    {:noreply, assign(socket, :edit, not socket.assigns.edit)}
  end
end
