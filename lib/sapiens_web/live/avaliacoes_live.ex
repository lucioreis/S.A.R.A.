defmodule SapiensWeb.AvaliacoesLive do
  use SapiensWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        menu_options: [
          {"sync", "Acerto de Matrícula"},
          {"lock", "Avaliacoes"},
          {"casino", "Dados Acadêmicos"},
          {"casino", "Dados Pessoais"},
          {"library_books", "Biblioteca"},
          {"task", "Plano de estudo"},
          {"close", "Saír"}
        ]
      )
      |> assign(grades: get_grades())

    {:ok, socket}
  end

  defp get_grades() do
    for _ <- 1..Enum.random(1..10) do
      nome = "INF #{Enum.random(100..300)}" 
        f_pratica = Enum.random(0..10)
        f_teorica = Enum.random(0..20)
        notas = [P1: Enum.random(50..100), P2: Enum.random(40..80), P3: Enum.random(0..100)]
        total = div(Enum.reduce(notas, 0, fn {_, value}, acc -> value+acc end ), length(notas))
        exame_final = Enum.random([Enum.random(0..100), 0, 0])
        nota_final = div(exame_final+total, 2)
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
