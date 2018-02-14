defmodule Goals.Cli do
  import Goals.Repeater

  def main(_args) do
    Goals.Repeater.run()
  end
end
