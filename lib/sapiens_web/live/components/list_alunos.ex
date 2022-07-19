defmodule SapiensWeb.Live.Components.ListAlunos do
  use SapiensWeb, :live_component
  alias SapiensWeb.Components.ListItens
  alias Sapiens.Estudantes

  @impl true
  def mount(socket) do
    socket = assign(socket, :edit, true)
    avaliacao = Ecto.Changeset.change(%Sapiens.Cursos.Avaliacao{})

    {
      :ok,
      socket
      |> assign(:changeset, Ecto.Changeset.change(%Sapiens.Cursos.Status{}))
    }
  end

  @impl true
  def update(assigns, socket) do
    disciplina = Sapiens.Repo.preload(assigns.turma, :disciplina).disciplina
    status_changes = Estudantes.change_status(%Sapiens.Cursos.Status{})

    statuses =
      Enum.reduce(assigns.alunos, %{}, fn aluno, acc ->
        Map.put_new(acc, aluno.id, Estudantes.get_status(aluno, assigns.turma))
      end)

    {:ok, historico} =
      try do
        Sapiens.Estudantes.get_historico(
          hd(assigns.alunos),
          disciplina
        )
      rescue
        _ -> {:ok, %Sapiens.Cursos.Historico{notas: %{}}}
      end

    {:ok,
     socket
     |> assign(:statuses, statuses)
     |> assign(status_changes: status_changes)
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
  def handle_event("post_notas", %{"status" => %{"aluno_id" => aluno_id}} = form, socket) do
    aluno_id = String.to_integer(aluno_id)
    status = socket.assigns.statuses[aluno_id]

    provas =
      Enum.reduce(form["status"], %{}, fn {nome, nota}, acc ->
        if String.starts_with?(nome, "P") do
          try do
            Map.put_new(acc, nome, %{
              Map.get(status.provas, nome)
              | "nota" => String.to_integer(nota)
            })
          rescue
            _e -> Map.put_new(acc, nome, %{Map.get(status.provas, nome) | "nota" => 0})
          end
        else
          acc
        end
      end)

    status =
      Estudantes.update_status(%{
        status
        | provas: provas,
          ef:
            try do
              String.to_integer(form["status"]["ef"])
            rescue
              _ -> 0
            end
      })

    {
      :noreply,
      socket
      |> assign(statuses: %{socket.assigns.statuses | aluno_id => status})
      |> assign(:edit, not socket.assigns.edit)
    }



    disciplina = Sapiens.Repo.preload(socket.assigns.turma, :disciplina).disciplina
    {:ok, aluno} = Sapiens.Estudantes.by_id(aluno_id)
    Sapiens.Historicos.set_historico_from_status(aluno_id, socket.assigns.turma, status)
    notify(
      disciplina,
      aluno,
      "Notas atualizadas. Conceito: #{status.conceito}"
    )

    {:noreply, assign(socket, :edit, not socket.assigns.edit)}
  end

  def handle_event(
        "notas_changed",
        %{"status" => %{"aluno_id" => aluno_id, "ft" => ft, "fp" => fp}} = form,
        socket
      ) do
    aluno_id = String.to_integer(aluno_id)
    status = socket.assigns.statuses[aluno_id] 
    ft = String.to_integer(ft)
    fp = String.to_integer(fp)

    provas =
      Enum.reduce(form["status"], %{}, fn {nome, nota}, acc ->
        if String.starts_with?(nome, "P") do
          try do
            Map.put_new(acc, nome, %{
              Map.get(status.provas, nome)
              | "nota" => String.to_integer(nota)
            })
          rescue
            _e -> Map.put_new(acc, nome, %{Map.get(status.provas, nome) | "nota" => 0})
          end
        else
          acc
        end
      end)

    status =
      Estudantes.update_status(%{
        status
        | provas: provas,
          fp: fp,
          ft: ft,
          ef:
            try do
              String.to_integer(form["status"]["ef"])
            rescue
              _ -> 0
            end
      })

    media = calc_media(socket.assigns.alunos, aluno_id, status, socket.assigns.turma)

    menos = calc_menos(socket.assigns.alunos, aluno_id, status, socket.assigns.turma)

    send(self(), {:update_media, media})
    send(self(), {:update_menos, menos})

    socket = assign(socket, statuses: %{socket.assigns.statuses | aluno_id => status})
    {:noreply, socket}
  end

  def handle_event("notas_changed", %{"status" => %{"aluno_id" => aluno_id}} = form, socket) do
    {:noreply, socket}
  end

  defp calc_media(alunos, aluno_id, status, turma) do
    div(
      Enum.sum(
        for aluno <- alunos do
          if aluno.id == aluno_id do
            status.nf
          else
            Sapiens.Historicos.get_nota_final(aluno, turma)
          end
        end
      ),
      case Enum.count(alunos) do
        0 -> 1
        n -> n
      end
    )
  end

  def calc_menos(alunos, aluno_id, status, turma) do
    Enum.count(
      alunos,
      fn aluno ->
        if aluno.id == aluno_id do
          status.nf < 60
        else
          Sapiens.Historicos.get_nota_final(aluno, turma) < 60
        end
      end
    )
  end

  defp notify(disciplina, target, msg) do
    Sapiens.Notifications.create_grade_notification(
      disciplina,
      target,
      msg
    )

  end
end
