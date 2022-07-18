defmodule Sapiens.Repo.Migrations.AddExameFinalToHistoricosTable do
  use Ecto.Migration

  def change do
    alter table("historicos") do
      add :exame_final, :integer
    end
  end
end
