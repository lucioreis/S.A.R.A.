defmodule SapiensWeb.AcertoLive do
  use SapiensWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = 
      socket
      |> assign(menu_options: [
        {"sync","Acerto de Matrícula"},
        {"lock", "Avaliacoes" },
        {"casino", "Dados Acadêmicos" },
        {"casino", "Dados Pessoais" },
        {"library_books", "Biblioteca" }, 
        {"task","Plano de estudo"},
        {"close", "Saír"}
      ])

    {:ok, assign(socket, name: "It's working")}
  end
  
end
