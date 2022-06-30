defmodule SapiensWeb.AcertoLive do
  use SapiensWeb, :live_view
  alias Sapiens.Estudante, warn: false
  alias Sapiens.Disciplina, warn: false
  alias Sapiens.Repo, warn: false

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    socket =
      socket
      |> assign(
        menu_options: [
          {"sync", "Acerto de Matrícula", &Routes.live_path(&1, SapiensWeb.AcertoLive, id: id)},
          {"lock", "Avaliacoes", &Routes.live_path(&1, SapiensWeb.AvaliacoesLive, id: id)},
          {"casino", "Dados Acadêmicos",
           &Routes.live_path(&1, SapiensWeb.DadosAcademicosLive, id: id)},
          {"casino", "Dados Pessoais",
           &Routes.live_path(&1, SapiensWeb.DadosPessoalLive, id: id)},
          {"library_books", "Biblioteca", &Routes.live_path(&1, SapiensWeb.PageLive, id: id)},
          {"task", "Plano de estudo", &Routes.live_path(&1, SapiensWeb.PlanoEstudoLive, id: id)}
        ]
      )

    socket =
      socket
      |> assign(:estudante_id, String.to_integer(id))
      |> assign(:user_id, String.to_integer(id))

    {:ok, estudante} = Estudante.by_id(socket.assigns.estudante_id)
    {:ok, disciplinas} = Estudante.get_disciplinas(estudante)
    {:ok, horario} = Estudante.get_horarios(estudante)
    {:ok, matriculas} = Estudante.get_turmas_matriculado(estudante)
    matriculas = for m <- matriculas, do: Repo.preload(m, :disciplina)
    IO.inspect(matriculas, label: "MATRICULAS")

    {
      :noreply,
      socket
      |> assign(disciplinas: disciplinas)
      |> assign(horario: horario)
      |> assign(matriculas: matriculas)
      |> assign(name: "Acerto")
    }

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    socket =
      socket
      |> assign(:estudante_id, String.to_integer(id))

    {:ok, estudante} = Estudante.by_id(socket.assigns.estudante_id)
    {:ok, disciplinas} = Estudante.get_disciplinas(estudante)
    {:ok, horario} = Estudante.get_horarios(estudante)
    {:ok, matriculas} = Estudante.get_turmas_matriculado(estudante)
    matriculas = for m <- matriculas, do: Repo.preload(m, :disciplina)
    IO.inspect(matriculas, label: "MATRICULAS")

    {
      :noreply,
      socket
      |> assign(disciplinas: disciplinas)
      |> assign(horario: horario)
      |> assign(matriculas: matriculas)
      |> assign(name: "Acerto")
    }
  end

  @impl true
  def handle_info({:updated_horario, %{horario: horario, matriculas: matriculas}}, socket) do
    {:noreply,
     socket
     |> assign(matriculas: matriculas)
     |> assign(horario: horario)}
  end

  @impl true
  def handle_info({:mat, %{disciplina_id: disciplina_id, sender: sender}}, socket) do
    if sender == self() do
      {:noreply, socket}
      # require IEx; IEx.pry
    else
      {:ok, estudante} = Estudante.by_id(socket.assigns.estudante_id)
      {:ok, horario} = Estudante.get_horarios(estudante)
      {:ok, matriculas} = Estudante.get_turmas_matriculado(estudante)
      matriculas = for m <- matriculas, do: Repo.preload(m, :disciplina)

      socket =
        socket
        |> assign(horario: horario)
        |> assign(matricula: matriculas)

      send_update(
        SapiensWeb.Components.CardDisciplina,
        id: disciplina_id,
        disciplina_id: disciplina_id,
        estudante_id: socket.assigns.estudante_id,
        matriculas: socket.assigns.matriculas
      )

      {:noreply, socket}
    end
  end
end
