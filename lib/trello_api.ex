defmodule DailyGoals.TrelloApi do
  use HTTPoison.Base
  import Poison

  def process_url(url) do
    "https://api.trello.com/1" <> url
  end

  def process_response_body(body) do
    Poison.decode!(body)
  end

  def process_request_headers(headers) do
    Enum.into(headers, [{"Content-Type", "application/json"}])
  end

  def process_request_body(body) do
    Poison.encode!(body)
  end
end
