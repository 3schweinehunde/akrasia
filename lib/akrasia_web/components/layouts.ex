defmodule AkrasiaWeb.Layouts do
  @moduledoc """
  Layouts and related function components: the root layout (root.html.heex),
  the app layout with navbar and footer, the flash group and the theme toggle.
  """
  use AkrasiaWeb, :html

  embed_templates "layouts/*"

  @doc """
  Renders the app layout: navbar with the user menu, main content, footer.

  ## Examples

      <Layouts.app flash={@flash} current_scope={@current_scope}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://phoenix.hexdocs.pm/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar bg-base-100 shadow-sm px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href={~p"/"} class="text-2xl">Akrasia</a>
      </div>
      <nav class="flex-none">
        <ul class="flex flex-wrap items-center gap-x-4 gap-y-2 px-1">
          <%= if @current_scope && @current_scope.user do %>
            <li class="text-sm opacity-75">{@current_scope.user.email}</li>
            <li><.link navigate={~p"/weighings"} class="link">{gettext("My Weighings")}</.link></li>
            <li><.link navigate={~p"/diagram"} class="link">{gettext("Diagram")}</.link></li>
            <li :if={@current_scope.user.admin}>
              <.link navigate={~p"/admin/users"} class="link">{gettext("Admin")}</.link>
            </li>
            <li>
              <.link navigate={~p"/users/profile"} class="link">{gettext("Profile")}</.link>
            </li>
            <li>
              <.link href={~p"/users/log-out"} method="delete" class="link">
                {gettext("Log out")}
              </.link>
            </li>
          <% else %>
            <li><.link href={~p"/users/register"} class="link">{gettext("Register")}</.link></li>
            <li><.link href={~p"/users/log-in"} class="link">{gettext("Log in")}</.link></li>
          <% end %>
          <li><.theme_toggle /></li>
        </ul>
      </nav>
    </header>

    <main class="flex-1 px-4 py-8 sm:px-6 lg:px-8">
      {render_slot(@inner_block)}
    </main>

    <footer class="footer footer-horizontal footer-center bg-base-100 p-4 text-sm">
      <nav class="grid-flow-col gap-6">
        <span>
          <a href="https://akrasia.informatom.com" class="link">Akrasia</a>
          @ <a href="http://www.mittenin.at" class="link">Mittenin.at</a>
        </span>
        <.link href={~p"/imprint"} class="link">{gettext("Imprint")}</.link>
        <.link href={~p"/privacy"} class="link">{gettext("Privacy")}</.link>
      </nav>
    </footer>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Latte / System / Mocha theme switch, same logic as in pan.

  The buttons only carry `data-theme-choice`; assets/js/theme_toggle.js
  handles the clicks, stores the choice and marks the active button. The
  script in root.html.heex applies a stored choice before the first paint.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="join" role="group" aria-label={gettext("Theme")}>
      <button
        type="button"
        class="btn btn-xs join-item"
        data-theme-choice="latte"
        title={gettext("Light (Latte)")}
      >
        <.icon name="hero-sun-micro" class="size-4" />
      </button>
      <button
        type="button"
        class="btn btn-xs join-item"
        data-theme-choice="system"
        title={gettext("Like the system")}
      >
        <.icon name="hero-computer-desktop-micro" class="size-4" />
      </button>
      <button
        type="button"
        class="btn btn-xs join-item"
        data-theme-choice="mocha"
        title={gettext("Dark (Mocha)")}
      >
        <.icon name="hero-moon-micro" class="size-4" />
      </button>
    </div>
    """
  end
end
