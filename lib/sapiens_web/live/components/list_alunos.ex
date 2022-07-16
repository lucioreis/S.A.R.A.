defmodule SapiensWeb.Live.Components.ListAlunos do
  use SapiensWeb, :live_component
  alias SapiensWeb.Components.ListItens

  @impl true
  def mount(socket) do
    socket = assign(socket, :edit, true)
    changeset = Ecto.Changeset.change(%Sapiens.Cursos.Avaliacao{})
    socket = assign(socket, :changeset, changeset)
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    disciplina = Sapiens.Repo.preload(assigns.turma, :disciplina).disciplina

    {:ok, historico} =
      Sapiens.Estudantes.get_historico(
        hd(assigns.alunos),
        disciplina
      )

    {:ok,
     socket
     |> assign(:alunos, assigns.alunos)
     |> assign(:historico, historico)
     |> assign(:turma, assigns.turma)
     |> assign(:disciplina, disciplina)}
  end

  @impl true
  def handle_event("change_mode", _value, socket) do
    {
      :noreply,
      assign(socket, :edit, not socket.assigns.edit)
    }
  end

  @impl true
  def handle_event("post_notas", form, socket) do
    IO.inspect(form)
    {:noreply, assign(socket, :edit, not socket.assigns.edit)}
  end
end
