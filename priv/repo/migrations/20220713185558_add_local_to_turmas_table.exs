defmodule Sapiens.Repo.Migrations.AddLocalToTurmasTable do
  use Ecto.Migration

  def change do
    alter table("turmas") do
      add :local, :string
    end
  end
end
