defmodule DailyGoals.Trello do
  alias DailyGoals.TrelloApi, as: TrelloApi
  import DailyGoals.Util
  import Logger

  @doc """
  Get trello cards
  """
  def get_cards(api_key, oath_token, board_id) do
    query_string = [
      checklists: "all",
      checklist_fields: "name",
      fields: "id,name,closed,due,dueComplete,idList",
      key: api_key,
      token: oath_token
    ]

    Logger.debug("Requesting cards for board #{board_id}")

    TrelloApi.start()

    TrelloApi.get!("/boards/#{board_id}/cards/open?" <> buildQueryString(query_string))
    |> Map.get(:body)
  end

  @doc """
  Create trello card
  """
  def create_card(api_key, oath_token, card, list_id) do
    Logger.debug("Creating card on list #{list_id}")

    payload =
      card
      |> Map.merge(%{
        key: api_key,
        token: oath_token,
        idList: list_id
      })

    TrelloApi.start()

    card =
      TrelloApi.post!("/cards", payload)
      |> Map.get(:body)
  end
end
