defmodule Sapiens.Repo.Migrations.CreateEnems do
  use Ecto.Migration

  def change do
    create table(:enems) do
      add :nota, :decimal
      add :modalidade, :string
      add :estudante_id, references(:estudantes)

      timestamps()
    end
  end
end
