use Mix.Config
import String

config :logger, :console,
  format: {DailyGoals.Logger, :format},
  level: :debug,
  metadata: :all

config :app,
  trello_api_key: System.get_env("TRELLO_API_KEY"),
  trello_oauth_token: System.get_env("TRELLO_OAUTH_TOKEN"),
  trello_board_id: System.get_env("TRELLO_BOARD_ID"),
  trello_active_list_id: System.get_env("TRELLO_ACTIVE_LIST_ID"),
  trello_archive_list_id: System.get_env("TRELLO_ARCHIVE_LIST_ID"),
  trello_card_prefix: System.get_env("TRELLO_CARD_TITLE_PREFIX")
