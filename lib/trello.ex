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

  defp create_check_item(api_key, oath_token, check_item, checklist_id) do
    response =
      %{"id" => id} =
      check_item
      |> Map.take(["name", "pos", "checked"])
      |> Map.merge(%{
        "key" => api_key,
        "token" => oath_token
      })
      |> (&TrelloApi.post!("/checklists/#{checklist_id}/checkItems", &1)).()
      |> Map.get(:body)

    Logger.debug("Created checklist_item #{id} on checklist #{checklist_id}")

    response
  end

  @doc """
  Create trello checklists and checklist items
  """
  defp create_checklist(api_key, oath_token, checklist, card_id) do
    response =
      %{"id" => id} =
      checklist
      |> Map.take(["name", "pos"])
      |> Map.merge(%{
        "key" => api_key,
        "token" => oath_token,
        "idCard" => card_id
      })
      |> (&TrelloApi.post!("/checklists", &1)).()
      |> Map.get(:body)

    Logger.debug("Created checklist #{id} on card #{card_id}")

    check_item_responses =
      checklist
      |> Map.get("checkItems")
      |> Enum.map(&create_check_item(api_key, oath_token, &1, id))

    response
    |> Map.put("checkItems", check_item_responses)
  end

  @doc """
  Create trello card, checklists, and checklist items
  """
  def create_card(api_key, oath_token, %{"checklists" => checklists} = card, list_id) do
    TrelloApi.start()

    response =
      %{"id" => id} =
      card
      |> Map.merge(%{
        "key" => api_key,
        "token" => oath_token,
        "idList" => list_id
      })
      |> (&TrelloApi.post!("/cards", &1)).()
      |> Map.get(:body)

    Logger.debug("Created card #{id} on list #{list_id}")

    checklist_responses =
      checklists
      |> Enum.map(&create_checklist(api_key, oath_token, &1, id))

    response
    |> Map.put("checklists", checklist_responses)
  end
end
