# Trello Daily Goals

Repeat a daily goal card once per day rolling over any incomplete checklist items to the next day and setting a new due date

## Configuration
Configure through environment
* TRELLO_API_KEY - API which can be generated [here](https://trello.com/app-key)
* TRELLO_OAUTH_TOKEN - Token that can be generate from [here](https://trello.com/1/authorize?expiration=never&scope=read,write,account&response_type=token&name=Server%20Token&key=11d819814ecab06772546fd5f37b992a)
* TRELLO_BOARD_ID - Board id which can be found in the url when viewing a board e.g. _be0BbWVQ_
* TRELLO_LIST_NAME - List name to create new cards on e.g. _Daily Goals_
* TRELLO_CARD_TITLE_PREFIX - Title prefix for daily goal cards e.g. _Daily Goals -_. This is how the service locates past cards to roll over.

## Usage
### Docker
```sh
docker run -d --env-file=trello-goals.env achannarasappa/trello-goals
```
### Mix
```sh
mix run --no-halt
```

## Motivation
- Like daily check-in and daily day-level goal completion aspects of [Status Hero](https://statushero.com/) but this tool is geared towards teams and lacks task-level tracking
- Like daily task-level goal completion of and historical goal completion views of HabitBull but this tool does not support one-off daily tasks
- Trello offers flexible task-level tracking via checklists and day-level tracking via cards. Trello has a Card Repeater power-up but lacks ability to roll over checklist items, set a title based ondate, or a due date based on date.

