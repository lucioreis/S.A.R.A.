defmodule Sapiens.Alteracoes do
  use Agent
  alias Sapiens.Acerto

  @moduledoc """
  Define um estrutura para armazenar alterações feitas no acerto de matricúla.

  %Alterações{
    pid: Pid do processo alterando a matrcúla
    author: Quem está alterando a Matricula
        {%Estudante{}, %Professor}
    time: Tempo que foi feita a alteração
    action: Qual a ação :remove, :add, :change
    old: Estado antigo que devem ser alterados 
          %{  
            disciplina: %Disciplina{},
            turma: %Turma{}
          }
    target: Estado novo no lugar dos antigos %{%estudante{}, %Disciplina{}, %Turma{}}
  %}
  """
  defstruct pid: nil, author: nil, time: nil, action: nil, old: nil, target: nil
  
  def start_link(author) do
    case Registry.lookup(Registry.Acerto, author.id) do
        [] -> 
          name = {:via, Registry, {Registry.Acerto, author.id}}
          Agent.start_link(fn -> [] end, name: name)
        [{pid, _}] -> {:ok, pid}
    end
  end

  def push(alteracoes, alteracao) do
    Agent.update(alteracoes, fn state -> state ++ [alteracao] end)
  end

  def get(alteracoes) do
    Agent.get(alteracoes, & &1)
  end

  def pop(alteracoes) do
    popped = Agent.get(alteracoes, &(List.pop_at(&1, length(&1)-1))) 
    Agent.update(alteracoes, fn state -> List.delete_at(state, length(state) - 1) end)
    popped
  end

  def clean(alteracoes) do
    Agent.update(alteracoes, fn _state -> [] end)
  end

  def stop(alteracoes) do
    Agent.stop(alteracoes)
  end

  def commit(alteracoes) do
    Agent.get(alteracoes, & &1)
    |> Enum.map(fn alt ->
      case alt.action do
        :add ->
          send(
            alt.pid,
            add: :added #Acerto.adiciona(alt.author, alt.target)
          )

        :remove ->
          send(
            alt.pid,
            remove: :removed #Acerto.remove(alt.author, alt.old)
          )

        :troca ->
          send(
            alt.pid,
            change: :changed #Acerto.troca(alt.author, alt.target)
          )
      end
    end)

    Agent.update(alteracoes, fn _state -> %{} end)
  end
end
