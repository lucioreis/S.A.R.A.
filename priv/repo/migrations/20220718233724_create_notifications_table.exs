defmodule Sapiens.Repo.Migrations.CreateNotificationsTable do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :read, :boolean, default: false
      add :message, :string
      add :estudante_id, references(:estudantes, on_delete: :delete_all)
      add :professor_id, references(:professores, on_delete: :delete_all)
      add :disciplina_id, references(:disciplinas, on_delete: :delete_all)
    end
  end
end
