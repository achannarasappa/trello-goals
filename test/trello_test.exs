defmodule TrelloTest do
  use ExUnit.Case
  alias DailyGoals.Trello, as: Trello

  @required_env [
    :trello_api_key,
    :trello_oauth_token,
    :trello_board_id
  ]
  @trello_list_id "5890a23bc9d14f6ca9c4c2cd"

  setup_all do
    config = Application.get_all_env(:app)

    @required_env
    |> MapSet.new()
    |> MapSet.subset?(config |> Keyword.keys() |> MapSet.new())
    |> IO.inspect()
    |> case do
      false -> raise "Environment variables for testing not set!"
      _ -> config
    end
  end

  @tag :io_read
  test "get_cards", config do
    expected = ["checklists", "closed", "due", "dueComplete", "id", "idList", "name"]

    assert Trello.get_cards(
             config[:trello_api_key],
             config[:trello_oauth_token],
             config[:trello_board_id]
           )
           |> hd
           |> Map.keys() == expected
  end

  @tag :io_write
  test "create_card", config do
    expected_properties = [
      "badges",
      "checkItemStates",
      "closed",
      "dateLastActivity",
      "desc",
      "descData",
      "due",
      "dueComplete",
      "email",
      "id",
      "idAttachmentCover",
      "idBoard",
      "idChecklists",
      "idLabels",
      "idList",
      "idMembers",
      "idMembersVoted",
      "idShort",
      "labels",
      "limits",
      "manualCoverAttachment",
      "name",
      "pos",
      "shortLink",
      "shortUrl",
      "stickers",
      "subscribed",
      "url"
    ]

    expected_card_name = "test trello card"
    expected_checklist_name = "test trello checklist"

    response =
      Trello.create_card(
        config[:trello_api_key],
        config[:trello_oauth_token],
        %{
          name: expected_card_name,
          checklists: [
            %{
              name: expected_checklist_name,
              checkItems: [
                %{
                  name: "to do 1",
                  checked: false
                }
              ]
            },
            %{
              name: "test trello checklist 2",
              checkItems: [
                %{
                  name: "to do 2",
                  checked: true
                }
              ]
            }
          ]
        },
        @trello_list_id
      )
      |> IO.inspect()

    assert response
           |> Map.keys() == expected_properties

    assert response
           |> Map.get("name") == expected_card_name

    assert response
           |> Map.get("checklists")
           |> hd
           |> Map.get("name") == expected_checklist_name

    assert response
           |> Map.get("checklists")
           |> length == 2
  end
end
