defmodule SapiensWeb.Professor.HomeLive do
  use SapiensWeb, :live_view
  alias Sapiens.Professores

  @impl true
  def mount(%{"id" => id}, _params, socket) do
    id = String.to_integer(id)
    {:ok, professor} = Professores.by_id(id, [:turmas, :disciplinas])
    horario = Professores.get_horarios(professor)

    socket =
      socket
      |> assign(
        menu_options: [
          {"lock", "Disciplinas",
           &Routes.live_path(&1, SapiensWeb.Professor.DisciplinasLive,
             id: Integer.to_string(id),
             d_id: "1"
           )},
          {"casino", "Alunos",
           &Routes.live_path(&1, SapiensWeb.Professor.HomeLive, id: Integer.to_string(id))}
        ]
      )
      |> assign(name: "Home")
      |> assign(nome: "Home")
      |> assign(user_id: id)
      |> assign(professor: professor)
      |> assign(horario: horario)

    {:ok, socket}
  end
end
