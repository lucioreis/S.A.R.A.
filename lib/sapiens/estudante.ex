defmodule Sapiens.Estudante do
  import Ecto.Query, only: [from: 2], warn: false
  import Sapiens.Utils, warn: false

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
    iex> by_id(1)
    {:ok,
      %Estudante{
        id: 1
        ...
      }
    }
  """
  def by_id(id) do
    case Repo.get_by(Estudante, id: id) do
      nil -> {:error, "Estudante com id: #{id} não encontrado!"}
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
  @spec get_disciplinas(Estudante.t()) :: {:error, String.t()} | {:ok, [[] | Disciplina]}
  def get_disciplinas(estudante) do
    {
      :ok,
      Repo.preload(estudante, :disciplinas).disciplinas
      |> Enum.map(fn disciplina -> Repo.preload(disciplina, :turmas) end)
    }
  end

  @doc """
  Retorna uma lista de turmas em que o estudante está matriculado

  ## Examples
    iex> get_turmas_matriculado(Estudante)
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
  @spec get_turmas_matriculado(Estudante.t()) :: {:error, String.T} | {:ok, [[] | Turma]}
  def get_turmas_matriculado(estudante) do
    estudante = estudante |> Repo.preload(:turmas)
    {:ok, estudante.turmas}
  end

  def add_disciplina(estudante, disciplina, ano \\ 0, semestre \\ nil) do
    semestre = semestre || semestre_atual()

    historico =
      Historico.changeset(
        %Historico{},
        %{
          ano: ano,
          conceito: "0",
          semestre: semestre,
          nota: 0,
          turma_pratica: 0,
          turma_teorica: 0
        }
      )
      |> Ecto.Changeset.put_assoc(:disciplina, disciplina)
      |> Ecto.Changeset.put_assoc(:estudante, estudante)

    case Repo.insert(historico) do
      {:ok, struct} -> {:ok, struct}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def remove_disciplina(estudante, disciplina, ano \\ 0, semestre \\ nil) do
    semestre = semestre || semestre_atual()

    case Repo.get_by(
           Historico,
           estudante_id: estudante.id,
           disciplina_id: disciplina.id,
           ano: ano,
           semestre: semestre
         ) do
      nil ->
        {:error, "Histórico não existe"}

      historico ->

        from(t in Sapiens.Cursos.Turma,
          join: et in Sapiens.Cursos.EstudanteTurma,
          on: et.turma_id == t.id,
          where: t.disciplina_id == ^disciplina.id,
          where: et.estudante_id == ^estudante.id
        )
        |> Repo.delete_all()

        case Repo.delete(historico) do
          {:ok, struct} -> {:ok, struct}
          {:error, changeset} -> {:error, changeset}
        end
    end
  end

  def get_historico(estudante, disciplina, ano \\ 0, semestre \\ 0) do
    semestre = if semestre == 0, do: semestre_atual(), else: semestre
    ano = if ano == 0, do: ano_atual(), else: ano

    case Repo.get_by(Historico,
           estudante_id: estudante.id,
           disciplina_id: disciplina.id,
           ano: ano,
           semestre: semestre
         ) do
      nil ->
        {:error,
         "Estudante com id=#{estudante.id} não possui histórico na disciplina com id=#{disciplina.id}"}

      historico ->
        {:ok, historico}
    end
  end

  @doc """
  Retorna os horarios de aula de um estudante
  %{
    {dia:[1-7], hora:[7-22]} => %{codigo: "XXX NNN", local: "XXX NNN"}
    dia => hora => %{codigo, local]
  %{"3" => [14, 15], "4" => [14, 15], "local" => "PVA 199"}
  """
  def get_horarios(estudante) do
    turmas = Enum.map(Repo.preload(estudante, :turmas).turmas, &Repo.preload(&1, :disciplina))

    {:ok,
     Enum.reduce(
       turmas,
       %{},
       fn turma, horarios ->
         Enum.reduce(
           Sapiens.Turma.get_horarios(turma),
           horarios,
           fn {key, value}, acc -> Map.put(acc, key, value) end
         )
       end
     )}
  end
end
