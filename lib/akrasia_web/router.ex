defmodule AkrasiaWeb.Router do
  use AkrasiaWeb, :router

  import AkrasiaWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AkrasiaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

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

  ## Authentication routes

  scope "/", AkrasiaWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{AkrasiaWeb.UserAuth, :require_authenticated}] do
      live "/users/profile", UserLive.Profile, :edit
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
      live "/diagram", WeighingDiagramLive, :show
      live "/weighings", MyWeighingLive.Index, :index
      live "/weighings/new", MyWeighingLive.Form, :new
      live "/weighings/:id/edit", MyWeighingLive.Form, :edit
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", AkrasiaWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{AkrasiaWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
