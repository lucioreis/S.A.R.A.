defmodule SapiensWeb.Components.DisciplinasMatriculado do
  use Phoenix.Component

  def show(assigns) do
    ~H"""
    <div class="w-full">
      <div class={if @matriculas == [], do: "hidden", else: "block"}>

        <table class="w-full p-4 mb-2">
          <thead>
            <tr class="bg-highlight text-white">
              <th class="p-1 w-5/6"> Disciplinas Matriculado </th>
              <th class="p-1 w-1/12"> <span class="center"> Turma </span> </th>
              <th class="p-1 w-1/12"> Créditos </th>
            </tr>
          </thead>

          <tbody class="">
            <%= for turma <- @matriculas do%>
              <tr class="odd:bg-base-200 even:bg-base-500 ">
                <td class="p-1 w-5/6"> <%= turma.disciplina.nome %>  </td>
                <td class="p-1 w-1/12"> <span class="center"> <%= turma.numero %> </span> </td>
                <td class="p-1 w-1/12"> <span class="center"> <%= turma.disciplina.carga %> </span> </td>
              </tr>
            <% end %>
            <tr class="odd:bg-base-200 even:bg-base-500">
              <td class="bg-highlight text-white"> </td>
              <td class="bg-highlight font-bold text-white"> <span class="flex justify-end pr-2"> Total: </span> </td>
              <td class=" center font-bold"> <%= Enum.sum( for m <- @matriculas, do: m.disciplina.carga) %> </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
