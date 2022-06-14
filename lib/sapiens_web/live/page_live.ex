defmodule SapiensWeb.PageLive do
  use SapiensWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do

    horario = get_horario(socket)

    socket = 
      socket
      |> assign(menu_options: [
        {"sync","Acerto de Matrícula", SapiensWeb.AcertoLive},
        {"lock", "Avaliacoes", SapiensWeb.AvaliacoesLive},
        {"casino", "Dados Acadêmicos", SapiensWeb.DadosAcademicosLive },
        {"casino", "Dados Pessoais", SapiensWeb.DadosPessoalLive},
        {"library_books", "Biblioteca", SapiensWeb.PageLive }, 
        {"task","Plano de estudo", SapiensWeb.PlanoEstudoLive},
        {"close", "Saír", SapiensWeb.PageLive}
      ])
      |> assign(name: "Home")
      |> assign(horario: horario)

    {:ok, socket}
  end

  @impl true
  def handle_event("avaliacoes", _params, socket) do
    {:noreply, push_redirect(socket, to: "/avaliacoes")}
  end


  defp get_horario(_socket) do
    %{
      {1, 8} => %{codigo: "INF 123", local: "PVA 123"},
      {1, 9} => %{codigo: "INF 123", local: "PVA 123"},
      {2, 10} => %{codigo: "INF 123", local: "PVA 123"},
      {2, 11} => %{codigo: "INF 123", local: "PVA 123"},
      {2, 14} => %{codigo: "INF 789", local: "PVA 123"},
      {2, 15} => %{codigo: "INF 789", local: "PVA 123"},
      {4, 16} => %{codigo: "INF 789", local: "PVA 345"},
      {4, 17} => %{codigo: "INF 789", local: "PVA 345"}
    }
  end

end
