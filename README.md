# Setup Instructions

* Download the script
* Move the script into your avatar
* Require the script and call the functions

# Functions

## getWordle
`<Wordle>.getWordle(<year: integer?>, <month: integer?>, <day: integer?>): <Wordle.Properties>`

Gets the Wordle on the specified date

If no date is provided, returns todays Wordle

```lua
local wordle = require("Wordle")

printTable(wordle.getWordle(2023, 3, 7))
```

## solveWordle
`<Wordle>.solveWordle(<guess: string>, <year: integer?>, <month: integer?>, <day: integer?>): <string>`

Solves a Wordle, returning a json string

Throws if the guess isn't a 5 letter word

```lua
local wordle = require("Wordle")

printJson(wordle.solveWordle("guess"))
```

## getCache
`<Wordle>.getCache(): <[string]: Wordle.Properties>`

Gets every Wordle that exists in cache indexed by date

```lua
local wordle = require("Wordle")

printTable(wordle.getCache(), 2)
```

# Classes

## Wordle.Properties

Contains several fields parsed from the Wordle HTTP response

| Name              | Type      | Example       |
| ----------------- | --------- | ------------- |
| id                | `integer` | 1977          |
| solution          | `string`  | horse         |
| print_date        | `string`  | 2023-03-07    |
| days_since_launch | `integer` | 626           |
| editor            | `string`  | Tracy Bennett |
