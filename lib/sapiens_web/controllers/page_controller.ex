defmodule SapiensWeb.PageController do
  use SapiensWeb, :controller

  def index(conn, _params) do
    conn
    |> render("index.html")
  end
end
