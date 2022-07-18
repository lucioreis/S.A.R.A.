defmodule SapiensWeb.Components.Button do
  use Phoenix.Component

  def confirm(assigns) do
    ~H"""
    <div class="flex justify-center align-center bg-yellow-400 border-black font-bold border rounded-md p-2 cursor-pointer">
      <span>Confirmar Alterações</span>
    </div>
    """
  end
end
