defmodule AkrasiaWeb.PageController do
  use AkrasiaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", error_message: nil)
  end
end
