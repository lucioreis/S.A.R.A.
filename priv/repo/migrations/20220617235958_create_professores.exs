defmodule Sapiens.Repo.Migrations.CreateProfessores do
  use Ecto.Migration

  def change do
    create table(:professores) do
      add :codigo, :integer
      add :semestre, :integer
      add :tipo_turma, :string
      add :ano_ingresso, :integer
      add :nome, :string
      add :data_nascimento, :date
      add :matricula, :string
      add :curso_id, references(:cursos)

      timestamps()
    end
  end
end
