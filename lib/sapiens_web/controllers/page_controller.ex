defmodule SapiensWeb.PageController do
  use SapiensWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
