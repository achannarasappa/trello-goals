defmodule RepeaterTest do
  use ExUnit.Case
  alias Goals.Repeater, as: Repeater

  @card_other %{
    "name" => "other task"
  }
  @card_parsed_other %{
    "card" => @card_other,
    "date" => nil
  }
  @card_old_daily_goal %{
    "name" => "Daily Goals - January 29, 2018"
  }
  @card_current_daily_goal %{
    "name" => "Daily Goals - January 30, 2018"
  }
  @card_parsed_current_daily_goal %{
    "card" => @card_current_daily_goal,
    "date" => ~D[2018-01-30]
  }
  @trello_card_prefix "Daily Goals - "

  test "get_card_date" do
    assert Repeater.get_card_date(@card_current_daily_goal, @trello_card_prefix) ==
             @card_parsed_current_daily_goal

    assert Repeater.get_card_date(@card_other, @trello_card_prefix) == @card_parsed_other
  end

  test "is_card_for_today true" do
    assert Repeater.is_card_for_today(
             @card_parsed_current_daily_goal,
             Timex.to_date({2018, 1, 30})
           ) == true
  end

  test "is_card_for_today false" do
    assert Repeater.is_card_for_today(
             @card_parsed_other,
             Timex.to_date({2018, 1, 30})
           ) == false

    assert Repeater.is_card_for_today(@card_old_daily_goal, "invalid date") == false
  end

  test "filter_checklist_items mixed" do
    assert Repeater.filter_checklist_items(%{
             "checklists" => [
               %{
                 "name" => "mixed",
                 "checkItems" => [
                   %{
                     "state" => "complete"
                   },
                   %{
                     "state" => "incomplete"
                   },
                   %{
                     "state" => "other"
                   }
                 ]
               }
             ]
           }) == %{
             "checklists" => [
               %{
                 "name" => "mixed",
                 "checkItems" => [
                   %{
                     "state" => "incomplete"
                   }
                 ]
               }
             ]
           }
  end

  test "filter_checklist_items incomplete" do
    assert Repeater.filter_checklist_items(%{
             "checklists" => [
               %{
                 "name" => "incomplete",
                 "checkItems" => [
                   %{
                     "state" => "incomplete"
                   }
                 ]
               }
             ]
           }) == %{
             "checklists" => [
               %{
                 "name" => "incomplete",
                 "checkItems" => [
                   %{
                     "state" => "incomplete"
                   }
                 ]
               }
             ]
           }
  end

  test "filter_checklist_items complete" do
    assert Repeater.filter_checklist_items(%{
             "checklists" => [
               %{
                 "name" => "complete",
                 "checkItems" => [
                   %{
                     "state" => "complete"
                   }
                 ]
               }
             ]
           }) == nil
  end

  test "filter_checklist_items empty" do
    assert Repeater.filter_checklist_items(%{
             "checklists" => [
               %{
                 "name" => "empty",
                 "checkItems" => []
               }
             ]
           }) == nil
  end

  test "compare_cards" do
    assert Repeater.compare_cards(
             %{
               "card" => "next",
               "date" => ~D[2018-01-29]
             },
             %{
               "card" => "prev",
               "date" => ~D[2018-01-30]
             }
           ) ==
             %{
               "card" => "prev",
               "date" => ~D[2018-01-30]
             }

    assert Repeater.compare_cards(
             %{
               "card" => "next",
               "date" => ~D[2018-01-30]
             },
             %{
               "card" => "prev",
               "date" => ~D[2018-01-29]
             }
           ) ==
             %{
               "card" => "next",
               "date" => ~D[2018-01-30]
             }

    assert Repeater.compare_cards(
             %{
               "card" => "next",
               "date" => ~D[2018-01-30]
             },
             %{
               "card" => "prev",
               "date" => ~D[2018-01-30]
             }
           ) ==
             %{
               "card" => "prev",
               "date" => ~D[2018-01-30]
             }

    assert Repeater.compare_cards(
             %{
               "card" => "next",
               "date" => nil
             },
             %{
               "card" => "prev",
               "date" => ~D[2018-01-30]
             }
           ) ==
             %{
               "card" => "prev",
               "date" => ~D[2018-01-30]
             }
  end

  test "create_new_card card" do
    assert Repeater.create_new_card(
             %{
               "checklists" => [
                 %{
                   "name" => "test"
                 }
               ]
             },
             @trello_card_prefix,
             "12345",
             "UTC",
             ~D[2018-01-31]
           ) == {
             :create,
             %{
               "name" => "Daily Goals - January 31, 2018",
               "idList" => "12345",
               "checklists" => [
                 %{
                   "name" => "test"
                 }
               ],
               "closed" => false,
               "due" => "2018-01-31T22:00:00Z",
               "dueComplete" => false
             }
           }
  end

  test "create_new_card nil" do
    assert Repeater.create_new_card(
             nil,
             @trello_card_prefix,
             "12345",
             "UTC",
             ~D[2018-01-31]
           ) ==
             {:empty,
              %{
                "name" => "Daily Goals - January 31, 2018",
                "idList" => "12345",
                "checklists" => [],
                "closed" => false,
                "due" => "2018-01-31T22:00:00Z",
                "dueComplete" => false
              }}
  end

  test "get_daily_goal_card" do
    input_incomplete = [
      %{
        "name" => "Daily Goals - January 30, 2018",
        "checklists" => [
          %{
            "name" => "my checklist",
            "checkItems" => [
              %{
                "state" => "incomplete"
              }
            ]
          }
        ]
      },
      %{
        "name" => "Daily Goals - January 29, 2018"
      }
    ]

    input_complete =
      input_incomplete
      |> put_in(
        [
          Access.at(0),
          Access.key!("checklists"),
          Access.all(),
          Access.key!("checkItems"),
          Access.all(),
          Access.key!("state")
        ],
        "complete"
      )

    expected_exists = {:exists, nil}

    expected_empty =
      {:empty,
       %{
         "checklists" => [],
         "closed" => false,
         "due" => "2018-01-31T22:00:00Z",
         "dueComplete" => false,
         "idList" => "12345",
         "name" => "Daily Goals - January 31, 2018"
       }}

    expected_create =
      {:create,
       %{
         "checklists" => [
           %{
             "name" => "my checklist",
             "checkItems" => [
               %{
                 "state" => "incomplete"
               }
             ]
           }
         ],
         "closed" => false,
         "due" => "2018-01-31T22:00:00Z",
         "dueComplete" => false,
         "idList" => "12345",
         "name" => "Daily Goals - January 31, 2018"
       }}

    assert Repeater.get_daily_goal_card(
             input_incomplete,
             @trello_card_prefix,
             "12345",
             "UTC",
             ~D[2018-01-30]
           ) == expected_exists

    assert Repeater.get_daily_goal_card(
             [],
             @trello_card_prefix,
             "12345",
             "UTC",
             ~D[2018-01-31]
           ) == expected_empty

    assert Repeater.get_daily_goal_card(
             input_complete,
             @trello_card_prefix,
             "12345",
             "UTC",
             ~D[2018-01-31]
           ) == expected_empty

    assert Repeater.get_daily_goal_card(
             input_incomplete,
             @trello_card_prefix,
             "12345",
             "UTC",
             ~D[2018-01-31]
           ) == expected_create
  end

  test "get_list_id" do
    input_lists = [
      %{
        "id" => "abc",
        "name" => "Active List"
      },
      %{
        "id" => "def",
        "name" => "Other List"
      },
      %{
        "id" => "hij",
        "name" => "Inactive List"
      }
    ]

    assert Repeater.get_list_id(input_lists, "Active") == "abc"
  end
end