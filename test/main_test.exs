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
  @trello_card_prefix "Daily Goals - "

  @tag :only
  test "is_card_daily_goals" do
    assert Main.is_card_daily_goals(
             @card_current_daily_goal,
             @trello_card_prefix
           ) == true

    assert Main.is_card_daily_goals(
             @card_other,
             @trello_card_prefix
           ) == false
  end

  @tag :only
  test "is_card_for_today true" do
    assert Main.is_card_for_today(
             @card_current_daily_goal,
             @trello_card_prefix,
             Timex.to_date({2018, 1, 30})
           ) == true
  end

  @tag :only
  test "is_card_for_today false" do
    assert Main.is_card_for_today(
             @card_old_daily_goal,
             @trello_card_prefix,
             Timex.to_date({2018, 1, 30})
           ) == false

    assert Main.is_card_for_today(@card_old_daily_goal, @trello_card_prefix, "invalid date") ==
             false
  end
end
