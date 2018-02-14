defmodule GoalsUtilTest do
  use ExUnit.Case
  import Goals.Util

  test "build query string" do
    input = [
      a: 1,
      b: 2
    ]

    expected = "a=1&b=2"

    assert buildQueryString(input) == expected
  end
end
