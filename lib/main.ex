defmodule DailyGoals.Main do
  @moduledoc """
  Main module for DailyGoals
  """

  @doc """
  Check if card is a daily goal card 
  """
  def is_card_daily_goals(card, trello_card_prefix) do
    String.starts_with?(Map.get(card, :name), trello_card_prefix)
  end

  @doc """
  Check if there is a card for today
  """
  def is_card_for_today(card, trello_card_prefix, todays_date \\ Timex.now()) do
    card
    |> Map.get(:name)
    |> String.replace_prefix(trello_card_prefix, "")
    |> Timex.parse("{Mfull} {D}, {YYYY}")
    |> case do
      {:ok, date} ->
        date |> Timex.to_date() == todays_date

      _ ->
        false
    end
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