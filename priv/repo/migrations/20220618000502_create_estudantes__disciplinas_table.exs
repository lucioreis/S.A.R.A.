defmodule Sapiens.Repo.Migrations.CreateEstudantesDisciplinasTable do
  use Ecto.Migration

  def change do
    create table(:disciplinas__estudantes) do
      add :disciplina_id, references(:disciplinas)
      add :estudante_id, references(:estudantes)

      timestamps()
    end
  end
end
