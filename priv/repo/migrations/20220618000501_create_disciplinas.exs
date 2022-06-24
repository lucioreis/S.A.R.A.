defmodule Sapiens.Repo.Migrations.CreateDisciplinas do
  use Ecto.Migration

  def change do
    create table(:disciplinas) do
      add :carga, :integer
      add :codigo, :string
      add :nome, :string
      add :pre_requisitos, {:array, :string}
      add :co_requisitos, {:array, :string}
      add :curso_id, references(:cursos)

      timestamps()
    end
  end
end
