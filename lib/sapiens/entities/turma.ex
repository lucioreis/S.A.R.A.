defmodule Sapiens.Entities.Turma do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
    %Turma{
      horario: :map, # %{dia => [horas]}
      numero: :integer,
      tipo: :string, # "teorica" | "pratica"
      vagas_preenchidas: :integer,
      vagas_disponiveis: :integer,
      estudantes: Sapiens.Cursos.Estudante
      disciplina: Sapiens.Cursos.Disciplina
      professor: Sapiens.Cursos.Professor
    }
  """

  schema "turmas" do
    field(:horario, :map)
    field(:numero, :integer)
    field(:tipo, :string)
    field(:vagas_disponiveis, :integer)
    field(:vagas_preenchidas, :integer)

    timestamps()

    many_to_many(:estudantes, Sapiens.Cursos.Estudante,
      join_through: Sapiens.Cursos.EstudanteTurma
    )

    belongs_to(:disciplina, Sapiens.Cursos.Disciplina)
    belongs_to(:professor, Sapiens.Cursos.Professor)
  end

  @doc false
  def changeset(turma, attrs) do
    turma
    |> cast(attrs, [
      :numero,
      :tipo,
      :horario,
      :vagas_disponiveis,
      :vagas_preenchidas,
      :estudantes,
      :disciplina,
      :professor
    ])
    |> validate_required([:numero, :tipo, :horario, :vagas_disponiveis, :vagas_preenchidas])
    |> unique_constraint(:id, name: :turmas_pkey)
  end
end
