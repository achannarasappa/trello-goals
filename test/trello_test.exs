defmodule TrelloTest do
  use ExUnit.Case
  alias DailyGoals.Trello, as: Trello

  @required_env [
    :trello_api_key,
    :trello_oauth_token,
    :trello_board_id
  ]

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

  @tag :io
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

  @tag :io
  test "create_card" do
    assert true == true
  end
end
