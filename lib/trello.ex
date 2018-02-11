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
  Create trello checklists and checklist items
  """
  defp create_checklist(api_key, oath_token, checklist, card_id) do
    checklist_payload =
      checklist
      |> Map.take(["name", "pos"])
      |> Map.merge(%{
        "key" => api_key,
        "token" => oath_token,
        "idCard" => card_id
      })

    checklist_response =
      TrelloApi.post!("/checklists", checklist_payload)
      |> Map.get(:body)

    checklist_id =
      checklist_response
      |> Map.get("id")

    Logger.debug("Created checklist #{checklist_id} on card #{card_id}")

    check_item_responses =
      checklist
      |> Map.get("checkItems")
      |> Enum.map(fn check_item ->
        query_string =
          buildQueryString(%{
            "key" => api_key,
            "token" => oath_token
          })

        check_item_payload =
          check_item
          |> Map.take(["name", "pos", "checked"])
          |> Map.merge(%{
            "key" => api_key,
            "token" => oath_token
          })

        check_item_response =
          TrelloApi.post!("/checklists/#{checklist_id}/checkItems", check_item_payload)
          |> Map.get(:body)

        check_item_id =
          check_item_response
          |> Map.get("id")

        Logger.debug("Created checklist_item #{check_item_id} on checklist #{checklist_id}")

        check_item_response
      end)

    checklist_response
    |> Map.put("checkItems", check_item_responses)
  end

  @doc """
  Create trello card, checklists, and checklist items
  """
  def create_card(api_key, oath_token, card, list_id) do
    card_payload =
      card
      |> Map.merge(%{
        key: api_key,
        token: oath_token,
        idList: list_id
      })

    TrelloApi.start()

    card_response =
      TrelloApi.post!("/cards", card_payload)
      |> Map.get(:body)

    card_id =
      card_response
      |> Map.get("id")

    Logger.debug("Created card #{card_id} on list #{list_id}")

    checklist_responses =
      card
      |> Map.get("checklists")
      |> Enum.map(&create_checklist(api_key, oath_token, &1, card_id))

    card_response
    |> Map.put("checklists", checklist_responses)
  end
end
