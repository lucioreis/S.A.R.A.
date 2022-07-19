defmodule Sapiens.Repo.Migrations.AddTimestampToNotificationsTable do
  use Ecto.Migration

  def change do
    alter table("notifications") do
      timestamps()
    end

  end
end
