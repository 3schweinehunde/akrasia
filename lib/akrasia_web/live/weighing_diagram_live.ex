defmodule AkrasiaWeb.WeighingDiagramLive do
  @moduledoc """
  The BMI diagram, akrasia's main page: the user's BMI over time, optionally
  next to a public comparator, with a dashed line at the BMI of the target
  weight, and a quick form for a new weighing.

  The chart is drawn by the `BmiChart` hook (assets/js/bmi_chart.js, ECharts):
  initial data in data attributes, updates through push_event
  ("user-series", "comparator-series"). Fixes from the old diagram (#43):
  empty states instead of crashes without weighings or height (#1), the form
  is reset and "Last weighing" updated after saving (#2), one BMI function
  (#3), and only public users can be compared with.
  """
  use AkrasiaWeb, :live_view

  alias Akrasia.Weighings
  alias Akrasia.Weighings.Weighing

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="grid gap-8 lg:grid-cols-[1fr_20rem]">
        <section class="space-y-4">
          <div :if={is_nil(@user.height)} role="alert" class="alert alert-warning">
            <.icon name="hero-exclamation-triangle" class="size-6" />
            <span>
              {gettext("Enter your height in your profile to see your BMI.")}
              <.link navigate={~p"/users/profile"} class="link font-semibold">
                {gettext("Profile")}
              </.link>
            </span>
          </div>

          <p :if={@user.height && !@last_weighing} class="opacity-75">
            {gettext("No weighings yet. Enter your first weighing to start your diagram.")}
          </p>

          <div class="rounded-box bg-base-100 p-2">
            <div
              id="bmi-chart"
              phx-hook="BmiChart"
              phx-update="ignore"
              class="h-[28rem] w-full"
              data-name={@user.name}
              data-series={Jason.encode!(@series)}
              data-target-bmi={@target_bmi}
              data-target-label={gettext("Target BMI")}
            >
            </div>
          </div>
        </section>

        <aside class="space-y-8">
          <section>
            <h2 class="mb-2 text-xl">{gettext("Compare to")}</h2>
            <p :if={@comparators == []} class="text-sm opacity-75">
              {gettext("Nobody has made their profile public yet.")}
            </p>
            <ul :if={@comparators != []} id="comparators" class="menu w-full rounded-box bg-base-100">
              <li :for={comparator <- @comparators}>
                <button
                  type="button"
                  phx-click="compare"
                  phx-value-id={comparator.id}
                  class={@comparator_id == comparator.id && "menu-active"}
                >
                  {comparator.name}
                </button>
              </li>
              <li :if={@comparator_id}>
                <button type="button" phx-click="compare" phx-value-id="" class="opacity-75">
                  {gettext("Nobody")}
                </button>
              </li>
            </ul>
          </section>

          <section :if={@last_weighing} id="last-weighing">
            <h2 class="mb-2 text-xl">{gettext("Last weighing")}</h2>
            <p>{@last_weighing.date}: {@last_weighing.weight} kg</p>
          </section>

          <section>
            <h2 class="mb-2 text-xl">{gettext("New weighing")}</h2>
            <.form
              for={@form}
              id="weighing-form"
              phx-change="validate_weighing"
              phx-submit="create_weighing"
            >
              <.input field={@form[:date]} type="date" label={gettext("Date")} required />
              <.input
                field={@form[:weight]}
                type="number"
                label={gettext("Weight (kg)")}
                step="0.1"
                required
              />
              <.button variant="primary" phx-disable-with={gettext("Saving...")}>
                {gettext("Save")}
              </.button>
            </.form>
          </section>
        </aside>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    user = scope.user
    last_weighing = Weighings.last_weighing(scope)

    {:ok,
     socket
     |> assign(
       page_title: gettext("Diagram"),
       user: user,
       series: Weighings.bmi_series(user),
       target_bmi: Weighings.target_bmi(user),
       comparators: Weighings.list_comparators(scope),
       comparator_id: nil,
       last_weighing: last_weighing
     )
     |> assign_new_weighing_form(last_weighing)}
  end

  @impl true
  def handle_event("compare", %{"id" => ""}, socket) do
    {:noreply,
     socket
     |> assign(comparator_id: nil)
     |> push_event("comparator-series", %{name: nil, data: []})}
  end

  def handle_event("compare", %{"id" => id}, socket) do
    case Weighings.get_comparator(socket.assigns.current_scope, id) do
      nil ->
        # not public (any more) or a forged id: ignore
        {:noreply, socket}

      comparator ->
        {:noreply,
         socket
         |> assign(comparator_id: comparator.id)
         |> push_event("comparator-series", %{
           name: comparator.name,
           data: Weighings.bmi_series(comparator)
         })}
    end
  end

  def handle_event("validate_weighing", %{"weighing" => params}, socket) do
    changeset = Weighings.change_weighing(socket.assigns.current_scope, %Weighing{}, params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("create_weighing", %{"weighing" => params}, socket) do
    scope = socket.assigns.current_scope

    case Weighings.create_weighing(scope, params) do
      {:ok, _weighing} ->
        last_weighing = Weighings.last_weighing(scope)
        series = Weighings.bmi_series(socket.assigns.user)

        {:noreply,
         socket
         |> assign(last_weighing: last_weighing, series: series)
         |> assign_new_weighing_form(last_weighing)
         |> push_event("user-series", %{name: socket.assigns.user.name, data: series})
         |> put_flash(:info, gettext("Weighing saved."))}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # a fresh form: today, prefilled with the last weight
  defp assign_new_weighing_form(socket, last_weighing) do
    weighing = %Weighing{date: Date.utc_today(), weight: last_weighing && last_weighing.weight}
    changeset = Weighings.change_weighing(socket.assigns.current_scope, weighing)
    assign(socket, form: to_form(changeset, id: "weighing-#{System.unique_integer()}"))
  end
end
