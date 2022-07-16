defmodule Sapiens.Plano do
  import Ecto.Query, only: [from: 2], warn: false
  import Sapiens.Utils, warn: false

  @moduledoc """
  Define o comportamento entre usuários(Professor e Estudante) e Disciplina.
  Neste módulo devem estar as funcões que determinam os
  comportamentos entre Estudante e Disciplina Assim como Professor e Disciplina. 
  Como inclusão, exclusão ou aproveitamento de disciplina. No caso de Professor
  quais Professores lecionarão alguma turma na disciplina
  """

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

  @doc """
  Registra um estudante em uma disciplina.
  Ano 0 ou Semestre 0 são abreviações para o ano e semestre atual.
  Ou no caso da realização do plano de estudo, o ano e semestre subsequente ao
  da realização do plano de estudo.

  ## Examples
    # Em caso de sucesso
    iex>adicionar_estudante_disciplina(%Estudante{}, %Disciplina{})
    {:ok, %Disciplina{}}
    
    # Em caso de erro
    iex>adicionar_estudante_disciplina(%Estudante{}, %Disciplina{})
    {:error, %Ecto.Changeset{}}
  """
  def adiciona(estudante, disciplina, ano \\ nil, semestre \\ nil) do
    semestre = semestre || semestre_atual()
    ano = ano || ano_atual()

    historico =
      Historico.changeset(
        %Historico{},
        %{
          ano: ano,
          conceito: "0",
          semestre: semestre,
          nota: 0,
          notas: %{},
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

  @doc """
  Remove uma disciplina do plano de estudo.
  Disciplina que são prerequisitos ou correquisitos de outras disciplinas
  não podem ser excluídas antes das disciplinas dependentes.

  ## Examples
    # Em caso de sucesso.
    iex> remover_estudante_disciplina(%Estudante{}, %Disciplina{})
    {:ok, %Disciplina{}}

    # Em caso de erro
    iex> remover_estudante_disciplina(%Estudante{}, %Disciplina{})
    {:ok, %Ecto.Changeset{}}
  """
  def remove(estudante, disciplina, ano \\ 0, semestre \\ 0) do
    semestre = semestre || semestre_atual()
    ano = ano || ano_atual()

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

  @doc """
  Retorna true ou false se o estudante está registrado na disciplina.
  Ano 0 ou Semestre 0 são abreviações para o ano e semestre atual.
  Ou no caso da realização do plano de estudo, o ano e semestre subsequente ao
  da realização do plano de estudo.

  ## Examples
    iex>Plano.estudante_inscrito_discplina(%Estudante{}, %Disciplina{})
    false
    
    iex>Plano.estudante_inscrito_discplina(%Estudante{}, %Disciplina{})
    true
  """
  def inscrito?(estudante, disciplina, ano \\ nil, semestre \\ nil) do
    ano = ano || ano_atual()
    semestre = semestre || semestre_atual()

    case Repo.get_by(Historico,
           disciplina_id: disciplina.id,
           estudante_id: estudante.id,
           ano: ano,
           semestre: semestre
         ) do
      nil -> false
      _value -> true
    end
  end

  @doc """
  Faz a validação dos co-requisitos(Disciplinas que devem ser feitas antes ou em conjunto)
  Retorna {:ok, disciplina} ou {:error, lista_de_correqusitos}

  ## Examples 
    #Em caso de sucesso
    iex>Plano.validar_co_requisitos(%Estudante{}, %Disciplina{})
    {:ok, %Disciplina{}}

    # Em caso de erro
    iex>Plano.validar_co_requisitos(%Estudante{}, %Disciplina{})
    {:error, [%Disciplina{}]}
  """
  @spec validar_co_requisitos(Estudante.t(), Disciplina.t()) ::
          {:ok, Disciplina.t()} | {:error, [Disciplina.t()]}
  def validar_co_requisitos(estudante, disciplina) do
    {:ok, disciplina}
  end

  @doc """
  Faz a validação dos pre-requisitos(Disciplinas que devem ser feitas antes)
  Retorna {:ok, %Disciplina{}} ou {:error, lista_de_pre-requsitos}

  ## Examples 
    #Em caso de sucesso
    iex>Plano.validar_pre_requisitos(%Estudante{}, %Disciplina{})
    {:ok, %Disciplina{}}

    # Em caso de erro
    iex>Plano.validar_pre_requisitos(%Estudante{}, %Disciplina{})
    {:error, [%Disciplina{}]}
  """
  @spec validar_pre_requisitos(Estudante.t(), Disciplina.t()) ::
          {:ok, Disciplina.t()} | {:error, [Disciplina.t()]}
  def validar_pre_requisitos(estudante, disciplina) do
    {:ok, disciplina}
  end
end
