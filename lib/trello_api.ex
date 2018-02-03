defmodule DailyGoals.TrelloApi do
  use HTTPoison.Base
  import Poison

  def process_url(url) do
    "https://api.trello.com/1" <> url
  end

  def process_response_body(body) do
    IO.inspect(body)

    Poison.decode!(body)
  end
end
