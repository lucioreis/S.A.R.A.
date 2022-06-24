defmodule SapiensWeb.Professor.HomeLive do
  use SapiensWeb, :live_view

  def mount(_session, _params, socket) do
    socket =
      socket
      |> assign(menu_options: [
        {"lock", "Disciplinas", SapiensWeb.PageLive},
        {"casino", "Alunos", SapiensWeb.PageLive },
        {"close", "Saír", SapiensWeb.PageLive}
      ])
      |> assign(name: "Home")
      |> assign(nome: "Home")
      |> assign(
        disciplinas: [
          %{
            nome: "INF 123",
            horario: ["Seg. 10:00", "Ter. 08:00"],
            nalunos: 34
          },
          %{
            nome: "INF 789",
            horario: ["Seg. 10:00", "Ter. 08:00"],
            nalunos: 34
          }
        ]
      )
      |> assign(horario: get_horario(socket))

    {:ok, socket}
  end


  defp get_horario(_socket) do
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
end
