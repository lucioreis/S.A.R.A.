defmodule SapiensWeb.Components.Horario do
  use Surface.Component

  @moduledoc """
    Show a student's schedulle.
  """

  prop horario, :map, required: true

  def render(assigns) do
    ~F"""
    <div class="">
      <div class="text-xs overflow-y-scroll">
        <table class="p-0 w-full text-center">
          <!-- head -->
          <thead>
            <tr class="text-sm odd:bg-base-200 even:bg-base-500 relative">
              <th class="sticky left-0 z-2 p-2 bg-highlight text-base-100">Hora</th>
              <th class="p-2 bg-highlight text-base-100">Segunda</th>
              <th class="p-2 bg-highlight text-base-100">Terca</th>
              <th class="p-2 bg-highlight text-base-100">Quarta</th>
              <th class="p-2 bg-highlight text-base-100">Quinta</th>
              <th class="p-2 bg-highlight text-base-100">Sexta</th>
              <th class="p-2 bg-highlight text-base-100">Sábado</th>
            </tr>
          </thead>
          <tbody>
            <!-- row 1 -->
            {#for time <- 7..17}
              <tr class="text-sm odd:bg-base-200 even:bg-base-500 relative">
                <td class="sticky left-0 z-2 bg-base-300 font-bold">
                  {time} :00
                </td>
                {#for day <- 1..6}
                  <td>
                    {#if @horario[{day, time}]}
                      <p class="font-bold">
                        {@horario[{day, time}]["codigo"]}
                      </p>
                      <p class="font-light text-xs">
                        {@horario[{day, time}]["local"]}
                      </p>
                    {#else}
                      <p class="text-gray-400">
                        --
                      </p>
                    {/if}
                  </td>
                {/for}
              </tr>
            {/for}
            <!-- row 2 -->
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
