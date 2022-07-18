defmodule Sapiens.Estudantes do
  import Ecto.Query, only: [from: 2], warn: false
  import Sapiens.Utils, warn: false

  alias Sapiens.Cursos.{
          Estudante,
          Professor,
          Curso,
          Disciplina,
          Enem,
          Historico,
          Turma,
          Status
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

  def get_historico(estudante, disciplina, ano \\ ano_atual(), semestre \\ semestre_atual()) do
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

  def get_avaliacoes(estudante, disciplina, ano, semestre) do
    {:ok, historico} = get_historico(estudante, disciplina, ano, semestre)
    historico.notas
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
    {:ok, build_horario(turmas)}
  end

  def build_horario(turmas) do
    Enum.reduce(
      turmas,
      %{},
      fn turma, horarios ->
        Enum.reduce(
          Sapiens.Turmas.get_horarios(turma),
          horarios,
          fn {key, value}, acc -> Map.put(acc, key, value) end
        )
      end
    )
  end

  def get_status(estudante, turma) do
    turma = turma |> Repo.preload(:disciplina)
    {:ok, historico} = get_historico(estudante, turma.disciplina)
    notas = historico.notas || %{}
    numer_of_testes = notas |> Map.keys() |> Enum.count() 
    nota_final = div(Enum.reduce(notas, 0, fn {_nome, body}, acc ->
       body["nota"] + acc
    end), if(numer_of_testes == 0, do: 1, else: numer_of_testes))
    conceito = 
      if (historico.turma_teorica > 15) do
      "L"
      else
        if (historico.nota > 0) do
          Decimal.div(Decimal.add(historico.nota, nota_final), 2) |> Decimal.to_string()
        else
          nota_final |> Integer.to_string()
        end
      end
    %Sapiens.Cursos.Status{
      nome: estudante.nome,
      matricula: estudante.matricula,
      provas: notas,
      ft: historico.turma_teorica,
      fp: 0,
      nf: nota_final,
      ef: historico.nota |> Decimal.to_integer(),
      conceito: conceito
    }
  end

  def update_status(%Sapiens.Cursos.Status{} = status) do

    provas = status.provas || %{}
    numer_of_testes = provas |> Map.keys() |> Enum.count() 
    nota_final = div(Enum.reduce(provas, 0, fn {_nome, body}, acc ->
       body["nota"] + acc
    end), if(numer_of_testes == 0, do: 1, else: numer_of_testes))
    conceito = if (status.ft > 15) do
      "L"
    else
      if (status.ef > 0) do
        Decimal.div(Decimal.add(status.ef, nota_final), 2) |> Decimal.to_string()
      else
        nota_final |> Integer.to_string()
      end
    end
    %Sapiens.Cursos.Status{
      status |
      nf: nota_final,
      conceito: conceito
    }
  end


  def change_status(%Sapiens.Cursos.Status{} = status, attrs \\ %{}) do
    Sapiens.Cursos.Status.changeset(status, attrs)
  end
end
