defmodule SapiensWeb.Professor.DisciplinasLive do
  use SapiensWeb, :live_view

  alias SapiensWeb.Components.ListItens

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    socket = 
      socket 
      |> assign(menu_options: [
        {"book", "Disciplinas", SapiensWeb.PageLive},
        {"school", "Alunos", SapiensWeb.PageLive},
        {"close", "Saír", SapiensWeb.PageLive},
      ])
      |> assign(name: "Disciplinas")
      |> assign(id: id)
    {:ok, socket}
  end

end
