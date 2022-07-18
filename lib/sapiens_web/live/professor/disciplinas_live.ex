defmodule SapiensWeb.Professor.DisciplinasLive do
  use SapiensWeb, :live_view

  alias SapiensWeb.Components.ListItens
  alias Sapiens.Turmas
  alias Sapiens.Disciplinas
  alias Sapiens.Professores
  alias Sapiens.Historicos
  alias Sapiens.Repo

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    id = String.to_integer(id)
    {:ok, professor} = Professores.by_id(id, [:disciplinas, :turmas])

    turmas =
      for t <- professor.turmas do
        Repo.preload(t, :disciplina)
      end |> Enum.sort(&(&1.numero < &2.numero))

    {:ok, selected_turma} = Turmas.by_id(1)
    selected_turma = Repo.preload(selected_turma, :estudantes)
    {:ok, alunos} = Turmas.get_all_estudantes(selected_turma)
    alunos = for aluno <- alunos, do: Repo.preload(aluno, :historicos)

    media =
      div(
        Enum.sum(for aluno <- alunos, do: Historicos.get_nota_final(aluno, selected_turma)),
        case Enum.count(alunos) do
          0 -> 1
          n -> n
        end
      )

    menos =
      Enum.count(alunos, fn aluno ->
        Sapiens.Historicos.get_nota_final(aluno, selected_turma) < 60
      end)

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
     |> assign(num_avaliacoes: selected_turma.provas |> Map.keys() |> Enum.count())
     |> assign(professor: professor)
     |> assign(turmas: turmas)
     |> assign(alunos: alunos)
     |> assign(:toggle_edit_turma, false)
     |> assign(num_alunos: Enum.count(alunos))
     |> assign(menos: menos)
     |> assign(media: media)
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
    turma = Repo.preload(turma, [:estudantes, :disciplina, :professor])
    alunos = for aluno <- turma.estudantes, do: Repo.preload(aluno, :historicos)

    send_update(
      SapiensWeb.Live.Components.ListAlunos,
      id: turma.id,
      alunos: alunos,
      turma: turma
    )

    media =
      div(
        Enum.sum(for aluno <- alunos, do: Historicos.get_nota_final(aluno, turma)),
        case Enum.count(alunos) do
          0 -> 1
          n -> n
        end
      )

    menos =
      Enum.count(alunos, fn aluno ->
        Sapiens.Historicos.get_nota_final(aluno, turma) < 60
      end)

    {
      :noreply,
      socket
      |> assign(selected_turma: turma)
      |> assign(media: media)
      |> assign(num_avaliacoes: turma.provas |> Map.keys() |> Enum.count())
      |> assign(menos: menos)
    }
  end

  @impl true
  def handle_event("toggle_modal", _value, socket) do
    {:noreply,
     socket
     |> assign(:toggle_edit_turma, not socket.assigns.toggle_edit_turma)}
  end

  @impl true
  def handle_event("edit_turma", %{"turma_id" => turma_id}, socket) do
    turma = Enum.find(socket.assigns.turmas, &(&1.id == String.to_integer(turma_id)))
    socket = assign(socket, toggle_edit_turma: not socket.assigns.toggle_edit_turma)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"avaliacao" => form}, socket) do
    %{
      "nome" => nome,
      "hora" => hora,
      "date" => date,
      "local" => local,
      "ordem" => ordem,
      "total" => total
    } = form

    teste = %{
      "nome" => nome,
      "hora" => hora,
      "date" => date,
      "local" => local,
      "ordem" => String.to_integer(ordem),
      "nota" => String.to_integer(total)
    }

    {:ok, turma} = Turmas.by_id(socket.assigns.selected_turma.id)
    turma = turma |> Repo.preload([:estudantes, :disciplina])
    Sapiens.Turmas.create_avaliacao(turma, teste)

    send_update(
      SapiensWeb.Live.Components.ListAlunos,
      id: socket.assigns.selected_turma.id,
      alunos: socket.assigns.turma.estudantes,
      turma: turma
    )

    {
      :noreply,
      socket
      |> assign(num_avaliacoes: turma.provas |> Map.keys() |> Enum.count())
    }
  end

  @impl true
  def handle_event("validate", form, socket) do
    {:noreply,
     socket
     |> assign(changeset: Sapiens.Cursos.Avaliacao.changeset(%Sapiens.Cursos.Avaliacao{}, form))}
  end

  @impl true
  def handle_info({:update_media, media}, socket) do
    {:noreply, socket |> assign(media: media)}
  end

  @impl true
  def handle_info({:update_menos, menos}, socket) do
    {:noreply, socket |> assign(menos: menos)}
  end
end
