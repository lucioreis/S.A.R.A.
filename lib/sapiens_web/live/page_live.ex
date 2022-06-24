defmodule SapiensWeb.PageLive do
  use SapiensWeb, :live_view
  alias Sapiens.Estudante

  @impl true
  def mount(_params, _session, socket) do
    id = 31

    {:ok, horario} = Estudante.get_horarios(id)

    socket = 
      socket
      |> assign(menu_options: [
        {"sync","Acerto de Matrícula", SapiensWeb.AcertoLive},
        {"lock", "Avaliacoes", SapiensWeb.AvaliacoesLive},
        {"casino", "Dados Acadêmicos", SapiensWeb.DadosAcademicosLive },
        {"casino", "Dados Pessoais", SapiensWeb.DadosPessoalLive},
        {"library_books", "Biblioteca", SapiensWeb.PageLive }, 
        {"task","Plano de estudo", SapiensWeb.PlanoEstudoLive},
      ])
      |> assign(name: "Home")
      |> assign(horario: horario)
      |> assign(id: id)

    {:ok, socket}
  end

  @impl true
  def handle_event("avaliacoes", _params, socket) do
    {:noreply, push_redirect(socket, to: "/avaliacoes")}
  end

end
