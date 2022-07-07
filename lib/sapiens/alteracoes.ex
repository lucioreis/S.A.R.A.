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
              commited: false
  end

  defmodule State do
    defstruct server: nil,
              client: nil,
              author: nil,
              disciplinas: [],
              matriculas: [],
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
        case Registry.register(Registry.Acerto, :cache, :ets.new(:cache, [:set])) do
          {:ok, _} -> table(n - 1)
          {:error, {_, ref}} -> ref
        end

      [{_, ref}] ->
        ref
    end
  end

  defp get_state(estudante) do
    {:ok, server} = start_link(estudante.id)
    get_state(server, estudante)
  end

  defp get_state(server, estudante) do
    case :ets.lookup(table(), server) do
      [] ->
        sync_state(estudante)

      [{_key, state}] ->
        state
    end
  end

  defp set_state(server, state) do
    :ets.insert(table(), {server, %State{state | server: server}})
    state
  end

  defp sync_state(estudante) do
    {:ok, disciplinas} = Estudantes.get_disciplinas(estudante)
    {:ok, matriculas} = Estudantes.get_turmas_matriculado(estudante)
    {:ok, horario} = Estudantes.get_horarios(estudante)
    matriculas = Turmas.preload_all(matriculas, :disciplina)
    {:ok, server} = start_link(estudante.id)

    set_state(
      server,
      %State{
        server: server,
        author: estudante,
        disciplinas: disciplinas,
        matriculas: matriculas,
        horario: horario,
        commited: true
      }
    )
  end

  def undo(server, disciplina_id) do
    Map.delete(Agent.get(server, & &1), disciplina_id)
  end

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

    load(req.author)
  end

  defp mats(state) do
    {:ok, server} = start_link(state.author.id)

    state =
      case get_all(server) do
        [] ->
          state

        reqs ->
          matriculas =
            Enum.reduce(reqs, state.matriculas, fn req, acc ->
              case req.action do
                :add ->
                  acc ++ [req.turma]

                :remove ->
                  acc -- [req.turma]

                :change ->
                  Enum.filter(state.matriculas, fn turma ->
                    turma.disciplina_id != req.turma.disciplina_id
                  end) ++
                    [req.turma]
              end
            end)

          %State{state | matriculas: matriculas}
      end

    matriculas = Turmas.preload_all(state.matriculas, :disciplina)
    {:ok, horario} = Estudantes.build_horario(matriculas)
    set_state(server, %State{state | matriculas: matriculas, horario: horario})
  end

  def load(estudante) do
    {:ok, server} = start_link(estudante.id)

    state =
      server
      |> get_state(estudante)
      |> mats()

    %Response{
      server: state.server,
      author: state.author,
      matriculas: state.matriculas,
      horario: state.horario,
      collisions: state.collisions,
      errors: [],
      commited: state.commited
    }
  end

  def get_all(server) do
    Enum.reduce(Agent.get(server, & &1), [], fn {_disciplina_id, req}, acc ->
      [req | acc]
    end)
  end

  def is_clean(server, disciplina_id) do
    case Map.get(Agent.get(server, & &1), disciplina_id) do
      [] -> true
      nil -> true
      _ -> false
    end
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
