defmodule Goals.MixProject do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  defp escript do
    [
      main_module: Goals.Cli,
      name: "goals"
    ]
  end

  def application do
    [
      mod: {Goals, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:timex, "~> 3.2"},
      {:tzdata, "~> 0.1.8"},
      {:quantum, ">= 2.2.5"},
      {:dialyxir, "~> 0.4", only: [:dev]}
    ]
  end
end