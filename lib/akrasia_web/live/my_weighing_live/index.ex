defmodule AkrasiaWeb.MyWeighingLive.Index do
  @moduledoc """
  "My Weighings" (#47): the logged-in user's weighings as a table, sortable
  by a fixed list of columns (#4: URL params are matched against strings,
  never turned into atoms), with simple paging.
  """
  use AkrasiaWeb, :live_view

  alias Akrasia.Weighings

  @per_page 20
  @sort_fields Map.new(Weighings.sortable_fields(), &{Atom.to_string(&1), &1})
  @sort_orders %{"asc" => :asc, "desc" => :desc}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("My Weighings")}
        <:actions>
          <.button variant="primary" navigate={~p"/weighings/new"}>
            <.icon name="hero-plus" /> {gettext("New weighing")}
          </.button>
        </:actions>
      </.header>

      <p :if={@count == 0} class="py-8 text-center opacity-75">
        {gettext("No weighings yet.")}
      </p>

      <div :if={@count > 0} class="overflow-x-auto rounded-box bg-base-100">
        <table id="weighings" class="table table-zebra">
          <thead>
            <tr>
              <th :for={{field, label} <- columns()}>
                <.link patch={sort_path(@sort_by, @sort_order, field)} class="link link-hover">
                  {label}
                  <.icon
                    :if={@sort_by == field}
                    name={if @sort_order == :asc, do: "hero-chevron-up", else: "hero-chevron-down"}
                    class="size-4"
                  />
                </.link>
              </th>
              <th><span class="sr-only">{gettext("Actions")}</span></th>
            </tr>
          </thead>
          <tbody>
            <tr :for={weighing <- @weighings} id={"weighing-#{weighing.id}"}>
              <td>{weighing.date}</td>
              <td>{weighing.weight}</td>
              <td>{weighing.abdominal_girth}</td>
              <td>{weighing.adipose}</td>
              <td class="flex justify-end gap-2">
                <.link navigate={~p"/weighings/#{weighing}/edit"} class="btn btn-ghost btn-xs">
                  {gettext("Edit")}
                </.link>
                <.link
                  phx-click={JS.push("delete", value: %{id: weighing.id})}
                  data-confirm={gettext("Are you sure?")}
                  class="btn btn-ghost btn-xs text-error"
                >
                  {gettext("Delete")}
                </.link>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div :if={@pages > 1} class="join mt-4">
        <.link
          :for={page <- 1..@pages}
          patch={~p"/weighings?#{%{sort_by: @sort_by, sort_order: @sort_order, page: page}}"}
          class={["join-item btn btn-sm", page == @page && "btn-active"]}
        >
          {page}
        </.link>
      </div>
    </Layouts.app>
    """
  end

  defp columns do
    [
      {:date, gettext("Date")},
      {:weight, gettext("Weight (kg)")},
      {:abdominal_girth, gettext("Abdominal girth (cm)")},
      {:adipose, gettext("Body fat (%)")}
    ]
  end

  defp sort_path(sort_by, sort_order, field) do
    order = if sort_by == field and sort_order == :asc, do: :desc, else: :asc
    ~p"/weighings?#{%{sort_by: field, sort_order: order}}"
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: gettext("My Weighings"))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(
       sort_by: Map.get(@sort_fields, params["sort_by"], :date),
       sort_order: Map.get(@sort_orders, params["sort_order"], :desc),
       page: parse_page(params["page"])
     )
     |> load_weighings()}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    weighing = Weighings.get_weighing!(scope, id)
    {:ok, _} = Weighings.delete_weighing(scope, weighing)

    {:noreply,
     socket
     |> put_flash(:info, gettext("Weighing deleted."))
     |> load_weighings()}
  end

  defp load_weighings(socket) do
    %{current_scope: scope, sort_by: sort_by, sort_order: sort_order} = socket.assigns
    count = Weighings.count_weighings(scope)
    pages = max(div(count + @per_page - 1, @per_page), 1)
    page = min(socket.assigns.page, pages)

    weighings =
      Weighings.list_weighings(scope,
        sort_by: sort_by,
        sort_order: sort_order,
        page: page,
        per_page: @per_page
      )

    assign(socket, weighings: weighings, count: count, pages: pages, page: page)
  end

  defp parse_page(value) do
    case Integer.parse(value || "") do
      {page, ""} when page > 0 -> page
      _ -> 1
    end
  end
end
