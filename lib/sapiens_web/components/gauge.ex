defmodule SapiensWeb.Components.Gauge do
  use Phoenix.Component

  def render(assigns) do
    # assigns = %{assigns| total: String.to_integer(assigns.total), value: String.to_integer(assigns.value)}

    ~H"""
    <div class="relative flex h-[6rem] w-[6rem]">
      <svg viewBox="0 0 100 100" fill="#0ff0" xmlns="http://www.w3.org/2000/svg">
        <circle class="stroke-[3px] stroke-slate-300" cx="50" cy="50" r="45" />
        <circle
          stroke-dasharray={"#{281 / @total * @value} #{281 - 281 / @total * @value}"}
          class="stroke-[3px] stroke-blue-500"
          cx="50"
          cy="50"
          r="45"
        />
      </svg>
      <div class="absolute flex w-full h-full justify-center items-center text-xl text-blue-500">
        <%= "#{@value}/#{@total}" %>
      </div>
    </div>
    """
  end
end
