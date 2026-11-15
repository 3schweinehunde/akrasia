defmodule AkrasiaWeb.PageHTML do
  @moduledoc """
  Pages rendered by PageController: home, imprint and privacy.

  The imprint and privacy texts are legal content and are not translated
  through gettext.
  """
  use AkrasiaWeb, :html

  embed_templates "page_html/*"
end
