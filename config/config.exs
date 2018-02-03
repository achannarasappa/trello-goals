use Mix.Config

config :logger, :console,
  format: {DailyGoals.Logger, :format},
  level: :debug
