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
    Alteracoes.undo(socket.assigns.alt_agent, disciplina_id)
    {:noreply, socket}
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
     |> assign(:clean, assigns.clean)
    |> assign(:alt_agent, assigns.alt_agent)}
  end

  @impl true
  def preload(list_of_assigns) do
    Enum.map(list_of_assigns, fn assigns ->
      disciplina = Disciplinas.preload(assigns.disciplina, :turmas)
      response = Alteracoes.load(assigns.estudante)
      horario = response.horario
      matriculas = response.matriculas
      matriculado = matriculado?(assigns.matriculas, disciplina)
      alt_agent = response.server
      clean = Alteracoes.is_clean(alt_agent, disciplina.id)

      assigns
      |> Map.put(:disciplina, disciplina)
      |> Map.put(:matriculas, matriculas)
      |> Map.put(:matriculado, matriculado)
      |> Map.put(:alt_agent, alt_agent)
      |> Map.put(:horario, horario)
      |> Map.put(:clean, clean)
    end)
  end

  def matriculado?(matriculas, disciplina) do
    disciplina.id in for(turma <- matriculas, do: turma.disciplina_id)
  end

  defp apply_action(action, socket, turma_numero) do
    response = Alteracoes.load(socket.assigns.estudante)

    {:ok, turma} =
      Turmas.get_by(disciplina_id: socket.assigns.disciplina.id, numero: turma_numero)

    case Acerto.validar_horario(response.author, turma) do
      {:ok, _} ->
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

        send(self(), {:alt, %{agent: response.server}})

        Phoenix.PubSub.broadcast(
          Sapiens.PubSub,
          "matricula",
          {:mat,
           %{
             sender: self(),
             disciplina_id: socket.assigns.disciplina.id
           }}
        )

        matriculado = if action == :remove, do: false, else: true

        send(
          self(),
          {:updated_horario,
           %{horario: response.horario, matriculas: response.matriculas, collisions: %{}}}
        )

        socket
        |> assign(turma: turma)
        |> assign(matriculas: response.matriculas)
        |> assign(matriculado: matriculado)
        |> assign(commited: false)
        |> assign(clean: Alteracoes.is_clean(response.server, socket.assigns.disciplina.id))

      {:error, collisions} ->
        send(
          self(),
          {:updated_horario,
           %{horario: response.horario, matriculas: response.matriculas, collisions: collisions}}
        )

        socket
    end
  end

  def dia_to_string(dia) do
    dias = %{1 => 'Seg', 2 => "Ter", 3 => "Qua", 4 => "Qui", 5 => "Sex", 6 => "Sab"}
    dias[dia]
  end
end
