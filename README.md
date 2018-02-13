# Trello Daily Goals

Repeat a daily goal card once per day rolling over any incomplete checklist items to the next day

## Installation
```sh
mix escript.build
```

## Usage
```sh
export TRELLO_API_KEY=<your api key>
export TRELLO_OAUTH_TOKEN=<your oauth token>
export TRELLO_BOARD_ID=<your board id>
export TRELLO_LIST_NAME="In Progress"
export TRELLO_CARD_TITLE_PREFIX="Daily Goals - "
./app
```

## Motivation
- Like daily check-in and daily day-level goal completion aspects of [Status Hero](https://statushero.com/) but this tool is geared towards teams and lacks task-level tracking
- Like daily task-level goal completion of and historical goal completion views of HabitBull but this tool does not support one-off daily tasks
- Trello offers flexible task-level tracking via checklists and day-level tracking via cards. Trello has a Card Repeater power-up but lacks ability to roll over checklist items, set a title based ondate, or a due date based on date.

