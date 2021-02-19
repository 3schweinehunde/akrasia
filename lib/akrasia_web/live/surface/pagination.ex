defmodule AkrasiaWeb.Surface.Pagination do
  use Surface.Component
  alias AkrasiaWeb.Surface.PaginationLink

  prop per_page, :integer
  prop current_page, :integer
end
