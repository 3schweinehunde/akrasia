defmodule AkrasiaWeb.ClientIPTest do
  use ExUnit.Case, async: true

  alias AkrasiaWeb.ClientIP

  test "prefers X-Real-IP" do
    assert ClientIP.from_headers([
             {"x-forwarded-for", "1.1.1.1, 2.2.2.2"},
             {"x-real-ip", " 3.3.3.3 "}
           ]) == "3.3.3.3"
  end

  test "takes the last X-Forwarded-For entry (the one the proxy added)" do
    assert ClientIP.from_headers([{"x-forwarded-for", "6.6.6.6, 2.2.2.2"}]) == "2.2.2.2"
  end

  test "returns nil without proxy headers" do
    assert ClientIP.from_headers([{"x-other", "x"}]) == nil
  end
end
