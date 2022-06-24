defmodule Sapiens.Estudante do
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

  alias Sapiens.Repo

  @doc """
  List all entries of same type as `struct`
  @params: `struct` define the struct to search
  @params: `opts`, the fields to select 
  ## Examples
    iex> list_all(%Estudante)
    [%Estudante{
      name: "Joao"
      ...
    },
    %Estudante{
      name: "Marcos"
      ...
    %}]
  """
  def list_all(struct, opts \\ []) do
    Repo.all(struct, opts)
  end

  def list_estudantes do
    Repo.all(Estudante)
  end

  # lits all
  #  estudantes
  #  disciplinas
  #  
  @doc """
  Pega o estudante pelo seu id
  ## Examples
    iex> get_by_id(1)
    {:ok,
      %Estudante{
        id: 1
        ...
      }
    }
  """
  @spec get_by_id(:integer) :: {:ok, Estudante} | {:error, String.t()}
  def get_by_id(id) do
    case Repo.get_by(Estudante, id: id) do
      nil -> {:error, "Estudante não encontrado!"}
      estudante -> {:ok, estudante}
    end
  end

  @doc """
  Retorna as diciplinas em que um estudante está matriculado

  ## Examples
    iex> get_disciplinas(1)
    {:ok,
      [
        %Disciplina{
          codigo: "INF321"
          ...
        },
        %Disciplina{
          codigo: "INF123"
          ...
        }
      ]
    }
  """
  @spec get_disciplinas(integer) :: {:error, String.t()} | {:ok, [[] | Disciplina]}
  def get_disciplinas(id) do
    case Repo.get_by(Estudante, id: id) do
      nil ->
        {:error, "Estudante com id: #{id} não encontrado!"}

      estudante ->
        {:ok,
         Repo.preload(estudante, :disciplinas).disciplinas
         |> Enum.map(fn disciplina -> Repo.preload(disciplina, :turmas) end)}
    end
  end

  @doc """
  Retorna uma lista de turmas em que o estudante está matriculado

  ## Examples
    iex> get_turmas_matriculado(1)
    [
      %Turma{
        horario: %{2 => [10,11]}
        numero: 3,
        tipo: "teorica" 
        vagas_preenchidas: 36,
        vagas_disponiveis: 14,
        estudantes: Sapiens.Cursos.Estudante
        disciplina: Sapiens.Cursos.Disciplina
        professor: Sapiens.Cursos.Professor
      }
    ]
      
  """
  @spec get_turmas(integer) :: {:error, String.T} | {:ok, [[] | Turma]}
  def get_turmas(id) when is_integer(id) do
    case Repo.get_by(Estudante, id: id) do
      nil ->
        {:error, "Estudante com id: #{id} não encontrado!"}

      estudante ->
        estudante = estudante |> Repo.preload(:turmas)
        {:ok, estudante.turmas}
    end
  end

  @doc """
  Registra o estudante em uma turma

  ## Examples 
    iex>Estudante.set_turma(id_estudante, %Turma{numero: 1, disciplina: %Disciplina{codigo: "INF 321"}})
    {:ok, %Estudante{}}
  """
  # @spec set_turma(:integer, Turma) :: {:ok, String.t}|{:error, String.t}
  def set_turma(id_estudante, %Turma{} = turma) do
    case get_by_id(id_estudante) do
      {:ok, estudante} ->
        change =
          turma
          |> Repo.preload([:estudantes, :disciplina, :professor])
          |> Ecto.Changeset.change()
          |> Ecto.Changeset.put_assoc(:estudantes, turma.estudantes ++ [estudante])

        case Repo.update(change) do
          {:ok, struct} -> {:ok, struct}
          {:error, changeset} -> {:error, changeset}
        end

      {:error, msg} ->
        {:error, msg}
    end
  end

  def set_turma(id_estudante, turma_id) do
    turma =
      Turma
      |> Repo.get_by(id: turma_id)
      |> Repo.preload(:estudantes)

    set_turma(id_estudante, turma)
  end

  def unset_turma(id_estudante, turma_id) when turma_id |> is_integer do
    case Repo.get_by(Sapiens.Cursos.EstudanteTurma, estudante_id: id_estudante, turma_id: turma_id) do
      nil ->
        {:error, "Relation between Student and Class doesn't exist!"}

      estudante_turma ->
        case Repo.delete(estudante_turma) do
          {:ok, _} -> {:ok, "Realtion deleted"}
          {:error, msg} -> {:error, msg}
        end
    end
  end

  def set_historico(estudante, turma) do
    turma = turma |> Repo.preload(:disciplina)

    historico =
      %Historico{}
      |> Ecto.Changeset.change(%{
        ano: 0,
        conceito: "0",
        semestre: 1,
        nota: 0,
        turma_pratica: 0,
        turma_teorica: 0
      })
      |> Ecto.Changeset.put_assoc(:disciplina, turma.disciplina)
      |> Ecto.Changeset.put_assoc(:estudante, estudante)

    case Repo.insert(historico) do
      {:ok, struct} -> {:ok, struct}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def unset_historico(estudante_id, disciplina_id, ano, semestre) do
    case Repo.get_by(
           Historico,
           estudante_id: estudante_id,
           disciplina_id: disciplina_id,
           ano: ano,
           semestre: semestre
         ) do
      nil ->
        {:error, "Histórico não existe"}

      historico ->
        case Repo.delete(historico) do
          {:ok, struct} -> {:ok, struct}
          {:error, changeset} -> {:error, changeset}
        end
    end
  end

  @doc """
  Retorna os horarios de aula de um estudante
  %{
    {dia:[1-7], hora:[7-22]} => %{codigo: "XXX NNN", local: "XXX NNN"}
    dia => hora => %{codigo, local]
  }
  """
  def get_horarios(id_estudante) do
    case get_turmas(id_estudante) do
      {:ok, turmas} ->
        horarios =
          for turma <- turmas do
            turma = Repo.preload(turma, :disciplina)
            turma.horario
          end

        {
          :ok,
          Enum.reduce(horarios, %{}, fn elem, acc ->
            Enum.reduce(elem, acc, fn {key, value}, acc ->
              <<dia, hora>> = key
              Map.put_new(acc, {dia, hora}, %{codigo: value["codigo"], local: value["local"]})
            end)
          end)
        }

      {:error, msg} ->
        {:error, msg}
    end
  end
end
