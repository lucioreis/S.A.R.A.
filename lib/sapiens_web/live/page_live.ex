defmodule SapiensWeb.PageLive do
  use SapiensWeb, :live_view
  alias Sapiens.Estudante

  @impl true
  def mount(%{"id" => id}, _session, socket) do

    id = String.to_integer(id)
    {:ok, estudante} = Estudante.by_id(id)
    {:ok, horario} = Estudante.get_horarios(estudante)

    socket = 
      socket
      |> assign(menu_options: [
        {"sync","Acerto de Matrícula", &Routes.live_path(&1, SapiensWeb.AcertoLive, id: id)},
        {"lock", "Avaliacoes",&Routes.live_path(&1, SapiensWeb.AvaliacoesLive, id: id)},
        {"casino", "Dados Acadêmicos",&Routes.live_path(&1, SapiensWeb.DadosAcademicosLive , id: id)},
        {"casino", "Dados Pessoais",&Routes.live_path(&1, SapiensWeb.DadosPessoalLive, id: id)},
        {"library_books", "Biblioteca",&Routes.live_path(&1, SapiensWeb.PageLive , id: id)}, 
        {"task","Plano de estudo",&Routes.live_path(&1, SapiensWeb.PlanoEstudoLive, id: id)},
      ])
      |> assign(name: "Home")
      |> assign(horario: horario)
      |> assign(estudante: estudante)
      |> assign(estudante_id: id)
      |> assign(user_id: id)

    {:ok, socket}
  end

  @impl true
  def mount(_params, session , socket) do
    mount(%{"id" => "1"}, session, socket)
  end

  @impl true
  def handle_event("avaliacoes", %{"id" => id}, socket) do
    {:noreply, push_redirect(socket, to: "/avaliacoes/#{id}")}
  end

end
