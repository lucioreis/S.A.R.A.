defmodule Sapiens.Queue do
  use GenServer
  alias Sapiens.Repo
  import Ecto.Query, only: [from: 2]
  alias Sapiens.Alteracoes.Request, warn: false
  alias Sapiens.Alteracoes.Response, warn: false
  alias Sapiens.Acerto

  ## Client API

  @doc """
  Starts the process
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    load_disciplinas()

    {
      :ok,
      %{}
    }
  end

  def disciplinas() do
    case Registry.lookup(Registry.Acerto, :disciplinas) do
      [] ->
        {:ok, pid} = Agent.start_link(fn -> %{} end)
        Registry.register(Registry.Acerto, :disciplinas, pid)
        pid

      [{_pid, pid}] ->
        pid
    end
  end

  def load_disciplinas() do
    disciplinas =
      Repo.all(Sapiens.Cursos.Disciplina)
      |> Repo.preload(:turmas)

    for disciplina <- disciplinas, turma <- disciplina.turmas do
      Agent.update(disciplinas(), fn state ->
        Map.put_new(state, {disciplina.id, turma.id}, turma.vagas_disponiveis)
      end)
    end
  end

  def get_vagas({disciplina_id, turma_id})
      when is_integer(disciplina_id) and is_integer(turma_id) do
    Agent.get(disciplinas(), fn state -> Map.get(state, {disciplina_id, turma_id}) end)
  end

  def get_vagas(disciplina_id) do
    Enum.reduce(Agent.get(disciplinas(), & &1), %{}, fn {{d_id, t_id}, value}, acc ->
      if d_id == disciplina_id do
        Map.put_new(acc, {d_id, t_id}, value)
      else
        acc
      end
    end)
  end

  def set_vagas({disciplina_id, turma_id}, vagas) do
    Agent.update(disciplinas(), fn state -> %{state | {disciplina_id, turma_id} => vagas} end)
  end

  def change_vagas({disciplina_id, turma_id}, n) do
    Agent.update(disciplinas(), fn state ->
      %{state | {disciplina_id, turma_id} => state[{disciplina_id, turma_id}] + n}
    end)

    Phoenix.PubSub.broadcast(Sapiens.PubSub, "matricula", {:matricula, disciplina_id})
  end

  def list_vagas(agent) do
    Agent.get(agent, & &1)
  end

  def lnst_vagas() do
    list_vagas(:ets.first(disciplinas()))
  end

  def run(request) do
    case request.action do
      :add -> change_vagas({request.disciplina.id, request.turma.id}, -1)
      :change -> change_vagas({request.disciplina.id, request.turma.id}, -1)
      _ -> nil
    end
  end

  def reset() do
    GenServer.cast(Sapiens.Queue, {:reset})
  end

  @impl true
  def handle_call({:libera, request}, _refs, state) do
    # Acerto.libera_vaga(request.turma)
    {:ok, disciplina} = Sapiens.Disciplinas.by_id(request.turma.disciplina_id)

    Phoenix.PubSub.broadcast(
      Sapiens.PubSub,
      "matricula",
      {:matricula, %{disciplina: disciplina, turma: request.turma}}
    )

    key = {request.disciplina.id, request.turma.id}
    state = Map.update(state, key, [], fn reqs -> reqs -- [request] end)
    {:reply, state, state}
  end

  @impl true
  def handle_call({:reserva, %{request: request, sender: _sender}}, _ref, state) do
    # Acerto.reserva_vaga(request.turma)
    {:ok, disciplina} = Sapiens.Disciplinas.by_id(request.turma.disciplina_id)

    Phoenix.PubSub.broadcast(
      Sapiens.PubSub,
      "matricula",
      {:matricula, %{disciplina: disciplina, turma: request.turma}}
    )

    key = {request.disciplina.id, request.turma.id}
    state = Map.update(state, key, [request], fn reqs -> reqs ++ [request] end)

    {:reply, state, state}
  end

  @impl true
  def handle_call({:change, request}, _ref, state) do
    # Acerto.reserva_vaga(request.turma)
    {:ok, disciplina} = Sapiens.Disciplinas.by_id(request.turma.disciplina_id)

    Phoenix.PubSub.broadcast(
      Sapiens.PubSub,
      "matricula",
      {:matricula, %{disciplina: disciplina, turma: request.turma}}
    )

    key = {request.disciplina.id, request.turma.id}
    state = Map.update(state, key, [request], fn reqs -> reqs ++ [request] end)

    {:reply, state, state}
  end

  @impl true
  def handle_cast({:reset}, _state) do
    {:noreply, %{}}
  end
end
