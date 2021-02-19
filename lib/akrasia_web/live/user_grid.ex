defmodule AkrasiaWeb.UserGrid do
  use Surface.LiveView
  alias AkrasiaWeb.Surface.Grid

  def mount(_params, _session, socket) do
    columns = [
      %{field: :id,
        name: "ID",
        sortable: true,
        searchable: true},
      %{field: :name,
        name: "Name",
        sortable: true,
        searchable: true},
      %{field: :email,
        name: "Email",
        sortable: true,
        searchable: true},
      %{field: :confirmed_at,
        name: "Confirmed at",
        sortable: true,
        searchable: true},
      %{field: :admin,
        name: "Admin",
        sortable: true,
        searchable: true},
      %{field: :height,
        name: "Height",
        sortable: true,
        searchable: true},
      %{field: :public,
        name: "Public",
        sortable: true,
        searchable: true},
      %{field: :target,
        name: "Target",
        sortable: true,
        searchable: true},
      %{field: :invitation_limit,
        name: "Invitation_limit",
        sortable: true,
        searchable: true},
      %{field: :inserted_at,
        name: "Inserted at",
        sortable: true,
        searchable: true},
      %{field: :updated_at,
        name: "Updated at",
        sortable: true,
        searchable: true},
    ]

    socket = assign(socket, options: %{}, columns: columns)
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    paginate_options =
      %{page: String.to_integer(params["page"] || "1"),
        per_page: String.to_integer(params["per_page"] || "10")}
    sort_options =
      %{sort_by: (params["sort_by"] || "id") |> String.to_atom(),
        sort_order: (params["sort_order"] || "asc") |> String.to_atom()}

    socket = assign(socket, options: Map.merge(paginate_options, sort_options))
    {:noreply, socket}
  end
end
