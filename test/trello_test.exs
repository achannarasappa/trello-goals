defmodule TrelloTest do
  use ExUnit.Case
  alias DailyGoals.Trello, as: Trello

  @tag :only
  @tag :io
  test "gets cards" do
    config = Application.get_all_env(:app)
    expected = ["checklists", "closed", "due", "dueComplete", "id", "idList", "name"]

    assert Trello.getCards(
             config[:trello_api_key],
             config[:trello_oauth_token],
             config[:trello_board_ids]
           )
           |> hd
           |> Map.keys == expected
  end
end
