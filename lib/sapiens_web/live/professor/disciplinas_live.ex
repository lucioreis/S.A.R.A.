defmodule SapiensWeb.Professor.DisciplinasLive do
  use SapiensWeb, :live_view

  alias SapiensWeb.Components.ListItens
  alias Sapiens.Turmas
  alias Sapiens.Disciplinas
  alias Sapiens.Professores
  alias Sapiens.Repo

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    id = String.to_integer(id)
    {:ok, professor} = Professores.by_id(id, [:disciplinas, :turmas])
    turmas = for t <- professor.turmas, do: Repo.preload(t, :disciplina)
    {:ok, selected_turma} = Turmas.by_id(2)
    selected_turma = Repo.preload(selected_turma, :estudantes)
    {:ok, alunos} = Turmas.get_all_estudantes(selected_turma)
    alunos = for aluno <- alunos, do: Repo.preload(aluno, :historicos)

    {:ok,
     socket
     |> assign(
       menu_options: [
         {"lock", "Disciplinas",
          &Routes.live_path(&1, SapiensWeb.Professor.DisciplinasLive, id: id, d_id: 1)},
         {"casino", "Alunos", &Routes.live_path(&1, SapiensWeb.Professor.HomeLive, id: id)}
       ]
     )
     |> assign(name: "Disciplinas")
     |> assign(user_id: id)
     |> assign(selected_turma: 1)
     |> assign(turma: selected_turma)
     |> assign(professor: professor)
     |> assign(turmas: turmas)
     |> assign(alunos: alunos)
     |> assign(:toggle_edit_turma, false)
     |> assign(media: 75)
     |> assign(disciplinas: professor.disciplinas)
     |> assign(selected_turma: selected_turma)}
  end

  @impl true
  def handle_params(unsigned_params, _uri, socket) do
    {:ok, disciplina} =
      if unsigned_params["d_id"] do
        Sapiens.Disciplinas.by_id(String.to_integer(unsigned_params["d_id"]))
      else
        Sapiens.Disciplinas.by_id(1)
      end

    {:noreply, assign(socket, :disciplina, Sapiens.Repo.preload(disciplina, :turmas))}
  end

  @impl true
  def handle_event("set_turma", %{"turma_id" => turma_id}, socket) do
    {:ok, turma} = Turmas.by_id(String.to_integer(turma_id))
    turma = Repo.preload(turma, [:estudantes, :disciplina])
    alunos = for aluno <- turma.estudantes, do: Repo.preload(aluno, :historicos)

    send_update(
      SapiensWeb.Live.Components.ListAlunos,
      id: socket.assigns.professor.id,
      alunos: alunos,
      turma: turma
    )

    {:noreply, assign(socket, selected_turma: turma)}
  end

  @impl true
  def handle_event("toggle_modal", _value, socket) do
    {:noreply,
     socket
     |> assign(:toggle_edit_turma, not socket.assigns.toggle_edit_turma)}
  end

  @impl true
  def handle_event("build_teste", %{"turma_id" => turma_id}, socket) do
    teste = %{
      total: 100,
      nota: 0,
      local: "PVA 123",
      ordem: 1,
      hora: 18
    }

    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_turma", %{"turma_id" => turma_id}, socket) do
    turma = Enum.find(socket.assigns.turmas, &(&1.id == String.to_integer(turma_id)))
    turma = Repo.preload(turma, [:disciplina, :estudantes])
    socket = assign(socket, toggle_edit_turma: not socket.assigns.toggle_edit_turma)
    IO.inspect(socket.assigns.toggle_edit_turma)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"avaliacao" => form}, socket) do
    estudantes = socket.assigns.turma.estudantes
    %{"nome" => nome, "hora" => hora, "local" => local, "ordem" => ordem, "total" => total} = form

    teste = %{
      hora: hora,
      local: local,
      nota: 0,
      ordem: String.to_integer(ordem),
      total: String.to_integer(total)
    }

    Sapiens.Historicos.create_teste(socket.assigns.turma, {nome, teste})
    turma = Turmas.by_id(socket.assigns.turma.id) |> Repo.preload([:estudantes, :disciplina])

    send_update(
      SapiensWeb.Live.Components.ListAlunos,
      id: socket.assigns.professor.id,
      alunos: socket.assigns.turma.estudantes,
      turma: turma
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", form, socket) do
    {:noreply,
     socket
     |> assign(changeset: Sapiens.Cursos.Avaliacao.changeset(%Sapiens.Cursos.Avaliacao{}, form))}
  end
end
