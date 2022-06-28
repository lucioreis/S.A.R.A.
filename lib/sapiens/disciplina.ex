defmodule Sapiens.Disciplina do
  import Ecto.Query, only: [from: 2], warn: false
  import Sapiens.Utils

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
  

  @spec by_id(integer, [{atom, atom}]) :: {:ok, Sapiens.Cursos.Disciplina.t()} | {:error, any()}
  def by_id(id, preload_fields) do
    case by_id(id) do
      {:error, msg} ->
        {:error, msg}

      {:ok, disciplina} ->
        {:ok,
         Enum.reduce(preload_fields, disciplina, fn {:preload, field}, acc ->
           case Repo.preload(disciplina, field) do
             nil -> acc
             value -> value
           end
         end)}
    end
  end

  def by_id(id) do
    case Repo.get_by(Disciplina, id: id) do
      nil -> {:error, "Disciplina não encontrada: id=#{id}"}
      disciplina -> {:ok, disciplina}
    end
  end

  def get_turmas(disciplina) do
    {:ok, Repo.preload(disciplina, :turmas).turmas}
  end

  def get_turma_by_numero(disciplina, numero) do
    case Repo.get_by(Turma, disciplina_id: disciplina.id, numero: numero) do
      nil -> {:error, "Turma numero: #{numero} não existe."}
      turma -> {:ok, turma}
    end
  end

  def estudante_inscrito?(disciplina, estudante) do
    case Repo.get_by(Historico,
           disciplina_id: disciplina.id,
           estudante_id: estudante.id,
           ano: ano_atual(),
           semestre: semestre_atual()
         ) do
      nil -> false
      _value -> true
    end
  end

  # from(u in User, update: [inc: [failed_login_tries: 1]], where: u.id == user.id) )
  @spec matricular_estudante(Disciplina.t(), Estudante.t(), Integer.t()) ::
          {:ok, Turma.t()} | {:error, String.t()}
  def matricular_estudante(disciplina, estudante, numero_turma) do
    case get_turma_by_numero(disciplina, numero_turma) do
      {:error, msg} ->
        {:error, msg}

      {:ok, turma} ->
        if turma.vagas_disponiveis > 0 do
          Sapiens.Turma.adiciona_estudante(turma, estudante)
        else
          {:error, "Vagas esgotadas"}
        end
    end
  end

  def desmatricular_estudante(disciplina, estudante, numero_turma) do
    case get_turma_by_numero(disciplina, numero_turma) do
      {:error, msg} ->
        {:error, msg}

      {:ok, turma} ->
        Sapiens.Turma.remove_estudante(turma, estudante)
    end
  end


  def troca_estudante(disciplina, estudante, nova_turma_numero) do
    case Repo.get_by(Sapiens.Cursos.EstudanteTurma,
           estudante_id: estudante.id,
           disciplina_id: disciplina.id
         ) do
      nil ->
        {:error, "Estudante não está na turma"}

      estudante_turma ->
        case Repo.get_by(Sapiens.Cursos.Turma, id: estudante_turma.turma_id) do
          nil ->
            {:error, "Há uma inconsistencia no banco de dados"}

          old_turma ->
            case Repo.get_by(Sapiens.Cursos.Turma, numero: nova_turma_numero, disciplina_id: disciplina.id) do
              nil ->
                {:erro, "Nova Turma não existe"}

              nova_turma ->
                Sapiens.Turma.remove_estudante(old_turma, estudante)
                Sapiens.Turma.adiciona_estudante(nova_turma, estudante)
                {:ok, nova_turma}
            end
        end
    end
  end
end
