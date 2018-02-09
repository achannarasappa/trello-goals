defmodule MainTest do
  use ExUnit.Case
  alias DailyGoals.Main, as: Main

  @card_other %{
    name: "other task"
  }
  @card_parsed_other %{
    card: @card_other,
    date: nil
  }
  @card_old_daily_goal %{
    name: "Daily Goals - January 29, 2018"
  }
  @card_current_daily_goal %{
    name: "Daily Goals - January 30, 2018"
  }
  @card_parsed_current_daily_goal %{
    card: @card_current_daily_goal,
    date: ~D[2018-01-30]
  }
  @trello_card_prefix "Daily Goals - "

  test "get_card_date" do
    assert Main.get_card_date(@card_current_daily_goal, @trello_card_prefix) ==
             @card_parsed_current_daily_goal

    assert Main.get_card_date(@card_other, @trello_card_prefix) == @card_parsed_other
  end

  test "is_card_for_today true" do
    assert Main.is_card_for_today(
             @card_parsed_current_daily_goal,
             Timex.to_date({2018, 1, 30})
           ) == true
  end

  test "is_card_for_today false" do
    assert Main.is_card_for_today(
             @card_parsed_other,
             Timex.to_date({2018, 1, 30})
           ) == false

    assert Main.is_card_for_today(@card_old_daily_goal, "invalid date") == false
  end

  test "filter_checklist_items mixed" do
    assert Main.filter_checklist_items(%{
             checklists: [
               %{
                 name: "mixed",
                 checkItems: [
                   %{
                     state: "complete"
                   },
                   %{
                     state: "incomplete"
                   },
                   %{
                     state: "other"
                   }
                 ]
               }
             ]
           }) == %{
             checklists: [
               %{
                 name: "mixed",
                 checkItems: [
                   %{
                     state: "incomplete"
                   }
                 ]
               }
             ]
           }
  end

  test "filter_checklist_items incomplete" do
    assert Main.filter_checklist_items(%{
             checklists: [
               %{
                 name: "incomplete",
                 checkItems: [
                   %{
                     state: "incomplete"
                   }
                 ]
               }
             ]
           }) == %{
             checklists: [
               %{
                 name: "incomplete",
                 checkItems: [
                   %{
                     state: "incomplete"
                   }
                 ]
               }
             ]
           }
  end

  test "filter_checklist_items complete" do
    assert Main.filter_checklist_items(%{
             checklists: [
               %{
                 name: "complete",
                 checkItems: [
                   %{
                     state: "complete"
                   }
                 ]
               }
             ]
           }) == nil
  end

  test "filter_checklist_items empty" do
    assert Main.filter_checklist_items(%{
             checklists: [
               %{
                 name: "empty",
                 checkItems: []
               }
             ]
           }) == nil
  end

  test "compare_cards" do
    assert Main.compare_cards(
             %{
               card: "next",
               date: ~D[2018-01-29]
             },
             %{
               card: "prev",
               date: ~D[2018-01-30]
             }
           ) ==
             %{
               card: "prev",
               date: ~D[2018-01-30]
             }

    assert Main.compare_cards(
             %{
               card: "next",
               date: ~D[2018-01-30]
             },
             %{
               card: "prev",
               date: ~D[2018-01-29]
             }
           ) ==
             %{
               card: "next",
               date: ~D[2018-01-30]
             }

    assert Main.compare_cards(
             %{
               card: "next",
               date: ~D[2018-01-30]
             },
             %{
               card: "prev",
               date: ~D[2018-01-30]
             }
           ) ==
             %{
               card: "prev",
               date: ~D[2018-01-30]
             }

    assert Main.compare_cards(
             %{
               card: "next",
               date: nil
             },
             %{
               card: "prev",
               date: ~D[2018-01-30]
             }
           ) ==
             %{
               card: "prev",
               date: ~D[2018-01-30]
             }
  end

  test "create_new_card card" do
    assert Main.create_new_card(
             %{
               checklists: [
                 %{
                   name: "test"
                 }
               ]
             },
             @trello_card_prefix,
             "12345",
             ~D[2018-01-31]
           ) == %{
             name: "Daily Goals - January 31, 2018",
             idList: "12345",
             checklists: [
               %{
                 name: "test"
               }
             ],
             closed: false,
             due: "2018-01-31",
             dueComplete: false
           }
  end

  test "create_new_card nil" do
    assert Main.create_new_card(nil, @trello_card_prefix, "12345", ~D[2018-01-31]) == %{
             name: "Daily Goals - January 31, 2018",
             idList: "12345",
             checklists: [],
             closed: false,
             due: "2018-01-31",
             dueComplete: false
           }
  end
end
