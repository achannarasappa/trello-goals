defmodule DailyGoals.Trello do
  alias DailyGoals.TrelloApi, as: TrelloApi
  import DailyGoals.Util
  import Logger

  @doc """
  Get cards from trello
  """
  def get_cards(api_key, oath_token, board_id) do
    query_string = [
      checklists: "all",
      checklist_fields: "name",
      fields: "id,name,closed,due,dueComplete,idList",
      key: api_key,
      token: oath_token
    ]

    Logger.debug("Requesting cards for #{board_id}")

    TrelloApi.start()

    TrelloApi.get!("/boards/#{board_id}/cards/open?" <> buildQueryString(query_string))
    |> Map.get(:body)
  end
end
