defmodule Goals.Cli do
  def main(_args) do
    Goals.Repeater.run()
  end
end