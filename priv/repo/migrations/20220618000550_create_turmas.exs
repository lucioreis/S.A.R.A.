defmodule Sapiens.Repo.Migrations.CreateTurmas do
  use Ecto.Migration

  def change do
    create table(:turmas) do
      add :numero, :integer
      add :tipo, :string
      add :horario, :map
      add :vagas_disponiveis, :integer
      add :vagas_preenchidas, :integer
      add :professor_id, references(:professores)
      add :disciplina_id, references(:disciplinas)

      timestamps()
    end
  end
end
