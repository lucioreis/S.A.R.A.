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
      add :disciplina_id, references(:disciplinas)
      add :estudantes_id, references(:estudantes)

      timestamps()
    end
  end
end
