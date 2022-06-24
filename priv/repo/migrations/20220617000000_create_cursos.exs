defmodule Sapiens.Repo.Migrations.CreateCursos do
  use Ecto.Migration

  def change do
    create table(:cursos) do
      add :codigo, :integer
      add :nome, :string
      add :sigla, :string

      timestamps()
    end
  end
end
