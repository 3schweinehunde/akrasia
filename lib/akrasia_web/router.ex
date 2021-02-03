defmodule AkrasiaWeb.Router do
  use AkrasiaWeb, :router

  import AkrasiaWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AkrasiaWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AkrasiaWeb do
    pipe_through :browser

    live "/", PageLive, :index
  end

  scope "/admin", AkrasiaWeb do
    pipe_through [:browser, :require_authenticated_admin_user]

    live "/weighings", WeighingGrid, :index, as: :weighing
    live "/users", UserGrid, :index, as: :user
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: AkrasiaWeb.Telemetry
    end
  end

  scope "/", AkrasiaWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", AkrasiaWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
    live "/diagram", WeighingDiagram
  end

  scope "/", AkrasiaWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end

  scope "/admin", AkrasiaWeb do
    pipe_through [:browser, :require_authenticated_admin_user]

    resources "/weighings", WeighingController, except: [:index]
    resources "/users", UserController, except: [:index]
  end
end
