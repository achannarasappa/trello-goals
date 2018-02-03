defmodule DailyGoals.Main do
  @moduledoc """
  Main module for DailyGoals
  """

  @doc """
  Filter cards to only daily goal cards
  """
  def filter_daily_goals(cards, trello_card_prefix) do
    cards
    |> Enum.filter(&(String.starts_with?(Map.get(&1, :name), trello_card_prefix)))
  end

  @doc """
  Check is there is a card for today
  """

end
