defmodule MainTest do
  use ExUnit.Case
  alias DailyGoals.Main, as: Main

  @card_other %{
    id: "5a6e037b5588952e9ec06eb4",
    name: "other task",
    closed: false,
    idList: "5890a23dead748db3fcbec31",
    due: "2018-01-29T02:00:00.000Z",
    dueComplete: false,
    checklists: []
  }
  @card_old_daily_goal %{
    id: "5a6e037b5588952e9ec06eb4",
    name: "Daily Goals - January 29, 2018",
    closed: false,
    idList: "5890a23dead748db3fcbec31",
    due: "2018-01-29T02:00:00.000Z",
    dueComplete: false,
    checklists: []
  }
  @card_current_daily_goal %{
    id: "5a6e037b5588952e9ec06eb4",
    name: "Daily Goals - January 30, 2018",
    closed: false,
    idList: "5890a23dead748db3fcbec31",
    due: "2018-01-29T02:00:00.000Z",
    dueComplete: false,
    checklists: []
  }

  @tag :only
  test "filtering daily goals" do
  
    trello_card_prefix = config = Application.get_env(:app, :trello_card_prefix)
    input = [ @card_other, @card_old_daily_goal, @card_current_daily_goal ]
    output = [ @card_old_daily_goal, @card_current_daily_goal ]

    assert Main.filter_daily_goals(input, trello_card_prefix) == output
  
  end
  

end
