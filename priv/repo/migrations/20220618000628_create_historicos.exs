defmodule Sapiens.Repo.Migrations.CreateHistoricos do
  use Ecto.Migration

  def change do
    create table(:historicos) do
      add :ano, :integer
      add :conceito, :string
      add :semestre, :integer
      add :nota, :decimal
      add :turma_pratica, :integer
      add :turma_teorica, :integer
      add :disciplina__estudante_id, references(:disciplinas__estudantes)

      timestamps()
    end
  end
end
