defmodule SapiensWeb.Components.CardDisciplina do
  use SapiensWeb, :live_component
  alias Sapiens.Disciplinas
  alias Sapiens.Turmas
  alias Sapiens.Estudantes
  alias Sapiens.Acerto
  alias SapiensWeb.Components.Action

  require IEx

  @impl true
  def mount(socket) do
    Phoenix.PubSub.subscribe(Sapiens.PubSub, "matricula")

    # socket = assign(socket, disciplina: gen_disciplina())
    {:ok, socket}
  end

  @impl true
  def handle_event(
        "add",
        %{"disciplina_id" => disciplina_id, "turma_numero" => turma_numero},
        socket
      ) do
    disciplina_id = String.to_integer(disciplina_id)
    turma_numero = String.to_integer(turma_numero)

    {
      :noreply,
      apply_action(:add, socket, disciplina_id, turma_numero)
    }
  end

  @impl true
  def handle_event(
        "remove",
        %{"disciplina_id" => disciplina_id, "turma_numero" => turma_numero},
        socket
      ) do
    {
      :noreply,
      apply_action(
        :remove,
        socket,
        disciplina_id,
        turma_numero
      )
    }
  end

  @impl true
  def handle_event(
        "change",
        %{"turma_numero" => turma_numero, "disciplina_id" => disciplina_id},
        socket
      ) do
    disciplina_id = String.to_integer(disciplina_id)
    turma_numero = String.to_integer(turma_numero)

    {
      :noreply,
      apply_action(:troca, socket, disciplina_id, turma_numero)
    }
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:estudante, assigns.estudante)
     |> assign(:estudante_id, assigns.estudante_id)
     |> assign(:disciplina, assigns.disciplina)
     |> assign(:horario, assigns.horario)
     |> assign(:matriculado, assigns.matriculado)
     |> assign(:matriculas, assigns.matriculas)
     |> assign(:alt_agent, assigns.alt_agent)}
  end

  @impl true
  def preload(list_of_assigns) do
    Enum.map(list_of_assigns, fn assigns ->
      {:ok, estudante} = Estudantes.by_id(assigns.estudante_id)
      {:ok, horario} = Estudantes.get_horarios(estudante)
      {:ok, disciplina} = Disciplinas.by_id(assigns.disciplina_id)
      matriculas = Turmas.preload_all(assigns.matriculas, :disciplina)
      matriculado = matriculado?(assigns.matriculas, disciplina)
      {:ok, alt_agent} = Sapiens.Alteracoes.start_link(estudante)

      assigns
      |> Map.put(:estudante, estudante)
      |> Map.put(:matriculas, matriculas)
      |> Map.put(:matriculado, matriculado)
      |> Map.put(:alt_agent, alt_agent)
      |> Map.put(:horario, horario)
      |> Map.put(:disciplina, Disciplinas.preload(disciplina, :turmas))
    end)
  end

  def matriculado?(matriculas, disciplina) do
    disciplina.id in for(turma <- matriculas, do: turma.disciplina_id)
  end

  defp apply_action(action, socket, disciplina_id, turma_numero) do
    {:ok, estudante} = Estudantes.by_id(socket.assigns.estudante_id)
    {:ok, horario} = Estudantes.get_horarios(estudante)
    {:ok, matriculas} = Estudantes.get_turmas_matriculado(estudante)
    {:ok, turma} = Turmas.get_by(disciplina_id: disciplina_id, numero: turma_numero)

    # unless Map.equal?(Acerto.validar_horario(estudante, turma), %{}) do 
    #   action = :remove
    # end
    #
    # defstruct pid: nil, author: nil, time: nil, action: nil, old: nil, target: nil

    func =
      case action do
        :add ->
          &Acerto.adiciona/2

        :troca ->
          &Acerto.troca/2

        :remove ->
          &Acerto.remove/2
      end

    # require IEx; IEx.pry

    Sapiens.Alteracoes.push(
      socket.assigns.alt_agent,
      %Sapiens.Alteracoes{
        pid: self(),
        author: socket.assigns.estudante,
        time: :now,
        action: action,
        target: turma
      }
    )

    send(self(), {:alt, %{agent: socket.assigns.alt_agent}})

    case Acerto.validar_horario(estudante, turma) do
      {:ok, _} ->
        case func.(estudante, turma) do
          {:ok, turma} ->
            matriculado = if action == :remove, do: false, else: true

            Phoenix.PubSub.broadcast(
              Sapiens.PubSub,
              "matricula",
              {:mat,
               %{
                 sender: self(),
                 disciplina_id: disciplina_id
               }}
            )

            {:ok, horario} = Estudantes.get_horarios(estudante)
            {:ok, matriculas} = Estudantes.get_turmas_matriculado(estudante)
            matriculas = Turmas.preload_all(matriculas, :disciplina)

            send(
              self(),
              {:updated_horario, %{horario: horario, matriculas: matriculas, collisions: %{}}}
            )

            socket
            |> assign(turma: turma)
            |> assign(matriculas: matriculas)
            |> assign(matriculado: matriculado)

          _ ->
            IO.puts("Problemas na ação #{action}")
            socket
        end

      {:error, collisions} ->
        send(
          self(),
          {:updated_horario, %{horario: horario, matriculas: matriculas, collisions: collisions}}
        )

        socket
    end
  end

  def dia_to_string(dia) do
    dias = %{1 => 'Seg', 2 => "Ter", 3 => "Qua", 4 => "Qui", 5 => "Sex", 6 => "Sab"}
    dias[dia]
  end
end
