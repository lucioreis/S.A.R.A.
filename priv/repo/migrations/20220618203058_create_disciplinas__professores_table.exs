defmodule Sapiens.Repo.Migrations.CreateDisciplinasProfessoresTable do
  use Ecto.Migration

  def change do
    create table(:disciplinas__professores) do
      add :disciplina_id, references(:disciplinas)
      add :professor_id, references(:professores)
    end

  end
end
