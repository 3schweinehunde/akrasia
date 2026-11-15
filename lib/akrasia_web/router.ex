defmodule AkrasiaWeb.Router do
  use AkrasiaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AkrasiaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    # until #17 step 3b: nobody is logged in; replaced by phx.gen.auth's
    # fetch_current_scope_for_user
    plug :assign_no_scope
  end

  defp assign_no_scope(conn, _opts), do: Plug.Conn.assign(conn, :current_scope, nil)

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AkrasiaWeb do
    pipe_through :browser

    get "/", PageController, :home
    # own routes instead of /page/:template (#45)
    get "/imprint", PageController, :imprint
    get "/privacy", PageController, :privacy
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:akrasia, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AkrasiaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
