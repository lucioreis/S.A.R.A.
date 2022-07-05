defmodule Sapiens.Repo.Migrations.AddNotasToHistoricosTable do
  use Ecto.Migration

  def change do
    alter table("historicos") do
      add :notas, :map
    end
  end
end
