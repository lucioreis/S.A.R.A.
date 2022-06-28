defmodule Sapiens.Repo.Migrations.CreateHistoricos do
  use Ecto.Migration

  def change do
    create table(:historicos) do
      add :ano, :integer, null: false, primary_key: true
      add :semestre, :integer, null: false, primary_key: true
      add :conceito, :string
      add :nota, :decimal
      add :turma_pratica, :integer
      add :turma_teorica, :integer
      add :disciplina_id, references(:disciplinas), null: false, primary_key: true
      add :estudante_id, references(:estudantes), null: false, primary_key: true

      timestamps()

    end

    create unique_index(:historicos, [:ano, :semestre, :disciplina_id, :estudante_id], name: :historicos_ano_semestre_disciplina_id_index)
  end
end
