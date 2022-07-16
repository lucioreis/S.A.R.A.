defmodule Sapiens.Historicos do
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
    case Repo.get_by(Hitorico, id: id) do
      nil -> {:error, "Disciplina não encontrada: id=#{id}"}
      historico -> {:ok, historico}
    end
  end

  def create_teste(turma, {tipo, teste}) do
    ano_atual = Sapiens.Utils.ano_atual()
    semestre_atual = Sapiens.Utils.semestre_atual()
    turma = Repo.preload(turma, [:estudantes, :disciplina])

    historicos =
      for estudante <- turma.estudantes do
        Repo.get_by(
          Historico,
          ano: ano_atual,
          semestre: semestre_atual,
          disciplina_id: turma.disciplina.id,
          estudante_id: estudante.id
        )
      end

    for historico <- historicos do
      historico
      |> Ecto.Changeset.change(%{
        notas: Map.put(if(historico.notas, do: historico.notas, else: %{}), tipo, teste)
      })
      |> Repo.update!()
    end
  end

  def get_grades(estudante, turma) do
    ano_atual = Sapiens.Utils.ano_atual()
    semestre_atual = Sapiens.Utils.semestre_atual()
    turma = Repo.preload(turma, :disciplina)

    Repo.get_by(Historico,
      ano: ano_atual,
      semestre: semestre_atual,
      disciplina_id: turma.disciplina_id,
      estudante_id: estudante.id
    )
    |> Map.get(:notas)
    |> case do
      nil -> %{}
      value -> value
    end
  end
end
