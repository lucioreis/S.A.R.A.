defmodule Sapiens.Repo.Migrations.CreateEstudantesTurmasTable do
  use Ecto.Migration

  def change do
    create table(:estudantes__turmas) do
      add :estudante_id, references(:estudantes)
      add :turma_id, references(:turmas)
    end

    create unique_index(:estudantes__turmas, [:estudante_id, :turma_id])
  end
end
