use Mix.Config
import String

config :logger, :console,
  format: {Goals.Logger, :format},
  level: :debug,
  metadata: :all

config :app,
  trello_api_key: System.get_env("TRELLO_API_KEY"),
  trello_oauth_token: System.get_env("TRELLO_OAUTH_TOKEN"),
  trello_board_id: System.get_env("TRELLO_BOARD_ID"),
  trello_list_name: System.get_env("TRELLO_LIST_NAME"),
  trello_card_prefix: System.get_env("TRELLO_CARD_TITLE_PREFIX"),
  trello_timezone: System.get_env("TRELLO_TIMEZONE")

config :app, Goals.Scheduler,
  jobs: [
    {"@daily", {Goals.Repeater, :run, []}}
  ]