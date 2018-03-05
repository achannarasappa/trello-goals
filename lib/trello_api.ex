defmodule Goals.TrelloApi do
  import Goals.Util
  require Logger

  @base_url "https://api.trello.com/1"

  def get(query_params, url) do
    HTTPoison.get!(@base_url <> url <> "?" <> buildQueryString(query_params))
    |> handle_response
  end

  def post(payload, url) do
    json_payload = Poison.encode!(payload)

    HTTPoison.post!(@base_url <> url, json_payload, [{"Content-Type", "application/json"}])
    |> handle_response
  end

  defp handle_response(response) do
    response
    |> case do
      %HTTPoison.Response{body: body, status_code: 200} ->
        Poison.decode!(body)

      %HTTPoison.Response{body: body, status_code: _} ->
        Logger.error(body)
        raise body
    end
  end
end