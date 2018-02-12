defmodule TrelloTest do
  use ExUnit.Case, async: false
  alias DailyGoals.Trello, as: Trello
  alias DailyGoals.TrelloApi, as: TrelloApi

  @trello_list_id "5890a23bc9d14f6ca9c4c2cd"

  setup_all do
    config = Application.get_all_env(:app)

    [
      :trello_api_key,
      :trello_oauth_token,
      :trello_board_id
    ]
    |> MapSet.new()
    |> MapSet.subset?(config |> Keyword.keys() |> MapSet.new())
    |> case do
      false -> raise "Environment variables for testing not set!"
      _ -> config
    end
  end

  # setup do
  #   :timer.sleep(5000)
  # end

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

  @tag :io_read
  test "get_list", config do
    expected = ["closed", "id", "name"]

    assert Trello.get_list(
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
      "checklists",
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

    input_card = %{
      "name" => "test trello card",
      "checklists" => [
        %{
          "name" => "test trello checklist 1",
          "checkItems" => [
            %{
              "name" => "to do 1",
              "checked" => false
            }
          ]
        },
        %{
          "name" => "test trello checklist 2",
          "checkItems" => [
            %{
              "name" => "to do 2",
              "checked" => true
            }
          ]
        }
      ]
    }

    response =
      Trello.create_card(
        config[:trello_api_key],
        config[:trello_oauth_token],
        input_card,
        @trello_list_id
      )

    assert response
           |> Map.keys() == expected_properties

    assert response
           |> get_in([
             Access.key!("name")
           ]) == "test trello card"

    assert response
           |> get_in([
             Access.key!("checklists"),
             Access.all(),
             Access.key!("name")
           ]) == ["test trello checklist 1", "test trello checklist 2"]

    assert response
           |> get_in([
             Access.key!("checklists"),
             Access.all(),
             Access.key!("checkItems"),
             Access.all(),
             Access.key!("name")
           ]) == [["to do 1"], ["to do 2"]]

    assert response
           |> get_in([
             Access.key!("checklists"),
             Access.all(),
             Access.key!("checkItems"),
             Access.all(),
             Access.key!("state")
           ]) == [["incomplete"], ["complete"]]
  end
end
