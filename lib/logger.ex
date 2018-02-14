defmodule Goals.Logger do
  import Poison

  def format(level, message, _, metadata) do
    "\n" <>
      Poison.encode!(%{
        time: DateTime.utc_now() |> DateTime.to_iso8601(),
        level: level,
        msg: message,
        meta: %{
          function: metadata[:function],
          module: metadata[:module]
        }
      })
  end
end
