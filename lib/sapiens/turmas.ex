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

  def by_id(id) do
    case Repo.get_by(Turma, id: id) do
      nil ->
        {:error, "Turma não encontrada: id=#{id}"}

      turma ->
        {:ok, turma}
    end
  end

  def get_by(list_of_keys) do
    case Repo.get_by(Turma, list_of_keys) do
      nil -> {:error, "Turma não encontrada"}
      turma -> {:ok, turma}
    end
  end

  def get_horarios(turma) do
    turma.horario
    |> Enum.reduce(%{}, fn {<<dia, hora>>, value}, acc -> Map.put_new(acc, {dia, hora}, value) end)
  end

  def get_all_estudantes(turma) do
    turma = Repo.preload(turma, :estudantes)
    {:ok, turma.estudantes}
  end

  def preload_all(turmas, field) do
    Enum.map(turmas, &Repo.preload(&1, field))
  end

  def preload(turma, field) do
    Repo.preload(turma, field)
  end

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
