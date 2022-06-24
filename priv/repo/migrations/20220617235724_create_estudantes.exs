defmodule Sapiens.Repo.Migrations.CreateEstudantes do
  use Ecto.Migration

  def change do
    create table(:estudantes) do
      add :matricula, :string
      add :situacao, :string
      add :ano_ingresso, :integer
      add :forma_ingresso, :string
      add :ano_saida, :integer
      add :idade, :integer
      add :estado, :string
      add :cidade, :string
      add :nome, :string
      add :curso_id, references(:cursos)

      timestamps()
    end
  end
end
