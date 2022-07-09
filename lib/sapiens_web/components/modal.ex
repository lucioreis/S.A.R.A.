defmodule SapiensWeb.Components.Modal do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <!-- This example requires Tailwind CSS v2.0+ -->
    <div class="relative z-10" aria-labelledby="modal-title" role="dialog" aria-modal="true">
      <!--
        Background backdrop, show/hide based on modal state.

        Entering: "ease-out duration-300"
          From: "opacity-0"
          To: "opacity-100"
        Leaving: "ease-in duration-200"
          From: "opacity-100"
          To: "opacity-0"
      -->
      <div phx-click="toggle_modal" class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>

      <div class="fixed z-10 inset-0 overflow-y-auto">
        <div class="flex items-end sm:items-center justify-center min-h-full p-4 text-center sm:p-0">
          <!--
            Modal panel, show/hide based on modal state.

            Entering: "ease-out duration-300"
              From: "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
              To: "opacity-100 translate-y-0 sm:scale-100"
            Leaving: "ease-in duration-200"
              From: "opacity-100 translate-y-0 sm:scale-100"
              To: "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
          -->
          <div class="relative bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:max-w-lg sm:w-full">
            <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
              <div class="sm:flex sm:items-start">
                <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10">
                  <!-- Heroicon name: outline/exclamation -->
                  <svg class="h-6 w-6 text-red-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                  </svg>
                </div>
                <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                  <h3 class="text-lg leading-6 font-medium text-gray-900" id="modal-title">Resumo de Alterações</h3>
                  <div class="mt-2"> 
    <!-- CONTENT -->
    <div class="">
      <div class="text-xs overflow-y-scroll">
        <table class="p-0 w-full text-center">
          <!-- head -->
          <thead>
            <tr class="text-sm odd:bg-base-200 even:bg-base-500">
              <th class="sticky left-0 p-2 bg-highlight text-base-100">Hora</th>
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
            <%= for time <- 7..17 do %>
              <tr class="text-sm odd:bg-base-200 even:bg-base-500">
                <td class="sticky left-0 bg-base-300 font-bold">
                  <%= time %> :00
                </td>
                <%= for day <- 1..6 do %>
                  <td>
                    <%= if @horario[{day, time}] do %>
                      <span class="text-black">
                        <p class="font-bold text-green-500">
                          + <%= @horario[{day, time}]["codigo"] %>
                        </p>
                        <p class="font-bold text-red-500">
                          - <%= @horario[{day, time}]["codigo"] %>
                        </p>
                      </span>
                     <% else %>
                      <p class="text-gray-400">
                        --
                      </p>
                  <% end %>
                  </td>
                <% end %>
              </tr>
            <% end %>
            <!-- row 2 -->
          </tbody>
        </table>
      </div>
    </div>
    <!-- END OF CONTENT -->
                    
                  </div>
                </div>
              </div>
            </div>
            <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
              <button type="button" phx-click="toggle_modal" class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-red-600 text-base font-medium text-white hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:ml-3 sm:w-auto sm:text-sm">Confirmar</button>
              <button type="button" phx-click="toggle_modal" class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm">Retornar</button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
