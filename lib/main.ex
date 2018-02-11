defmodule DailyGoals.Main do
  alias DailyGoals.Trello, as: Trello

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

  @type card_parsed :: %{card: card, date: Date.t() | nil}

  @doc """
  Get card date
  """
  @spec get_card_date(card, String.t()) :: card_parsed
  def get_card_date(card, trello_card_prefix) do
    date =
      card
      |> Map.get(:name)
      |> String.replace_prefix(trello_card_prefix, "")
      |> Timex.parse("{Mfull} {D}, {YYYY}")
      |> case do
        {:ok, date} ->
          date |> Timex.to_date()

        _ ->
          nil
      end

    %{
      card: card,
      date: date
    }
  end

  @doc """
  Check if there is a card for today
  """
  @spec is_card_for_today(card_parsed, Date.t()) :: boolean()
  def is_card_for_today(card_parsed, todays_date \\ Date.utc_today()) do
    card_parsed
    |> Map.get(:date) == todays_date
  end

  @doc """
  Compare two parsed cards and return the one with the most recent date
  """
  @spec compare_cards(card_parsed, card_parsed) :: card_parsed
  def compare_cards(%{date: nil}, %{date: nil} = card_prev), do: card_prev
  def compare_cards(%{date: nil}, %{date: _} = card_prev), do: card_prev
  def compare_cards(%{date: _} = card_next, %{date: nil}), do: card_next

  def compare_cards(%{date: date_next} = card_next, %{date: date_prev} = card_prev) do
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
    |> Map.get(:checklists, [])
    |> Enum.map(fn checklist ->
      checklist
      |> Map.get(:checkItems, [])
      |> Enum.filter(&(&1 |> Map.get(:state) == "incomplete"))
      |> case do
        [] -> nil
        checkItems -> checklist |> Map.put(:checkItems, checkItems)
      end
    end)
    |> Enum.reject(&is_nil(&1))
    |> case do
      [] -> nil
      checklists -> card |> Map.put(:checklists, checklists)
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
          |> Map.get(:checklists)
          |> (&{:create, &1}).()
          |> IO.inspect()
      end

    date_string = Timex.format!(todays_date, "{Mfull} {D}, {YYYY}")

    {
      action,
      %{
        name: "#{trello_card_prefix}#{date_string}",
        idList: trello_id_list,
        checklists: checklists,
        closed: false,
        due: Timex.format!(todays_date, "{ISOdate}"),
        dueComplete: false
      }
    }
  end

  @doc """
  Run daily goals
  """
  def main() do
    # config = Application.get_all_env(:app)

    # cards =
    #   Trello.getCards(
    #     config[:trello_api_key],
    #     config[:trello_oauth_token],
    #     config[:trello_board_id]
    #   )
    #   |> filter_daily_goals
  end
end
