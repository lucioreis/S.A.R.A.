defmodule Sapiens.Alteracoes do
  use Agent
  alias Sapiens.Acerto
  alias Sapiens.Estudantes
  alias Sapiens.Turmas

  @moduledoc """
  Define um estrutura para armazenar alterações feitas no acerto de matricúla.

  %Alterações{
    pid: Pid do processo alterando a matrcúla
    author: Quem está alterando a Matricula
        {%Estudante{}, %Professor}
    time: Tempo que foi feita a alteração
    action: Qual a ação %{remove: [%Turma{}], add: [%Turmas{}]
    old: Estado antigo que devem ser alterados 
          %{  
            disciplina: %Disciplina{},
            turma: %Turma{}
          }
    target: Estado novo no lugar dos antigos %{%estudante{}, %Disciplina{}, %Turma{}}
  %}
  """
  defmodule Request do
    defstruct client: nil, author: nil, action: nil, disciplina: nil, time: nil, turma: nil
  end

  defmodule Response do
    defstruct server: nil,
              author: nil,
              disciplinas: nil,
              matriculas: [],
              horario: %{},
              collisions: %{},
              errors: [],
              commited: false,
              included: [],
              removed: []
  end

  defmodule State do
    defstruct server: nil,
              client: nil,
              author: nil,
              disciplinas: [],
              matriculas: [],
              included: [],
              removed: [],
              horario: nil,
              collisions: nil,
              commited: false
  end

  # CACHE API
  defp table(), do: table(5)
  defp table(0), do: {:error, "Errrou"}

  defp table(n) do
    case Registry.lookup(Registry.Acerto, :cache) do
      [] ->
        case Registry.register(
               Registry.Acerto,
               :cache,
               :ets.new(:cache, [:set, :public, read_concurrency: true, write_concurrency: true])
             ) do
          {:ok, _} -> table(n - 1)
          {:error, {_, ref}} -> ref
        end

      [{_, ref}] ->
        ref
    end
  end

  def build_state(server) do
    state = %State{server: server}

    Task.async(fn -> :ets.insert(table(), {server, state}) end)
    |> Task.await()

    state
  end

  def get_state(server) do
    case :ets.lookup(table(), server) do
      [] -> build_state(server)
      [{_key, state}] -> state
    end
  end

  def get_state_and_sync(server, estudante) do
    case :ets.lookup(table(), server) do
      [] ->
        sync_state(estudante)
        |> set_state()

      [{_key, state}] ->
        state
    end
  end

  defp set_state(state) do
    :ets.insert(table(), {state.server, state})
    state
  end

  def update_state(state, req \\ nil) do
    {included, removed} =
      if req != nil do
        changes(state, req)
      else
        {state.included, state.removed}
      end

    %State{
      server: state.server,
      author: if(req == nil, do: state.author, else: req.author),
      disciplinas: state.disciplinas,
      matriculas: state.matriculas,
      horario: Estudantes.build_horario(state.matriculas),
      commited: false,
      included: included,
      removed: removed
    }
  end

  defp changes(state, req) do
    case req.action do
      :add ->
        Sapiens.Queue.change_vagas({req.disciplina.id, req.turma.id}, -1)
        removed = Enum.filter(state.removed, &(&1.id != req.turma.id))
        included = Enum.filter(state.included, &(&1.id != req.turma.id)) ++ [req.turma]
        {included, removed}

      :remove ->
        removed = Enum.filter(state.removed, &(&1.id != req.turma.id)) ++ [req.turma]
        included = Enum.filter(state.included, &(&1.id != req.turma.id))
        {included, removed}

      :change ->
        Sapiens.Queue.change_vagas({req.disciplina.id, req.turma.id}, -1)

        removed =
          Enum.filter(state.removed, &(&1.id != req.turma.id)) ++
            Enum.filter(state.included, &(&1.disciplina_id == req.turma.disciplina_id))

        included = Enum.filter(state.included, &(&1.id != req.turma.id)) ++ [req.turma]
        {included, removed}

      :undo ->
        removed = Enum.filter(state.removed, &(&1.disciplina_id != req.turma.disciplina_id))
        included = Enum.filter(state.included, &(&1.disciplina_id != req.turma.disciplina_id))
        s = length(state.included) - length(included)
        r = length(state.removed) - length(removed)
        Sapiens.Queue.change_vagas({req.disciplina.id, req.turma.id}, s - r)
        {included, removed}
    end
  end

  defp sync_state(estudante) do
    {:ok, disciplinas} = Estudantes.get_disciplinas(estudante)
    {:ok, matriculas} = Estudantes.get_turmas_matriculado(estudante)
    {:ok, horario} = Estudantes.get_horarios(estudante)
    matriculas = Turmas.preload_all(matriculas, :disciplina)
    {:ok, server} = start_link(estudante.id)

    %State{
      server: server,
      author: estudante,
      disciplinas: disciplinas,
      matriculas: matriculas,
      included: [],
      removed: [],
      horario: horario,
      commited: true
    }
  end

  def undo(server, disciplina_id) do
    case Agent.get(server, fn reqs -> Map.get(reqs, disciplina_id) end) do
      nil ->
        sync_state(get_state(server).author) |> set_state()

      req ->
        Agent.update(server, fn reqs -> Map.delete(reqs, disciplina_id) end)

        server
        |> get_state()
        |> update_state(%Request{req | action: :undo})
        |> set_state()
        |> respond()
    end
  end

  defp respond(state) do
    IO.inspect(length(state.matriculas), label: "MATriculas")

    matriculas = calc_mats(state, state.included, state.removed)
    horario = Estudantes.build_horario(matriculas)

    %Response{
      server: state.server,
      author: state.author,
      matriculas: matriculas,
      horario: horario,
      collisions: state.collisions,
      errors: [],
      commited: state.commited,
      included: state.included,
      removed: state.removed
    }
  end

  # Requests API
  def start_link(id) do
    caso = Task.async(fn -> Registry.lookup(Registry.Acerto, id) end)
    caso = Task.await(caso)

    case caso do
      [] ->
        name = {:via, Registry, {Registry.Acerto, id}}
        Agent.start_link(fn -> %{} end, name: name)

      [{pid, _}] ->
        {:ok, pid}
    end
  end

  def push(server, req) do
    Agent.update(server, fn reqs ->
      Map.put(reqs, req.disciplina.id, req)
    end)

    server
    |> get_state()
    |> update_state(req)
    |> set_state()
    |> respond()
  end

  defp calc_mats(state, included, removed) do
    (state.matriculas -- removed) ++ included

    # matriculas = Enum.reject(state.matriculas, fn turma -> turma.id in for(t <- state.removed, do: t) e  
    # matriculas ++ state.included
  end

  # defp mats(state) do
  #   state =
  #     case get_all(state.server) do
  #       [] ->
  #         %State{state | commited: true}
  #
  #       reqs ->
  #         Enum.reduce(reqs, state, &Sapiens.Alteracoes.update_state(&2, &1))
  #     end
  #
  #   matriculas = Turmas.preload_all(state.matriculas, :disciplina)
  #   {:ok, horario} = Estudantes.build_horario(matriculas)
  #   set_state(%State{state | matriculas: matriculas, horario: horario})
  # end

  def load(estudante) do
    {:ok, server} = start_link(estudante.id)

    server
    |> get_state_and_sync(estudante)
    |> update_state()
    |> respond()
  end

  def get_all(server) do
    Enum.reduce(Agent.get(server, & &1), [], fn {_disciplina_id, req}, acc ->
      [req | acc]
    end)
  end

  def is_clean(server, disciplina_id) do
    state = get_state(server)

    Enum.empty?(
      Enum.filter(state.included ++ state.removed, fn turma ->
        turma.disciplina_id == disciplina_id
      end)
    )
  end

  def clean(server) do
    Agent.update(server, fn _state -> %{} end)
  end

  def stop(server) do
    Agent.stop(server)
  end

  def commit(server) do
    alt_list = get_all(server)

    results =
      Enum.map(alt_list, fn alt ->
        case alt.action do
          :change ->
            Acerto.troca(alt.author, alt.turma)

          :add ->
            Acerto.adiciona(alt.author, alt.turma)

          :remove ->
            Acerto.remove(alt.author, alt.turma)
        end
      end)

    if results != [] do
      sync_state(hd(alt_list).author)
    end

    clean(server)
    results
  end
end
