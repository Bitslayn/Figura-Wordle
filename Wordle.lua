--[[
____  ___ __   __
| __|/ _ \\ \ / /
| _|| (_) |> w <
|_|  \___//_/ \_\
FOX's Wordle API v1.0

Github: https://github.com/Bitslayn/Figura-Wordle
]]

--==============================================================================================================================
--#REGION ˚♡ Library ♡˚
--==============================================================================================================================

---@class Wordle.Properties
---@field id integer
---@field solution string
---@field print_date string
---@field days_since_launch integer
---@field editor string

---Fetches the Wordle on the specified date
---@param formatted_date string
---@param level integer?
---@return string
local function fetch_wordle(formatted_date, level)
	-- Create HTTP request

	local request = net.http:request("https://www.nytimes.com/svc/wordle/v2/" .. formatted_date .. ".json")

	local response_future = request:send()
	repeat until response_future:isDone()
	local response = response_future:getOrError() --[[@as HttpResponse]]

	if response:getResponseCode() ~= 200 then
		error("Failed to fetch Wordle with code: " .. response:getResponseCode(), level)
	end

	-- Read HTTP response

	local stream = response:getData()
	local length = response:getHeaders()["content-length"][1] --[[@as integer]]
	local buffer = data:createBuffer(length)

	buffer:readFromStream(stream)
	buffer:setPosition(0)
	local string = buffer:readByteArray()

	buffer:close()
	stream:close()

	return string
end

---Attempts to load a Wordle from cache
---@param formatted_date string
---@overload fun(): table<string, string>
---@return string?
local function fetch_cache(formatted_date)
	local name = config:getName()
	config:setName("Wordle")
	local val = config:load(formatted_date)
	config:setName(name)
	return val
end

---Saves a Wordle to cache
---@param formatted_date string
---@param body string
---@return string
local function store_cache(formatted_date, body)
	local name = config:getName()
	config:setName("Wordle")
	config:save(formatted_date, body)
	config:setName(name)
	return body
end

---Gets the Wordle on the specified date
---@param year integer?
---@param month integer?
---@param day integer?
---@param level integer?
---@return Wordle.Properties
local function get_wordle(year, month, day, level)
	local date = client.getDate()

	year = year or date.year
	month = month or date.month
	day = day or date.day

	local formatted_date = string.format("%04d-%02d-%02d", year, month, day)
	local body = fetch_cache(formatted_date) or store_cache(formatted_date, fetch_wordle(formatted_date, level))

	return parseJson(body)
end

--#ENDREGION --=================================================================================================================
--#REGION ˚♡ API ♡˚
--==============================================================================================================================

---@class Wordle
local wordle = {}

---Gets the Wordle on the specified date
---@param year integer?
---@param month integer?
---@param day integer?
function wordle.getWordle(year, month, day)
	return get_wordle(year, month, day, 3)
end

---Gets every Wordle that exists in cache
---@return table<string, Wordle.Properties>
function wordle.getCache()
	local cache = fetch_cache()
	local parsed_cache = {}
	for key, value in pairs(cache) do
		parsed_cache[key] = parseJson(value)
	end
	return parsed_cache
end

---Solves a Wordle
---
---Throws if the guess isn't a 5 letter word
---@param guess string
---@param year integer?
---@param month integer?
---@param day integer?
function wordle.solveWordle(guess, year, month, day)
	guess = string.match(guess, "%a*")
	if type(guess) ~= "string" or #guess ~= 5 then
		error("Invalid Wordle guess: " .. tostring(guess), 2)
	end

	local solution = get_wordle(year, month, day, 4).solution

	local squares = {
		{ text = "■", color = "gray" },
		{ text = "■", color = "gray" },
		{ text = "■", color = "gray" },
		{ text = "■", color = "gray" },
		{ text = "■", color = "gray" },
	}

	-- Count letters

	local letters = {}
	for w in string.gmatch(solution, "%a") do
		letters[w] = letters[w] and letters[w] + 1 or 1
	end

	-- Mark correct

	for i = 1, 5 do
		local char_guess = string.sub(guess, i, i)

		local skip = letters[char_guess] == 0

		if not skip and char_guess == string.sub(solution, i, i) then
			squares[i].color = "green"
			letters[char_guess] = letters[char_guess] - 1
		end
	end

	-- Mark misses

	for i = 1, 5 do
		local char_guess = string.sub(guess, i, i)

		local skip = letters[char_guess] == 0 or squares[i].color == "green"

		if not skip and string.find(solution, char_guess) then
			squares[i].color = "yellow"
			letters[char_guess] = letters[char_guess] - 1
		end
	end

	return toJson({ text = guess .. " ", extra = squares })
end

return wordle

--#ENDREGION
