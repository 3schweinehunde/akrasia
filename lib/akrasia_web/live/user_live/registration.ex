defmodule AkrasiaWeb.UserLive.Registration do
  @moduledoc """
  Sign-up with email and name (#29); the account is confirmed through the
  magic link sent by email.

  Bot filter (#31): a hidden honeypot field ("website") that people don't
  see, and a minimum fill-in time (`config :akrasia, :signup_min_seconds`,
  default 3). Rate limit (#33): at most a few sign-up mails per client IP.
  A suspected bot gets the same answer as a person, so it learns nothing;
  no account is created and no email is sent.
  """
  use AkrasiaWeb, :live_view

  alias Akrasia.Accounts
  alias Akrasia.Accounts.User
  alias Akrasia.RateLimit
  alias AkrasiaWeb.ClientIP

  @default_min_seconds 3

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm">
        <div class="text-center">
          <.header>
            {gettext("Register for an account")}
            <:subtitle>
              {gettext("Already registered?")}
              <.link navigate={~p"/users/log-in"} class="link font-semibold">
                {gettext("Log in")}
              </.link>
            </:subtitle>
          </.header>
        </div>

        <.form for={@form} id="registration_form" phx-submit="save" phx-change="validate">
          <.input
            field={@form[:email]}
            type="email"
            label={gettext("Email")}
            autocomplete="username"
            spellcheck="false"
            required
            phx-mounted={JS.focus()}
          />
          <.input
            field={@form[:name]}
            type="text"
            label={gettext("Name")}
            autocomplete="nickname"
            required
          />
          <p class="mb-4 text-sm opacity-75">
            {gettext("Your name is shown to other users if you make your profile public.")}
          </p>

          <%!-- honeypot (#31): hidden from people, bots tend to fill it in --%>
          <div class="hidden" aria-hidden="true">
            <label for="registration_website">Website</label>
            <input
              type="text"
              id="registration_website"
              name="website"
              value=""
              tabindex="-1"
              autocomplete="off"
            />
          </div>

          <.button phx-disable-with={gettext("Creating account...")} class="btn btn-primary w-full">
            {gettext("Create an account")}
          </.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: AkrasiaWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{}, %{}, validate_unique: false)

    socket =
      socket
      |> assign(mounted_at: System.monotonic_time(:millisecond))
      |> assign(client_ip: ClientIP.from_socket(socket))
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params} = params, socket) do
    cond do
      bot?(params, socket) ->
        {:noreply, pretend_success(socket, user_params)}

      RateLimit.mail_request(socket.assigns.client_ip) == :error ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("Too many requests. Please try again in a few minutes."))
         |> assign_form(Accounts.change_user_registration(%User{}, user_params))}

      true ->
        register(socket, user_params)
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params, validate_unique: false)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp register(socket, user_params) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_login_instructions(
            user,
            &url(~p"/users/log-in/#{&1}")
          )

        {:noreply, pretend_success(socket, user_params)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  # the answer for people and bots alike
  defp pretend_success(socket, user_params) do
    socket
    |> put_flash(
      :info,
      gettext("An email was sent to %{email}, please access it to confirm your account.",
        email: user_params["email"]
      )
    )
    |> push_navigate(to: ~p"/users/log-in")
  end

  defp bot?(params, socket) do
    honeypot_filled? = String.trim(params["website"] || "") != ""
    elapsed_ms = System.monotonic_time(:millisecond) - socket.assigns.mounted_at

    honeypot_filled? or elapsed_ms < min_seconds() * 1000
  end

  defp min_seconds, do: Application.get_env(:akrasia, :signup_min_seconds, @default_min_seconds)

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end
