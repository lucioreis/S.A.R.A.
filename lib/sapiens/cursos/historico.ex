defmodule Sapiens.Cursos.Historico do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
    %Historica{
      ano: :integer,
      conceito: :string,
      semestre: :integer,
      nota: :decimal,
      turma_pratica: :integer,
      turma_teorica: :integer,
      estudante: Sapiens.Cursos.Estudante,
      disciplina: Sapiens.Cursos.Disciplina
    }
  """
  schema "historicos" do
    field(:ano, :integer)
    field(:conceito, :string)
    field(:semestre, :integer)
    field(:nota, :integer)
    field(:exame_final, :integer)
    field(:notas, :map)
    field(:turma_pratica, :integer)
    field(:turma_teorica, :integer)

    timestamps()

    belongs_to(:estudante, Sapiens.Cursos.Estudante)
    belongs_to(:disciplina, Sapiens.Cursos.Disciplina)
  end

  @doc false
  def changeset(historico, attrs \\ %{}) do
    historico
    |> cast(attrs, [
      :ano,
      :semestre,
      :nota,
      :notas,
      :conceito,
      :turma_pratica,
      :turma_teorica,
      :exame_final
    ])
    |> validate_required([:ano, :semestre])
    |> unique_constraint([:ano, :semestre, :disciplina_id, :estudante_id],
      name: :historicos_ano_semestre_disciplina_id_index
    )
  end
end
