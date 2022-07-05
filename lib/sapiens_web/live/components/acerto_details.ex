defmodule SapiensWeb.Live.Components.AcertoDetails do
  use Surface.Component

  @doc "Lista de turmas onde o estudante está matriculado"
  prop matriculas, :map, required: true

  def render(assigns) do
    ~F"""
    <div class="w-full">
      <div class={if @matriculas == [], do: "hidden", else: "block"}>
        <table class="w-full p-4 mb-2">
          <thead>
            <tr class="bg-highlight text-white">
              <th class="p-1 w-5/6">
                Disciplinas Matriculado
              </th>
              <th class="p-1 w-1/12">
                <span class="center">
                  Turma
                </span>
              </th>
              <th class="p-1 w-1/12">
                Créditos
              </th>
            </tr>
          </thead>

          <tbody class="">
            {#for turma <- @matriculas}
              <tr class="odd:bg-base-200 even:bg-base-500">
                <td class="p-1 w-5/6">
                  {turma.disciplina.nome}
                </td>
                <td class="p-1 w-1/12">
                  <span class="center">
                    {turma.numero}
                  </span>
                </td>
                <td class="p-1 w-1/12">
                  <span class="center">
                    {turma.disciplina.carga}
                  </span>
                </td>
              </tr>
            {/for}
            <tr class="odd:bg-base-200 even:bg-base-500">
              <td class="bg-highlight text-white"> </td>
              <td class="bg-highlight font-bold text-white">
                <span class="flex justify-end pr-2">
                  Total:
                </span>
              </td>
              <td class="center font-bold">
                {Enum.sum(for m <- @matriculas, do: m.disciplina.carga)}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
