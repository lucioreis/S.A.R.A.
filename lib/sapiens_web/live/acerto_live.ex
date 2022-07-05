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

    socket =
      socket
      |> assign(:estudante_id, String.to_integer(id))
      |> assign(:user_id, String.to_integer(id))

    {:ok, estudante} = Estudantes.by_id(socket.assigns.estudante_id)
    {:ok, disciplinas} = Estudantes.get_disciplinas(estudante)
    {:ok, horario} = Estudantes.get_horarios(estudante)
    {:ok, matriculas} = Estudantes.get_turmas_matriculado(estudante)
    matriculas = Turmas.preload_all(matriculas, :disciplina)
    {:ok, alt_agent} = Sapiens.Alteracoes.start_link(estudante)

    {
      :ok,
      socket
      |> assign(collisions: %{})
      |> assign(disciplinas: disciplinas)
      |> assign(horario: horario)
      |> assign(matriculas: matriculas)
      |> assign(name: "Acerto")
      |> assign(alt_agent: alt_agent)
      |> assign(alteracoes: [])
      |> build_message()
    }
  end
  #
  # @impl true
  # def handle_params(%{"id" => id}, _uri, socket) do
  #   socket =
  #     socket
  #     |> assign(:estudante_id, String.to_integer(id))
  #
  #   {:ok, estudante} = Estudantes.by_id(socket.assigns.estudante_id)
  #   {:ok, disciplinas} = Estudantes.get_disciplinas(estudante)
  #   {:ok, horario} = Estudantes.get_horarios(estudante)
  #   {:ok, matriculas} = Estudantes.get_turmas_matriculado(estudante)
  #   matriculas = Turmas.preload_all(matriculas, :disciplina)
  #
  #   {
  #     :noreply,
  #     socket
  #     |> assign(disciplinas: disciplinas)
  #     |> assign(horario: horario)
  #     |> assign(matriculas: matriculas)
  #     |> assign(name: "Acerto")
  #   }
  # end

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
  def handle_info({:mat, %{disciplina_id: disciplina_id, sender: sender}}, socket) do
    if sender == self() do
      {:noreply, socket}
      # require IEx; IEx.pry
    else
      {:ok, estudante} = Estudantes.by_id(socket.assigns.estudante_id)
      {:ok, horario} = Estudantes.get_horarios(estudante)
      {:ok, matriculas} = Estudantes.get_turmas_matriculado(estudante)
      matriculas = Turmas.preload_all(matriculas, :disciplina)

      socket =
        socket
        |> assign(horario: horario)
        |> assign(matricula: matriculas)

      send_update(
        SapiensWeb.Components.CardDisciplina,
        id: disciplina_id,
        disciplina_id: disciplina_id,
        estudante_id: socket.assigns.estudante_id,
        matriculas: socket.assigns.matriculas
      )

      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:alt, %{agent: agent_pid}}, socket) do
      {:noreply, 
        socket
      |> assign(alteracoes: Alteracoes.get(agent_pid))
      }
  end

  @impl true
  def handle_event(
        "hover_on_turma",
        %{"turma_id" => turma_id, "estudante_id" => estudante_id},
        socket
      ) do
    {:ok, turma} = Turmas.by_id(String.to_integer(turma_id))
    {:ok, estudante} = Estudantes.by_id(String.to_integer(estudante_id))

    case Acerto.validar_horario(estudante, turma) do
      {:ok, _h} ->
        {:noreply, socket}

      {:error, _collisions} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("dismiss_msg", _params, socket) do
    {:noreply, 
    socket
    |> assign(message: nil)
    }
  end

  @impl true
  def handle_event("confirm", _params, socket) do
    Sapiens.Alteracoes.clean(socket.assigns.alt_agent)
    socket = assign(socket, alteracoes: [])
    {:noreply, socket}
  end

  defp build_message(socket) do
    socket
    |> assign(message: "This is another message!")

  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen relative">
      <%= if @message do %>
        <SapiensWeb.Components.Message.render message={@message} />
      <% end %>
      <div> <SapiensWeb.Alterations.render alteracoes={@alteracoes} /> </div>
      <div class="flex justify-center m-2" phx-click="confirm">
      <SapiensWeb.Components.Button.confirm class="w-1/2" />
      </div>
      <div class="flex flex-col md:flex-row m-2">
        <div class="md:w-1/2 md:h-screen">
          <SapiensWeb.Components.DisciplinasMatriculado.show matriculas={@matriculas} />

          <Horario.render horario={@horario} collisions={@collisions} />
        </div>

        <div class="md:h-screen md:overflow-scroll bg-base-200 md:w-1/2 mt-2 my-2 md:ml-2 md:mt-0 flex flex-col gap-y-2">
          <%= for disciplina <- @disciplinas do %>
            <.live_component
              @socket
              module={SapiensWeb.Components.CardDisciplina}
              id={disciplina.id}
              estudante_id={@estudante_id}
              disciplina_id={disciplina.id}
              codigo={disciplina.codigo}
              matriculas={@matriculas}
            />
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
