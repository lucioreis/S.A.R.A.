# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Sapiens.Repo.insert!(%Sapiens.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

"""
SELECT *
  FROM public.disciplinas
LEFT OUTER JOIN public.disciplinas__estudantes
  ON disciplinas.ID = disciplinas__estudantes.disciplina_id
LEFT OUTER JOIN estudantes
  ON disciplinas__estudantes.estudante_id = estudantes.ID
"""

alias Sapiens.Cursos.{
  Estudante,
  Professor,
  Curso,
  Disciplina,
  Enem,
  Historico,
  Turma,
  EstudanteTurma,
  DisciplinaProfessor
}

alias Sapiens.Repo
alias Sapiens.Cursos
import Ecto.Query, only: [from: 2], warn: false

Repo.delete_all(EstudanteTurma)
Repo.delete_all(DisciplinaProfessor)
Repo.delete_all(Historico)
Repo.delete_all(Enem)
Repo.delete_all(Turma)
Repo.delete_all(Disciplina)
Repo.delete_all(Estudante)
Repo.delete_all(Professor)
Repo.delete_all(Curso)

curso =
  Repo.insert!(%Curso{
    codigo: 261,
    nome: "Ciência da Computação",
    sigla: "INF"
  })

defmodule Gen do
  defp ano, do: Enum.random [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022]
  defp idade, do: Enum.random [18, 19, 20, 21, 22, 23, 24, 25, 26]
  defp estado, do: Enum.random ["MG", "SP", "RJ", "ES"]

  defp nome do
    Enum.random(
      ~w(Maria Joao Carlo Eduardo Marcelo Tiago Aline Alice Paula Claudia Carla Marina Vitoria Luis Benjamin Tereza Patricia Ema Lucas Diego Marcos Alicia Valentina Enzo)
    )
  end

  defp sobrenome do
    Enum.random(
      ~w(Silva Abrantes Pereira Moreira Silveira Amarantes Reis Duarte Batista Lopes Antunes Nunes Martins Borges Conde Bittencourt Souza)
    )
  end

  def historico(disciplina, estudante) do
    %Historico{
      ano: 0,
      conceito: 0,
      semestre: Sapiens.Utils.semestre_atual(),
      nota: 0,
      turma_pratica: 0,
      turma_teorica: 0,
      disciplina: disciplina,
      estudante: estudante
    }
  end

  def estudante(curso) do
    ano = ano()

    %Estudante{
      matricula: "es" <> Integer.to_string(Enum.random(10000..99999)),
      situacao: "normal",
      forma_ingresso: "enem",
      ano_ingresso: ano,
      ano_saida: ano + 7,
      idade: idade(),
      estado: estado(),
      nome: "#{nome()} #{sobrenome()}",
      cidade: "Cidade qualquer",
      curso: curso
    }
  end

  def disciplina(curso) do
    numero = Enum.random(100..999)
    carga = Enum.random([2, 4, 4, 4, 6])
    codigo = "INF #{numero}"

    %Sapiens.Cursos.Disciplina{
      carga: carga,
      codigo: codigo,
      nome: "Informatica #{numero}",
      pre_requisitos: [],
      co_requisitos: [],
      curso: curso,
      turmas:
        for i <- 1..Enum.random(1..20) do
          turma(i, carga, codigo)
        end
    }
  end

  def turma(i, carga, codigo) do
    horario = %{}
    hora = Enum.random([8, 10, 14, 16])
    dia = Enum.random([1, 2, 3, 4])
    vagas_disponiveis = Enum.random([0, Enum.random(1..50)])
    local = "PVA #{Enum.random(100..310)}"

    horario =
      Enum.reduce(2..carga//2, %{}, fn n, acc -> 
        dia_de_aula = case carga do
          6 -> Enum.random(1..3)
          4 -> Enum.random(1..4)
          2 -> Enum.random(1..5)
        end

        hora_de_aula = Enum.random([8, 10, 14, 16])

        case Map.get(horario, [dia_de_aula, hora_de_aula]) do
          nil -> Map.put(acc, [dia_de_aula, hora_de_aula], %{local: local, codigo: codigo})
                |> Map.put([dia_de_aula, hora_de_aula+1], %{local: local, codigo: codigo})
        end

      end)
        

    %Turma{
      numero: i,
      tipo: "teorica",
      horario: horario,
      vagas_disponiveis: vagas_disponiveis,
      vagas_preenchidas: 50 - vagas_disponiveis
    }
  end

  def professor(curso) do
    semestre = 1
    tipo_turma = "teorica"
    ano_ingresso =  ano()
    nome = nome() <> " " <> sobrenome()
    data_nascimento = ~D[2000-01-01]
    matricula = "pr" <> Integer.to_string(Enum.random(10000..99999))

    %Sapiens.Cursos.Professor{
      semestre: Sapiens.Utils.semestre_atual(),
      tipo_turma: tipo_turma,
      ano_ingresso: ano_ingresso,
      nome: nome,
      data_nascimento: data_nascimento,
      matricula: matricula,
      curso: curso
    }
  end
end

# Insert Disciplinas
for _ <- 1..3 do
  Sapiens.Repo.insert!(Gen.disciplina(curso))
end

for _ <- 1..5 do
  Sapiens.Repo.insert!(Gen.estudante(curso))
end

for _ <- 1..3 do
  Sapiens.Repo.insert!(Gen.professor(curso))
end
