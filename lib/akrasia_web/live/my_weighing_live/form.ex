defmodule AkrasiaWeb.MyWeighingLive.Form do
  @moduledoc """
  New and edit form for the logged-in user's own weighings, with the
  optional abdominal girth and body fat (user, 2026-11-15).
  """
  use AkrasiaWeb, :live_view

  alias Akrasia.Weighings
  alias Akrasia.Weighings.Weighing

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm">
        <.header>{@page_title}</.header>

        <.form for={@form} id="weighing-form" phx-change="validate" phx-submit="save">
          <.input field={@form[:date]} type="date" label={gettext("Date")} required />
          <.input
            field={@form[:weight]}
            type="number"
            label={gettext("Weight (kg)")}
            step="0.1"
            required
          />
          <.input
            field={@form[:abdominal_girth]}
            type="number"
            label={gettext("Abdominal girth (cm, optional)")}
            step="1"
          />
          <.input
            field={@form[:adipose]}
            type="number"
            label={gettext("Body fat (%, optional)")}
            step="0.1"
          />
          <div class="flex gap-2">
            <.button variant="primary" phx-disable-with={gettext("Saving...")}>
              {gettext("Save")}
            </.button>
            <.button navigate={~p"/weighings"}>{gettext("Cancel")}</.button>
          </div>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    weighing = %Weighing{date: Date.utc_today()}

    socket
    |> assign(page_title: gettext("New weighing"), weighing: weighing)
    |> assign(form: to_form(Weighings.change_weighing(socket.assigns.current_scope, weighing)))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    scope = socket.assigns.current_scope
    weighing = Weighings.get_weighing!(scope, id)

    socket
    |> assign(page_title: gettext("Edit weighing"), weighing: weighing)
    |> assign(form: to_form(Weighings.change_weighing(scope, weighing)))
  end

  @impl true
  def handle_event("validate", %{"weighing" => params}, socket) do
    changeset =
      Weighings.change_weighing(socket.assigns.current_scope, socket.assigns.weighing, params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"weighing" => params}, socket) do
    save(socket, socket.assigns.live_action, params)
  end

  defp save(socket, :new, params) do
    case Weighings.create_weighing(socket.assigns.current_scope, params) do
      {:ok, _weighing} -> saved(socket, gettext("Weighing created."))
      {:error, changeset} -> {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save(socket, :edit, params) do
    scope = socket.assigns.current_scope

    case Weighings.update_weighing(scope, socket.assigns.weighing, params) do
      {:ok, _weighing} -> saved(socket, gettext("Weighing updated."))
      {:error, changeset} -> {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp saved(socket, message) do
    {:noreply, socket |> put_flash(:info, message) |> push_navigate(to: ~p"/weighings")}
  end
end
