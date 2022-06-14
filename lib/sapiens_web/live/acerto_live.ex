defmodule SapiensWeb.AcertoLive do
  use SapiensWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        menu_options: [
          {"sync", "Acerto de Matrícula", SapiensWeb.AcertoLive},
          {"lock", "Avaliacoes", SapiensWeb.AvaliacoesLive},
          {"casino", "Dados Acadêmicos", SapiensWeb.DadosAcademicosLive},
          {"casino", "Dados Pessoais", SapiensWeb.DadosPessoalLive},
          {"library_books", "Biblioteca", SapiensWeb.PageLive},
          {"task", "Plano de estudo", SapiensWeb.PlanoEstudoLive},
          {"close", "Saír", SapiensWeb.PageLive}
        ]
      )

    disciplinas = gen_disciplinas()
    horario = get_horario(socket)
    matriculas = gen_matriculado()

    {
      :ok,
      socket
      |> assign(disciplinas: disciplinas)
      |> assign(horario: horario)
      |> assign(matriculas: matriculas)
      |> assign(name: "Acerto")

    }
  end

  defp gen_disciplinas() do
    %{
      "INF 123": %{
        codigo: "INF 123",
        nome: "Informatica de Exemplo I",
        turmas: %{
          1 => %{
            numero: 1,
            vagas: Enum.random([0, 0, Enum.random(1..50)]),
            tipo: :teorica,
            local: "PVB 666",
            horario: ["Seg: 08:00-10:00", "Ter: 10:00-12:00"],
            h: %{1 => {8, 9}, 2 => {10, 11}}
          },
          2 => %{
            numero: 2,
            vagas: Enum.random([0, 0, Enum.random(1..50)]),
            tipo: :teorica,
            status: :matriculado,
            local: "PVB 123",
            horario: ["Seg: 10:00-12:00", "Ter: 08:00-10:00"],
            h: %{1 => {10, 11}, 2 => {8, 9}}
          },
          3 => %{
            numero: 3,
            vagas: Enum.random([0, 0, Enum.random(1..50)]),
            tipo: :teorica,
            local: "PVB 345",
            horario: ["Qua: 08:00-10:00", "Sex: 10:00-12:00"],
            h: %{3 => {8, 9}, 5 => {10, 11}}
          }
        }
      },
      "INF 456": %{
        codigo: "INF 456",
        nome: "Informatica de Exemplo II",
        turmas: %{
          1 => %{
            numero: 1,
            vagas: Enum.random(2..50),
            tipo: :teorica,
            local: "CCE 123",
            horario: ["Ter: 14:00-16:00", "Qui: 16:00-18:00"],
            h: %{2 => {8, 9}, 4 => {10, 11}}
          }
        }
      },
      "INF 789": %{
        codigo: "INF 789",
        nome: "Informatica de Exemplo III",
        turmas: %{
          1 => %{
            numero: 1,
            vagas: Enum.random([0, 0, Enum.random(1..50)]),
            tipo: :pratica,
            local: "PVA 123",
            horario: ["Ter: 14:00-16:00", "Qui: 16:00-18:00"],
            h: %{2 => {14, 15}, 4 => {16, 17}}
          },
          2 => %{
            numero: 2,
            vagas: Enum.random([0, 0, Enum.random(1..50)]),
            tipo: :teorica,
            local: "PVA 231",
            horario: ["Seg: 08:00-10:00", "Ter: 10:00-12:00"],
            h: %{1 => {8, 9}, 2 => {10, 11}}
          },
          3 => %{
            numero: 3,
            vagas: Enum.random([0, 0, Enum.random(1..50)]),
            tipo: :teorica,
            local: "PVA 222",
            horario: ["Seg: 10:00-12:00", "Ter: 08:00-10:00"],
            h: %{1 => {10, 11}, 2 => {8, 9}}
          },
          4 => %{
            numero: 4,
            vagas: Enum.random([0, 0, Enum.random(1..50)]),
            tipo: :teorica,
            local: "PVA 333",
            horario: ["Qua: 08:00-10:00", "Sex: 10:00-12:00"],
            h: %{2 => {8, 9}, 5 => {10, 11}}
          }
        }
      }
    }
  end

  defp get_horario(socket) do
    %{
      {1, 8} => %{codigo: "INF 123", local: "PVA 123"},
      {1, 9} => %{codigo: "INF 123", local: "PVA 123"},
      {2, 10} => %{codigo: "INF 123", local: "PVA 123"},
      {2, 11} => %{codigo: "INF 123", local: "PVA 123"},
      {2, 14} => %{codigo: "INF 789", local: "PVA 123"},
      {2, 15} => %{codigo: "INF 789", local: "PVA 123"},
      {4, 16} => %{codigo: "INF 789", local: "PVA 345"},
      {4, 17} => %{codigo: "INF 789", local: "PVA 345"}
    }
  end

  defp gen_matriculado() do
    %{"INF 123" => 1, "INF 789" => 1}
  end
end
