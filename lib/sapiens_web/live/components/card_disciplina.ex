defmodule SapiensWeb.Components.CardDisciplina do
  use SapiensWeb, :live_component
  alias Sapiens.Disciplinas
  alias Sapiens.Turmas
  alias Sapiens.Estudantes
  alias Sapiens.Acerto
  alias Sapiens.Alteracoes
  alias SapiensWeb.Components.Action

  require IEx

  @impl true
  def mount(socket) do
    Phoenix.PubSub.subscribe(Sapiens.PubSub, "matricula")

    socket = assign(socket, commited: true)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "add",
        %{"turma_numero" => turma_numero},
        socket
      ) do
    turma_numero = String.to_integer(turma_numero)

    {
      :noreply,
      apply_action(:add, socket, turma_numero)
    }
  end

  @impl true
  def handle_event(
        "remove",
        %{"turma_numero" => turma_numero},
        socket
      ) do
    turma_numero = String.to_integer(turma_numero)

    {
      :noreply,
      apply_action(
        :remove,
        socket,
        turma_numero
      )
    }
  end

  @impl true
  def handle_event(
        "change",
        %{"turma_numero" => turma_numero},
        socket
      ) do
    turma_numero = String.to_integer(turma_numero)

    {
      :noreply,
      apply_action(:change, socket, turma_numero)
    }
  end

  @impl true
  def handle_event("undo", %{"disciplina_id" => disciplina_id}, socket) do
    disciplina_id = String.to_integer(disciplina_id)
    response = Alteracoes.undo(socket.assigns.alt_agent, disciplina_id)
    alteracoes = Alteracoes.get_all(socket.assigns.alt_agent)
    IO.inspect(alteracoes, label: "alteracoes")

    matriculado =
      disciplina_id in for(turma <- response.matriculas, do: turma.disciplina.id)

    send(self(), {:alt, %{agent: response.server}})

    send(
      self(),
      {:updated_horario,
       %{horario: response.horario, matriculas: response.matriculas, collisions: %{}}}
    )

    {
      :noreply,
      socket
      |> assign(:clean, Alteracoes.is_clean(socket.assigns.alt_agent, disciplina_id))
      |> assign(:alteracoes, alteracoes)
      |> assign(matriculas: response.matriculas)
      |> assign(matriculado: matriculado)
      |> assign(horario: response.horario)
    }
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:horario, assigns.horario)
     |> assign(:estudante, assigns.estudante)
     |> assign(:matriculado, assigns.matriculado)
     |> assign(:matriculas, assigns.matriculas)
     |> assign(:disciplina, assigns.disciplina)
     |> assign(:turmas, assigns.turmas)
     |> assign(:clean, assigns.clean)
     |> assign(:vagas, assigns.vagas)
     |> assign(:alt_agent, assigns.alt_agent)
    |> assign(:alteracoes, assigns.alteracoes)}
  end

  @impl true
  def preload(list_of_assigns) do
    Enum.map(list_of_assigns, fn assigns ->
      disciplina = Disciplinas.preload(assigns.disciplina, :turmas)
      turmas = disciplina.turmas
      response = Alteracoes.load(assigns.estudante)
      horario = response.horario
      matriculas = response.matriculas
      alteracoes = Alteracoes.get_all(response.server)
      matriculado = matriculado?(response.matriculas, disciplina)
      vagas = Sapiens.Queue.get_vagas(disciplina.id)

      alt_agent =
        if response.server != nil, do: response.server, else: raise("Response.server is nil")

      clean = Alteracoes.is_clean(alt_agent, disciplina.id)

      assigns
      |> Map.put(:disciplina, disciplina)
      |> Map.put(:turmas, turmas)
      |> Map.put(:matriculas, matriculas)
      |> Map.put(:matriculado, matriculado)
      |> Map.put(:alt_agent, alt_agent)
      |> Map.put(:horario, horario)
      |> Map.put(:clean, clean)
      |> Map.put(:alteracoes, alteracoes)
      |> Map.put(:vagas, vagas)
    end)
  end

  def matriculado?(matriculas, disciplina) do
    disciplina.id in for(turma <- matriculas, do: turma.disciplina_id)
  end

  defp apply_action(action, socket, turma_numero) do
    response = Alteracoes.load(socket.assigns.estudante)

    [turma] =
      Enum.filter(socket.assigns.disciplina.turmas, fn turma -> turma.numero == turma_numero end)

    turma = Turmas.preload(turma, :disciplina)

    response =
      Sapiens.Alteracoes.push(
        response.server,
        %Sapiens.Alteracoes.Request{
          client: self(),
          author: socket.assigns.estudante,
          action: action,
          disciplina: socket.assigns.disciplina,
          time: :os.system_time(:millisecond),
          turma: turma
        }
      )

    matriculado =
      turma.disciplina.codigo in for(turma <- response.matriculas, do: turma.disciplina.codigo)

    send(self(), {:alt, %{agent: response.server}})

    send(
      self(),
      {:updated_horario,
       %{
         horario: response.horario,
         matriculas: response.matriculas,
         collisions: response.collisions
       }}
    )

    socket
    |> assign(matriculas: response.matriculas)
    |> assign(matriculado: matriculado)
    |> assign(commited: false)
    |> assign(:vagas, Sapiens.Queue.get_vagas(socket.assigns.disciplina.id))
    |> assign(clean: Alteracoes.is_clean(socket.assigns.alt_agent, socket.assigns.disciplina.id))
  end

  def dia_to_string(dia) do
    dias = %{1 => 'Seg', 2 => "Ter", 3 => "Qua", 4 => "Qui", 5 => "Sex", 6 => "Sab"}
    dias[dia]
  end
end
