defmodule AkrasiaWeb.PageController do
  use AkrasiaWeb, :controller

  def home(conn, _params), do: render(conn, :home)

  # imprint and privacy have their own routes instead of /page/:template (#45)
  def imprint(conn, _params), do: render(conn, :imprint)

  def privacy(conn, _params), do: render(conn, :privacy)
end
