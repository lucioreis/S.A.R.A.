defmodule Sapiens.Entities.Estudante do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
    %Estudante{
      ano_ingresso: :integer,
      ano_saida: :integer,
      cidade: :string,
      estado: :string,
      forma_ingresso: :string,
      idade: :integer,
      matricula: :string,
      nome: :string
      disciplinas: [Sapiens.Cursos.Disciplina]
      turmas: [Sapiens.Cursos.Turma]
      historicos: [Sapiens.Cursos.Historico]
      enems: [Sapiens.Cursos.Enem]
      curso: Sapiens.Cursos.Curso
    }
  """
  schema "estudantes" do
    field(:ano_ingresso, :integer)
    field(:ano_saida, :integer)
    field(:cidade, :string)
    field(:estado, :string)
    field(:forma_ingresso, :string)
    field(:idade, :integer)
    field(:matricula, :string)
    field(:situacao, :string)
    field(:nome, :string)

    timestamps()

    many_to_many(:disciplinas, Sapiens.Cursos.Disciplina, join_through: Sapiens.Cursos.Historico)

    many_to_many(:turmas, Sapiens.Cursos.Turma, join_through: Sapiens.Cursos.EstudanteTurma)

    has_many(:enems, Sapiens.Cursos.Enem)

    belongs_to(:curso, Sapiens.Cursos.Curso)
  end

  @doc false
  def changeset(estudante, attrs) do
    estudante
    |> cast(attrs, [
      :matricula,
      :situacao,
      :ano_ingresso,
      :forma_ingresso,
      :ano_saida,
      :idade,
      :estado,
      :cidade,
      :turmas,
      :historicos
    ])
    |> validate_required([
      :matricula,
      :situacao,
      :ano_ingresso,
      :forma_ingresso,
      :ano_saida,
      :idade,
      :estado,
      :cidade
    ])
  end
end
