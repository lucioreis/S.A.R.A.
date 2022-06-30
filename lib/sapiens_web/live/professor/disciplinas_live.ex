defmodule SapiensWeb.Professor.DisciplinasLive do
  use SapiensWeb, :live_view

  alias SapiensWeb.Components.ListItens

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    socket = 
      socket 
      |> assign(menu_options: [

        {"lock", "Disciplinas", &Routes.live_path(&1, SapiensWeb.Professor.DisciplinasLive, id:  id)},
        {"casino", "Alunos", &Routes.live_path(&1, SapiensWeb.Professor.HomeLive, id: id) },
      ])
      |> assign(name: "Disciplinas")

    id= String.to_integer(id)
    socket =  assign(socket, user_id: id)
    {:ok, socket}
  end

end
