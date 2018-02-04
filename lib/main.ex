defmodule DailyGoals.Main do
  @moduledoc """
  Main module for DailyGoals
  """

  @doc """
  Filter cards to only daily goal cards
  """
  def filter_daily_goals(cards, trello_card_prefix) do
    cards
    |> Enum.filter(&String.starts_with?(Map.get(&1, :name), trello_card_prefix))
  end

  @doc """
  Check is there is a card for today
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
end
