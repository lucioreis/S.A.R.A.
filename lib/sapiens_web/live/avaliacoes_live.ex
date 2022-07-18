defmodule SapiensWeb.AvaliacoesLive do
  use SapiensWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    id = String.to_integer(id)
    {:ok, estudante} = Sapiens.Estudantes.by_id(id)

    socket =
      socket
      |> assign(
        menu_options: [
          {"sync", "Acerto de Matrícula", &Routes.live_path(&1, SapiensWeb.AcertoLive, id: id)},
          {"lock", "Avaliacoes", &Routes.live_path(&1, SapiensWeb.AvaliacoesLive, id: id)},
          {"casino", "Dados Acadêmicos",
           &Routes.live_path(&1, SapiensWeb.DadosAcademicosLive, id: id)},
          {"casino", "Dados Pessoais",
           &Routes.live_path(&1, SapiensWeb.DadosPessoalLive, id: id)},
          {"library_books", "Biblioteca", &Routes.live_path(&1, SapiensWeb.PageLive, id: id)},
          {"task", "Plano de estudo", &Routes.live_path(&1, SapiensWeb.PlanoEstudoLive, id: id)}
        ]
      )
      |> assign(name: "Avaliações")
      |> assign(estudante_id: id)
      |> assign(estudante: estudante)
      |> assign(user_id: id)
      |> assign(grades: get_grades(estudante))

    {:ok, socket}
  end

  defp get_grades(estudante) do
    {:ok, turmas} = Sapiens.Estudantes.get_turmas_matriculado(estudante)

    for turma <- turmas do
      turmas_status = Sapiens.Estudantes.get_status(estudante, turma)
      turma = Sapiens.Repo.preload(turma, :disciplina)

      timestamp =
        Enum.random(hora: Enum.random(1..12), minuto: Enum.random(1..50), dia: Enum.random(1..23))

      IO.inspect(%{
        nome: turma.disciplina.nome,
        faltas_p: turmas_status.fp,
        faltas_t: turmas_status.ft,
        provas: turmas_status.provas,
        total: turmas_status.nf,
        nota_final: turmas_status.nf,
        exame_final: turmas_status.ef,
        conceito: turmas_status.conceito,
        timestamp: timestamp
      })
    end
  end

  defp _get_grades() do
    for _ <- 1..Enum.random(1..10) do
      nome = "INF #{Enum.random(100..300)}"
      f_pratica = Enum.random(0..10)
      f_teorica = Enum.random(0..20)
      notas = [P1: Enum.random(50..100), P2: Enum.random(40..80), P3: Enum.random(0..100)]
      total = div(Enum.reduce(notas, 0, fn {_, value}, acc -> value + acc end), length(notas))
      exame_final = if total > 40 and total < 60, do: Enum.random(10..100), else: 0
      nota_final = if exame_final > 2, do: div(exame_final + total, 2), else: total
      conceito = if(f_teorica >= 16 or f_pratica >= 16, do: "L", else: nota_final)

      timestamp =
        Enum.random(hora: Enum.random(1..12), minuto: Enum.random(1..50), dia: Enum.random(1..23))

      {
        nome,
        f_pratica,
        f_teorica,
        notas,
        total,
        exame_final,
        nota_final,
        conceito,
        timestamp
      }
    end
  end
end
