defmodule SapiensWeb.PageLive do
  use SapiensWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = 
      socket
      |> assign(menu_options: [
        {"sync","Acerto de Matrícula", "acerto"},
        {"lock", "Avaliacoes" },
        {"casino", "Dados Acadêmicos" },
        {"casino", "Dados Pessoais" },
        {"library_books", "Biblioteca" }, 
        {"task","Plano de estudo"},
        {"close", "Saír"}
      ])

    {:ok, assign(socket, name: "It's working")}
  end

  @impl true
  def handle_event("avaliacoes", _params, socket) do
    {:noreply, push_redirect(socket, to: "/avaliacoes")}
  end
end
