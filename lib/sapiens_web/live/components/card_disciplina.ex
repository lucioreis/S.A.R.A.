defmodule SapiensWeb.Components.CardDisciplina do
  use SapiensWeb, :live_component

  @impl true
  def mount(socket) do
    # socket = assign(socket, disciplina: gen_disciplina())

    {:ok, socket}
  end

  @impl true
  def handle_event("add", %{"numero" => numero, "codigo" => codigo}, socket) do

    {
      :noreply,
      add(socket, String.to_integer(numero), codigo)
    }
  end

  @impl true
  def handle_event("remove", %{"numero" => numero, "codigo"=> codigo}, socket) do

    {
      :noreply,
      remove(socket, String.to_integer(numero), codigo)
    }

  end

  @impl true
  def handle_event("change", %{"numero" => numero, "codigo" => codigo}, socket) do

    turma_atualmente_matriculada = socket.assigns.matriculas[codigo] 
    numero = numero |> String.to_integer
    {
      :noreply,
      socket
      |> remove(turma_atualmente_matriculada, codigo)
      |> add(numero, codigo)
    }
  end


  defp remove(socket, numero, codigo) do

    turmas = socket.assigns.disciplina.turmas
    turma = turmas[numero]
    turma = %{turma | vagas: turma.vagas + 1}

    turmas = %{turmas| numero => turma}

    disciplina = %{socket.assigns.disciplina | turmas: turmas}

    matriculas =
      socket.assigns.matriculas
      |> Map.delete(codigo)

      socket
      |> assign(matriculas: matriculas)
      |> assign(disciplina: disciplina)
  end

  defp add(socket, numero, codigo) do
    IO.inspect(socket.assigns.disciplina.turmas)
    turmas = socket.assigns.disciplina.turmas
    turma = turmas[numero]
    IO.inspect(turma)
    turma = %{turma | vagas: turma.vagas - 1}

    turmas = %{turmas| numero => turma}

    disciplina = %{socket.assigns.disciplina | turmas: turmas}

    matriculas =
      socket.assigns.matriculas
      |> Map.put(codigo, numero)

    socket
      |> assign(matriculas: matriculas)
      |> assign(disciplina: disciplina)
  end


  # @impl true
  # def update(_assigns, socket) do
  #   {:ok, socket}
  # end
end
