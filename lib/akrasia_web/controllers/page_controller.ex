defmodule AkrasiaWeb.PageController do
  use AkrasiaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
