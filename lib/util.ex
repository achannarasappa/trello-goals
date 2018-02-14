defmodule Goals.Util do
  def buildQueryString(map) do
    map
    |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)
    |> Enum.join("&")
  end
end
