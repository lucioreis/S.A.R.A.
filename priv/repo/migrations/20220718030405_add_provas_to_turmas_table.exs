defmodule Sapiens.Repo.Migrations.AddProvasToTurmasTable do
  use Ecto.Migration

  def change do
    alter table("turmas") do
      add :provas, :map
    end
  end
end
