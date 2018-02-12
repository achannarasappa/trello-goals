defmodule DailyGoals.Main do
  alias DailyGoals.Trello, as: Trello
  import Logger

  @moduledoc """
  Main module for DailyGoals
  """

  @type card :: %{
          name: String.t(),
          idList: String.t(),
          checklists: [checklist],
          closed: boolean(),
          due: String.t(),
          dueComplete: boolean()
        }

  @type checklist :: %{
          name: String.t(),
          idBoard: String.t(),
          idCard: String.t(),
          checkItems: [checklist_item]
        }

  @type checklist_item :: %{
          name: String.t(),
          state: String.t()
        }

  @type card_parsed :: %{
          card: card,
          date: Date.t() | nil
        }

  @type card_list :: %{
          id: String.t(),
          name: String.t()
        }

  @doc """
  Get card date
  """
  @spec get_card_date(card, String.t()) :: card_parsed
  def get_card_date(card, trello_card_prefix) do
    date =
      card
      |> Map.get("name")
      |> String.replace_prefix(trello_card_prefix, "")
      |> Timex.parse("{Mfull} {D}, {YYYY}")
      |> case do
        {:ok, date} ->
          date |> Timex.to_date()

        _ ->
          nil
      end

    %{
      "card" => card,
      "date" => date
    }
  end

  @doc """
  Check if there is a card for today
  """
  @spec is_card_for_today(card_parsed, Date.t()) :: boolean()
  def is_card_for_today(card_parsed, todays_date \\ Date.utc_today()) do
    card_parsed
    |> Map.get("date") == todays_date
  end

  @doc """
  Compare two parsed cards and return the one with the most recent date
  """
  @spec compare_cards(card_parsed, card_parsed) :: card_parsed
  def compare_cards(%{"date" => nil}, %{"date" => nil} = card_prev), do: card_prev
  def compare_cards(%{"date" => nil}, %{"date" => _} = card_prev), do: card_prev
  def compare_cards(%{"date" => _} = card_next, %{"date" => nil}), do: card_next

  def compare_cards(%{"date" => date_next} = card_next, %{"date" => date_prev} = card_prev) do
    Timex.compare(date_prev, date_next)
    |> case do
      -1 -> card_next
      0 -> card_prev
      1 -> card_prev
      _ -> card_prev
    end
  end

  @doc """
  Filter out complete checklist items
  """
  @spec filter_checklist_items(card) :: card | nil
  def filter_checklist_items(card) do
    card
    |> Map.get("checklists", [])
    |> Enum.map(fn checklist ->
      checklist
      |> Map.get("checkItems", [])
      |> Enum.filter(&(&1 |> Map.get("state") == "incomplete"))
      |> case do
        [] -> nil
        checkItems -> checklist |> Map.put("checkItems", checkItems)
      end
    end)
    |> Enum.reject(&is_nil(&1))
    |> case do
      [] -> nil
      checklists -> card |> Map.put("checklists", checklists)
    end
  end

  @doc """
  Create new daily goals card based on previous checklists
  """
  @spec create_new_card(card | nil, String.t(), String.t(), Date.t()) :: {atom(), card}
  def create_new_card(card, trello_card_prefix, trello_id_list, todays_date \\ Date.utc_today()) do
    {action, checklists} =
      card
      |> case do
        nil ->
          {:empty, []}

        _ ->
          card
          |> Map.get("checklists")
          |> (&{:create, &1}).()
      end

    date_string = Timex.format!(todays_date, "{Mfull} {D}, {YYYY}")

    {
      action,
      %{
        "name" => "#{trello_card_prefix}#{date_string}",
        "idList" => trello_id_list,
        "checklists" => checklists,
        "closed" => false,
        "due" => Timex.format!(todays_date, "{ISOdate}"),
        "dueComplete" => false
      }
    }
  end

  @doc """
  Get the daily goal card to create
  """
  @spec get_daily_goal_card([card], String.t(), String.t(), Date.t()) :: {atom(), card}
  def get_daily_goal_card(
        cards,
        trello_card_prefix,
        trello_id_list,
        todays_date \\ Date.utc_today()
      )

  def get_daily_goal_card(
        cards,
        trello_card_prefix,
        trello_id_list,
        todays_date
      )
      when length(cards) > 1 do
    cards
    |> Enum.map(&get_card_date(&1, trello_card_prefix))
    |> Enum.reduce(&compare_cards(&1, &2))
    |> List.wrap()
    |> get_daily_goal_card(trello_card_prefix, trello_id_list, todays_date)
  end

  def get_daily_goal_card(
        cards,
        trello_card_prefix,
        trello_id_list,
        todays_date
      )
      when length(cards) == 1 do
    cards
    |> Enum.reject(&is_card_for_today(&1, todays_date))
    |> case do
      [card] ->
        card
        |> Map.get("card")
        |> filter_checklist_items
        |> create_new_card(trello_card_prefix, trello_id_list, todays_date)

      _ ->
        {:exists, nil}
    end
  end

  def get_daily_goal_card(
        _,
        trello_card_prefix,
        trello_id_list,
        todays_date
      ) do
    create_new_card(nil, trello_card_prefix, trello_id_list, todays_date)
  end

  @doc """
  Get list that matches the target list name
  """
  @spec get_list_id([card_list], String.t()) :: String.t()
  def get_list_id(lists, trello_list_name) when length(lists) > 0 do
    lists
    |> Enum.map(fn list ->
      distance =
        list
        |> Map.get("name")
        |> String.jaro_distance(trello_list_name)

      {distance, list}
    end)
    |> Enum.reduce(fn {next_distance, _} = next, {prev_distance, _} = prev ->
      if next_distance > prev_distance do
        next
      else
        prev
      end
    end)
    |> elem(1)
    |> Map.get("id")
  end

  @doc """
  Run daily goals
  """
  def main() do
    config = Application.get_all_env(:app)

    list_id =
      Trello.get_list(
        config[:trello_api_key],
        config[:trello_oauth_token],
        config[:trello_board_id]
      )
      |> get_list_id(config[:trello_list_name])

    Trello.get_cards(
      config[:trello_api_key],
      config[:trello_oauth_token],
      config[:trello_board_id]
    )
    |> get_daily_goal_card(config[:trello_card_prefix], list_id)
    |> case do
      {:exists, _} ->
        Logger.info("Card already exists for today!")
        nil

      {_, card} ->
        Trello.create_card(
          config[:trello_api_key],
          config[:trello_oauth_token],
          card,
          list_id
        )
    end
  end
end
