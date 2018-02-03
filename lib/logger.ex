defmodule DailyGoals.Logger do
  import Poison

  def format(level, message, _, metadata) do
    Poison.encode!(%{
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      level: level,
      message: message,
      meta: %{
        function: metadata[:function],
        module: metadata[:module],
      }
    })
  end
end
