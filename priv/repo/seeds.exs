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
  Turma
}
alias Sapiens.Repo
alias Sapiens.Cursos
import Ecto.Query, only: [from: 2], warn: false

Repo.delete_all Historico 
Repo.delete_all Enem 
Repo.delete_all Turma 
Repo.delete_all Disciplina 
Repo.delete_all Estudante 
Repo.delete_all Professor 
Repo.delete_all Curso 

anos = [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022]
idades = [18, 19, 20, 21, 22, 23, 24, 25, 26]
estados = ["MG", "SP", "RJ", "ES"]

nomes = fn ->
  Enum.random(
    ~w(Maria Joao Carlo Eduardo Marcelo Tiago Aline Alice Paula Claudia Carla Marina Vitoria Luis Benjamin Tereza Patricia Ema Lucas Diego Marcos Alicia Valentina Enzo)
  )
end

sobrenomes = fn ->
  Enum.random(
    ~w(Silva Abrantes Pereira Moreira Silveira Amarantes Reis Duarte Batista Lopes Antunes Nunes Martins Borges Conde Bittencourt Souza)
  )
end

curso = Repo.insert!(%Curso{
  codigo: 261,
  nome: "Ciência da Computação",
  sigla: "INF"
})

#Insert Disciplinas
for _ <- 1..3 do
  carga = Enum.random([2, 4, 4, 4, 6])
  codigo = "INF" <> Integer.to_string(Enum.random(100..199))
  nome = "Informatica de Exemplo" <> Integer.to_string(Enum.random(1..9))
  pre_requisitos = []
  co_requisitos = []

  numero = 1
  Sapiens.Repo.insert!(%Sapiens.Cursos.Disciplina{
    carga: carga,
    codigo: codigo,
    nome: nome,
    pre_requisitos: pre_requisitos,
    co_requisitos: co_requisitos,
    curso: curso,
    turmas: for i <- 1..Enum.random(1..20) do
        %Turma{
          numero: i,
          tipo: "teorica",
          horario: %{1 => [7,8], 4 => [9,10]},
          vagas_disponiveis: Enum.random(1..10),
          vagas_preenchidas: Enum.random(20..30)

        }
      end
  })
end

#Insert Estudantes
for _i <- 1..5 do
  ano = Enum.at(anos, Enum.random(0..(length(anos) - 1)))
  idade = Enum.at(idades, Enum.random(0..(length(idades) - 1)))
  estado = Enum.random(estados)
  nome = nomes.()
  sobrenome = sobrenomes.()

  disciplinas = Repo.all(from d in Disciplina, where: d.curso_id==^curso.id) 
  number_of_disciplinas = Enum.random(1..5)
  counter = 0
  matriculado = for disciplina <- disciplinas do
    if counter < number_of_disciplinas do
      Enum.random(disciplinas) 
    end
  end
  matriculado = Enum.filter(matriculado, fn disc ->
    repetition = Enum.filter(matriculado, fn dd -> disc.id == dd.id end)
    |> Enum.count()
    repetition == 1
  end)

  Sapiens.Repo.insert!(%Sapiens.Cursos.Estudante{
    matricula: "es" <> Integer.to_string(Enum.random(10000..99999)),
    situacao: "normal",
    forma_ingresso: "enem",
    ano_ingresso: ano,
    ano_saida: ano + 7,
    idade: idade,
    estado: estado,
    cidade: "Cidade qualquer",
    nome: nome <> " " <> sobrenome,
    curso: curso,
    disciplinas: matriculado
  })
end

# Insert Professores
for _ <- 1..3 do
  semestre = 1
  tipo_turma = "teorica"
  ano_ingresso = Enum.at(anos, Enum.random(0..(length(anos) - 1)))
  nome = nomes.() <> " " <> sobrenomes.()
  data_nascimento = ~D[2000-01-01]
  matricula = "pr" <> Integer.to_string(Enum.random(10000..99999))

  Sapiens.Repo.insert!(%Sapiens.Cursos.Professor{
    semestre: semestre,
    tipo_turma: tipo_turma,
    ano_ingresso: ano_ingresso,
    nome: nome,
    data_nascimento: data_nascimento,
    matricula: matricula,
    curso: curso
  })
end
