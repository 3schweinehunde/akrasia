defmodule AkrasiaWeb.UserLive.Profile do
  @moduledoc """
  The user's own profile: name, height, public, target.

  Separate from UserLive.Settings (email, password), because that page needs
  sudo mode (logged in within the last 20 minutes), which is too strict for
  editing the height or the target weight. `admin` is not editable here.
  """
  use AkrasiaWeb, :live_view

  alias Akrasia.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm">
        <div class="text-center">
          <.header>
            {gettext("Profile")}
            <:subtitle>
              {gettext("Email address and password:")}
              <.link navigate={~p"/users/settings"} class="link font-semibold">
                {gettext("Account settings")}
              </.link>
            </:subtitle>
          </.header>
        </div>

        <.form for={@form} id="profile_form" phx-change="validate" phx-submit="save">
          <.input field={@form[:name]} type="text" label={gettext("Name")} required />
          <.input
            field={@form[:height]}
            type="number"
            label={gettext("Height (cm)")}
            step="1"
            min="50"
            max="300"
          />
          <.input
            field={@form[:target]}
            type="number"
            label={gettext("Target weight (kg)")}
            step="0.1"
          />
          <.input
            field={@form[:public]}
            type="checkbox"
            label={gettext("Public: other users can compare their BMI with mine")}
          />
          <.button variant="primary" phx-disable-with={gettext("Saving...")}>
            {gettext("Save profile")}
          </.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_profile(socket.assigns.current_scope.user)
    {:ok, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_profile(user_params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_user_profile(socket.assigns.current_scope.user, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(current_scope: %{socket.assigns.current_scope | user: user})
         |> assign(form: to_form(Accounts.change_user_profile(user)))
         |> put_flash(:info, gettext("Profile saved."))}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, action: :insert))}
    end
  end
end
