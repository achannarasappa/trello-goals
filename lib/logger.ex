defmodule DailyGoals.Logger do
  def format(level, message, timestamp, metadata) do
    "\n{\"timestamp\": \"#{DateTime.utc_now() |> DateTime.to_iso8601()}\", \"level\": \"#{level}\", \"message\": \"#{
      message
    }\"}\n"
  end
end
