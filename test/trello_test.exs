defmodule TrelloTest do
  use ExUnit.Case
  alias DailyGoals.Trello, as: Trello

  @tag :io
  test "gets cards response properties" do
    config = Application.get_all_env(:app)
    expected = ["checklists", "closed", "due", "dueComplete", "id", "idList", "name"]

    assert Trello.get_cards(
             config[:trello_api_key],
             config[:trello_oauth_token],
             config[:trello_board_id]
           )
           |> hd
           |> Map.keys() == expected
  end
end
