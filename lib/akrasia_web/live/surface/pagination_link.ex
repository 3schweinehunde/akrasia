defmodule AkrasiaWeb.Surface.PaginationLink do
  use Surface.Component

  prop page, :integer
  prop per_page, :integer
  prop disabled, :boolean

  slot default, required: true
end
