defmodule Sapiens.Turmas do
  import Ecto.Query, only: [from: 2], warn: false

  alias Sapiens.Cursos.{
          Estudante,
          Professor,
          Curso,
          Disciplina,
          Enem,
          Historico,
          Turma
        },
        warn: false

  alias Sapiens.Repo, warn: false

  @doc"""
  Retorna turma pelo seu id, retorna {:ok, %Turma{}} ou {:error, razão}

  ## Examples
    ```
    iex>Turma.by_id(1)
    {:ok, %Turma{id: 1, ...}
    ```

  """
  def by_id(id) do
    case Repo.get_by(Turma, id: id) do
      nil ->
        {:error, "Turma não encontrada: id=#{id}"}

      turma ->
        {:ok, turma}
    end
  end

  @doc """
  Retorna por uma lista de vqlores
  ## Examples
    ```
    iex>Turma.get_by([:key1, :key2])
    {ok, Turma}
    
    iex>Turma.get_by([:chave_que_nâo_existe])
    {:error, "Turma não encontrada"}
    ```
  """
  def get_by(list_of_keys) do
    case Repo.get_by(Turma, list_of_keys) do
      nil -> {:error, "Turma não encontrada"}
      turma -> {:ok, turma}
    end
  end

  @doc """
  Retorna o horário da turma no formato %{{dia, hora}=>%{local: XXX, codigo: XXX}}
  """
  def get_horarios(turma) do
    turma.horario
    |> Enum.reduce(%{}, fn {<<dia, hora>>, value}, acc -> Map.put_new(acc, {dia, hora}, value) end)
  end

  @doc """
  Retorna uma lista de todos os estudantes
  ## Examples
    iex>Turma.get_all_estudantes(%Turma{})
    [
      %Estudante{},
      ...
    ]
  """
  def get_all_estudantes(turma) do
    turma = Repo.preload(turma, :estudantes)
    {:ok, turma.estudantes}
  end

  @doc """
  Busca campo(field) no banco de dados de uma lista de turma.
  ## Examples
    iex>Turmas.preload_all([%Turma{}], :discplina)
    [
      %Turma{disciplina: %Disciplina{}},
      ...
    ]
  """
  def preload_all(turmas, field) do
    Enum.map(turmas, &Repo.preload(&1, field))
  end

  @doc """
  Busca um campo de ums turma no banco de dados
  """
  def preload(turma, field) do
    Repo.preload(turma, field)
  end

  @doc """
  Cria uma avalição para uma turma, avaliação deve conter um nome("P1", "P2", "T1", etc.)
  local, nota(quanto vale a avaliação), date quando será a avaliação, hora e ordem se ela
  é a primeira ou segunda prova.
  """
  def create_avaliacao(
        turma,
        %{"nome" => nome, "local" => _, "nota" => _, "date" => _, "hora" => _, "ordem" => _} =
          teste
      ) do
    case Sapiens.Cursos.Turma.changeset(
           turma,
           %{
             provas:
               Map.put(
                 if(turma.provas == nil, do: %{}, else: turma.provas),
                 nome,
                 teste
               )
           }
         )
         |> Repo.update() do
      {:ok, turma} ->
        sync_estudantes(turma)
        {:ok, turma}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Sincroniza os estudates de uma turma com o banco de dados.
  Esta funcção coloca as avaçiações criadas pelos professores no histórico de cada aluno
  """
  def sync_estudantes(turma) do
    turma = Repo.preload(turma, [:estudantes, :disciplina])

    case turma.provas do
      nil ->
        Enum.map(
          turma.estudantes,
          fn estudante ->
            case Sapiens.Estudantes.get_historico(estudante, turma.disciplina) do
              {:ok, historico} ->
                Sapiens.Cursos.Estudante.changeset(historico, %{notas: %{}, nota: 0})
                |> Repo.update()

              msg ->
                {:err, msg}
            end
          end
        )

      provas ->
        Enum.map(
          turma.estudantes,
          fn estudante ->
            {:ok, historico} = Sapiens.Estudantes.get_historico(estudante, turma.disciplina)

            provas =
              Enum.reduce(
                provas,
                %{},
                fn {nome, prova}, acc ->
                  Map.put(acc, nome, %{prova | "nota" => 0})
                end
              )

            Sapiens.Cursos.Historico.changeset(historico, %{notas: provas, nota: 0, conceito: "0"})
            |> Repo.update()
          end
        )
    end
  end
end
