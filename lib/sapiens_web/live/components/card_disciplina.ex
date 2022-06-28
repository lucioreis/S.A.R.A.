defmodule SapiensWeb.Components.CardDisciplina do
  use SapiensWeb, :live_component
  alias Sapiens.Disciplina
  alias Sapiens.Turma
  alias Sapiens.Estudante
  alias Sapiens.Repo

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
     |> assign(:matriculas, assigns.matriculas)}
  end

  @impl true
  def preload(list_of_assigns) do
    # codigo
    # disciplina_id
    # estudante_id
    # matriculas [
    #  %Turma{
    #   disciplina
    #   horario
    #   numero
    # }
    # ]

    Enum.map(list_of_assigns, fn assigns ->
      {:ok, estudante} = Estudante.by_id(assigns.estudante_id)
      {:ok, horario} = Estudante.get_horarios(estudante)
      {:ok, disciplina} = Disciplina.by_id(assigns.disciplina_id)
      matriculas = Enum.map(assigns.matriculas, &Repo.preload(&1, :disciplina))
      matriculado = matriculado?(assigns.matriculas, disciplina)

      assigns
      |> Map.put(:estudante, estudante)
      |> Map.put(:matriculas, matriculas)
      |> Map.put(:matriculado, matriculado)
      |> Map.put(:horario, horario)
      |> Map.put(:disciplina, Repo.preload(disciplina, :turmas))
    end)
  end

  def matriculado?(matriculas, disciplina) do
    disciplina.id in for(turma <- matriculas, do: turma.disciplina_id)
  end

  defp apply_action(action, socket, disciplina_id, turma_numero) do
    {:ok, estudante} = Estudante.by_id(socket.assigns.estudante_id)
    {:ok, disciplina} = Disciplina.by_id(disciplina_id, preload: :turmas)

    func =
      case action do
        :add ->
          &Disciplina.matricular_estudante/3

        :troca ->
          &Disciplina.troca_estudante/3

        :remove ->
          &Disciplina.desmatricular_estudante/3
      end

    case func.(disciplina, estudante, turma_numero) do
      {:ok, turma} ->

        matriculado = if action == :remove, do: false, else: true
        Phoenix.PubSub.broadcast(
          Sapiens.PubSub,
          "matricula",
          {:mat,
           %{
             sender: self(),
             disciplina_id: disciplina.id,
           }}
        )
        {:ok, disciplina} = Disciplina.by_id(disciplina_id, preload: :turmas)
        {:ok, horario} = Estudante.get_horarios(estudante)
        {:ok, matriculas} = Estudante.get_turmas_matriculado(estudante)

        send(self(), {:updated_horario, %{horario: horario}})

        socket
        |> assign(turma: turma)
        |> assign(disciplina: disciplina)
        |> assign(matriculas: matriculas)
        |> assign(matriculado: matriculado)

      _ ->
        IO.puts("Problemas na ação #{action}")
        socket
    end
  end
end
