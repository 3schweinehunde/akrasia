defmodule AkrasiaWeb.Surface.Grid do
  use Surface.Component

  prop target, :module
  prop per_page, :integer
  prop current_page, :integer
end
