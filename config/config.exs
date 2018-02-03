use Mix.Config
import String

config :logger, :console,
  format: {DailyGoals.Logger, :format},
  level: :debug,
  metadata: :all

config :app,
  trello_api_key: System.get_env("TRELLO_API_KEY"),
  trello_oauth_token: System.get_env("TRELLO_OAUTH_TOKEN"),
  trello_board_ids: System.get_env("TRELLO_BOARD_IDS")
