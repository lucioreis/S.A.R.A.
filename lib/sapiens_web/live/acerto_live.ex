defmodule SapiensWeb.AcertoLive do
  use SapiensWeb, :live_view
  alias Sapiens.Estudante

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

    id = 35
    {:ok, disciplinas} = Estudante.get_disciplinas(id)
    {:ok, horario} = Estudante.get_horarios(id)
    {:ok, matriculas} = Estudante.get_turmas(id)

    {
      :ok,
      socket
      |> assign(disciplinas: disciplinas)
      |> assign(horario: horario)
      |> assign(matriculas: matriculas)
      |> assign(name: "Acerto")
    }
  end

  @spec add(integer, integer) :: integer
  def add(a, b), do: a + b
end
