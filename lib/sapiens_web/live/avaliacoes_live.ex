defmodule SapiensWeb.AvaliacoesLive do
  use SapiensWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        menu_options: [
        {"sync","Acerto de Matrícula", SapiensWeb.AcertoLive},
        {"lock", "Avaliacoes", SapiensWeb.AvaliacoesLive},
        {"casino", "Dados Acadêmicos", SapiensWeb.DadosAcademicosLive },
        {"casino", "Dados Pessoais", SapiensWeb.DadosPessoalLive},
        {"library_books", "Biblioteca", SapiensWeb.PageLive }, 
        {"task","Plano de estudo", SapiensWeb.PlanoEstudoLive},
        {"close", "Saír", SapiensWeb.PageLive}
        ]
      )
      |> assign(grades: get_grades())
      |> assign(name: "Avaliacões")

    {:ok, socket}
  end

  defp get_grades() do
    for _ <- 1..Enum.random(1..10) do
      nome = "INF #{Enum.random(100..300)}" 
        f_pratica = Enum.random(0..10)
        f_teorica = Enum.random(0..20)
        notas = [P1: Enum.random(50..100), P2: Enum.random(40..80), P3: Enum.random(0..100)]
        total = div(Enum.reduce(notas, 0, fn {_, value}, acc -> value+acc end ), length(notas))
        exame_final = if total > 40 and total < 60, do: Enum.random(10..100), else: 0
        nota_final = if exame_final > 2, do: div(exame_final+total, 2), else: total
        conceito = if(f_teorica >= 16 or f_pratica >= 16, do: "L", else: nota_final)
        {
          nome,
          f_pratica,
          f_teorica,
          notas,
          total,
          exame_final,
          nota_final,
          conceito
        }
    end

  end
end
