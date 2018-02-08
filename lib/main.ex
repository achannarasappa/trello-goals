defmodule DailyGoals.Main do
  @moduledoc """
  Main module for DailyGoals
  """

  @type card :: %{
          id: String.t(),
          name: String.t(),
          idList: String.t(),
          checklists: [],
          closed: boolean(),
          due: String.t(),
          dueComplete: String.t()
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
