defmodule SapiensWeb.AcertoLive do
  use SapiensWeb, :live_view

  alias Sapiens.Estudantes, warn: false
  alias Sapiens.Turmas, warn: false
  alias Sapiens.Disciplinas, warn: false
  alias SapiensWeb.Router.Helpers, as: Routes
  alias Sapiens.Repo, warn: false
  alias Sapiens.Acerto, warn: false
  alias Sapiens.Alteracoes, warn: false
  alias SapiensWeb.Live.Components.Horario

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    Phoenix.PubSub.subscribe(Sapiens.PubSub, "matricula")

    socket =
      socket
      |> assign(
        menu_options: [
          {"sync", "Acerto de Matrícula", &Routes.live_path(&1, SapiensWeb.AcertoLive, id: id)},
          {"lock", "Avaliacoes", &Routes.live_path(&1, SapiensWeb.AvaliacoesLive, id: id)},
          {"casino", "Dados Acadêmicos",
           &Routes.live_path(&1, SapiensWeb.DadosAcademicosLive, id: id)},
          {"casino", "Dados Pessoais",
           &Routes.live_path(&1, SapiensWeb.DadosPessoalLive, id: id)},
          {"library_books", "Biblioteca", &Routes.live_path(&1, SapiensWeb.PageLive, id: id)},
          {"task", "Plano de estudo", &Routes.live_path(&1, SapiensWeb.PlanoEstudoLive, id: id)}
        ]
      )

    id = String.to_integer(id)
    {:ok, estudante} = Estudantes.by_id(id)
    {:ok, disciplinas} = Estudantes.get_disciplinas(estudante)

    socket =
      socket
      |> assign(:estudante_id, id)
      |> assign(:user_id, id)

    response = Alteracoes.load(estudante)
    alteracoes = Alteracoes.get_all(response.server)

    {
      :ok,
      socket
      |> assign(collisions: %{})
      |> assign(estudante: estudante)
      |> assign(disciplinas: disciplinas)
      |> assign(horario: response.horario)
      |> assign(matriculas: response.matriculas)
      |> assign(name: "Acerto")
      |> assign(alt_agent: response.server)
      |> assign(alteracoes: alteracoes)
      |> assign(modal: :closed)
    }
  end

  @impl true
  def handle_info(
        {:updated_horario, %{horario: horario, matriculas: matriculas, collisions: collisions}},
        socket
      ) do
    matriculas = Turmas.preload_all(matriculas, :disciplina)

    {:noreply,
     socket
     |> assign(matriculas: matriculas)
     |> assign(horario: horario)
     |> assign(collisions: collisions)}
  end

  @impl true
  def handle_info({:mat, %{disciplina: disciplina, sender: sender}}, socket) do
    if sender == self() do
      # IO.inspect({:mat, %{sender: sender}})
      {:noreply, socket}
      # require IEx; IEx.pry
    else
      response = Alteracoes.load(socket.assigns.estudante)

      socket =
        socket
        |> assign(horario: response.horario)
        |> assign(matricula: response.matriculas)

      send_update(
        SapiensWeb.Components.CardDisciplina,
        id: disciplina.id,
        disciplina: disciplina,
        estudante: socket.assigns.estudante,
        matriculas: socket.assigns.matriculas
      )

      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:alt, %{agent: server_pid}}, socket) do
    {:noreply,
     socket
     |> assign(alteracoes: Alteracoes.get_all(server_pid))}
  end

  @impl true
  def handle_info({:matricula, disciplina_id}, socket) do
    case Enum.filter(socket.assigns.disciplinas, &(&1.id == disciplina_id)) do
      [] ->
        {:noreply, socket}

      [disciplina] ->
        send_update(
          SapiensWeb.Components.CardDisciplina,
          id: disciplina_id,
          disciplina: disciplina,
          estudante: socket.assigns.estudante,
          matriculas: socket.assigns.matriculas
        )

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("dismiss_msg", _params, socket) do
    {:noreply,
     socket
     |> assign(message: nil)}
  end

  @impl true
  def handle_event("confirm", _params, socket) do
    state = Sapiens.Alteracoes.commit(socket.assigns.alt_agent)

    socket =
      assign(socket, alteracoes: [])
      |> assign(socket, modal: :closed)

    for disciplina <- socket.assigns.disciplinas do
      send_update(
        SapiensWeb.Components.CardDisciplina,
        id: disciplina.id,
        disciplina: disciplina,
        estudante: state.author,
        matriculas: state.matriculas
      )
    end

    handle_event("toggle_modal", "", socket)
  end

  @impl true
  def handle_event("toggle_modal", _params, socket) do
    state = Alteracoes.get_state(socket.assigns.alt_agent)
    included_horario = Estudantes.build_horario(state.included)
    removed_horario = Estudantes.build_horario(state.removed)

    if socket.assigns.modal == :closed do
      {:noreply,
       socket
       |> assign(modal: :opened)
       |> assign(included_horario: included_horario)
       |> assign(removed_horario: removed_horario)}
    else
      {:noreply, assign(socket, modal: :closed)}
    end
  end

  defp build_message(socket, msg \\ "") do
    socket
    |> assign(message: msg)
  end
end
