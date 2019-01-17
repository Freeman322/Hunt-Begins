if stats == nil then
    stats = {}
    stats.__index = stats
end

stats.GET = 1;
stats.SET = 2;
stats.BUY_ITEM = 3;
stats.BUY_HERO = 4;

stats.data = {}

stats.config = {
	server = "http://82.146.43.107/",
	version = "1.0.0",
	game = "hunt",
	agent = "hunt",
	timeout = 15000
}

function stats.get_data()
    local data = {}
    data.players = stats.get_players_ids()

    local connection = CreateHTTPRequestScriptVM('POST', stats.config.server)
    
    local encoded_data = json.encode({
        type = stats.GET,
        key = GetDedicatedServerKey(stats.config.version),
        time = {
            frames = tonumber(GetFrameCount()),
            server_time = tonumber(Time()),
            dota_time = tonumber(GameRules:GetDOTATime(true, true)),
            game_time = tonumber(GameRules:GetGameTime()),
            server_system_date_time = tostring(GetSystemDate()) .. " " .. tostring(GetSystemTime()),
        },
        data = data
    })

	print("Performing request to " .. stats.config.server)
    print("Method: " .. 'POST')
    if payload ~= nil then
		print("Payload: " .. encoded_data:sub(1, 20))
    end
    
    connection:SetHTTPRequestGetOrPostParameter('hunt', encoded_data)
    connection:SetHTTPRequestAbsoluteTimeoutMS(stats.config.timeout)

    connection:Send (function(result_keys)
        local result = {
			code = result_keys.StatusCode,
			body = result_keys.Body,
		}

		if result.code == 0 then
			print("Request timed out")
			return
        end
        
		if result.body ~= nil then
			local decoded = json.decode(result.body)
			if result.code == 503 then
				print("Server unavailable")
			elseif result.code == 500 then
				if result.message ~= nil then print("Internal Server Error: " .. tostring(result.message)) else print("Internal Server Error") end
			elseif result.code == 405 then
				print("Used invalid method on endpoint" .. endpoint)
			elseif result.code == 404 then
				print("Tried to access unknown endpoint " .. endpoint)
			elseif result.code ~= 200 then
				print("Unknown Error: " .. tostring(result.code))
            end
            
            stats.prepare(decoded)
		else
			print("Warning: Recieved response for request " .. endpoint .. " without body!")
		end
    end)
end

function stats.save_data(pID, isEscape)
    local data = {}
    data.player = stats.get_player_stats(pID)
    data.loadout = stats.get_player_items(pID)
    data.steam_id = PlayerResource:GetSteamAccountID(pID)
    data.survived = isEscape

    local connection = CreateHTTPRequestScriptVM('POST', stats.config.server)
    
    local encoded_data = json.encode({
        type = stats.SET,
        key = GetDedicatedServerKey(stats.config.version),
        time = {
            frames = tonumber(GetFrameCount()),
            server_time = tonumber(Time()),
            version = stats.config.version,
            dota_time = tonumber(GameRules:GetDOTATime(true, true)),
            game_time = tonumber(GameRules:GetGameTime()),
            map = GetMapName(),
            server_system_date_time = tostring(string.gsub( GetSystemDate(), "/", ":" )) .. " " .. tostring(GetSystemTime()),
        },
        data = data
    })

	print("Performing request to " .. stats.config.server)
    print("Method: " .. 'POST')
    
    connection:SetHTTPRequestGetOrPostParameter('hunt', encoded_data)
    connection:SetHTTPRequestAbsoluteTimeoutMS(stats.config.timeout)

    connection:Send (function(result_keys)
        local result = {
			code = result_keys.StatusCode,
			body = result_keys.Body,
		}

		if result.code == 0 then
			print("Request timed out")
			return
        end
        
        print(result_keys.Body)

		if result.body ~= nil then
			local decoded = json.decode(result.body)
			if result.code == 503 then
				print("Server unavailable")
			elseif result.code == 500 then
				if result.message ~= nil then print("Internal Server Error: " .. tostring(result.message)) else print("Internal Server Error") end
			elseif result.code == 405 then
				print("Used invalid method on endpoint" .. endpoint)
			elseif result.code == 404 then
				print("Tried to access unknown endpoint " .. endpoint)
			elseif result.code ~= 200 then
				print("Unknown Error: " .. tostring(result.code))
            end
		else
			print("Warning: Recieved response for request " .. endpoint .. " without body!")
		end
    end)
end

function stats.get_player_items(pID)
    local items = {}
    
    if PlayerResource:IsValidPlayerID(pID) and PlayerResource:IsFakeClient(pID) == false then
        for i = 0, 8, 1 do
            local current_item = PlayerResource:GetSelectedHeroEntity(pID):GetItemInSlot(i)
            if current_item then 
                local item_name = current_item:GetName()
                
                table.insert(items, item_name)
            end 
        end
    end
    
    return items
end 
function stats.get_player_stats(pID)
    local player = {
        gold = GameRules.GameMode._vPlayers[pID].Gold,
        exp = GameRules.GameMode._vPlayers[pID].Exp,
        hero_id = GameRules.GameMode._vPlayers[pID].Hero,
        kills = PlayerResource:GetKills(pID)
    }

    return player
end
function stats.get_players_ids()
    local players = {}
    for i = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(i) then
            local steam_id = PlayerResource:GetSteamAccountID(i)
            if steam_id ~= 0 then table.insert(players, steam_id) end
        end
    end

    return players
end 
function stats.prepare( data )
    local array = {}

    for _, player in pairs(data) do
        for i = 0, DOTA_MAX_PLAYERS do
            if PlayerResource:IsValidPlayerID(i) then
                local steam_id = tostring(PlayerResource:GetSteamAccountID(i))
                
                if steam_id == player["steam_id"] then 
                    array[i] = player

                    GameRules.GameMode._vPlayers[i].Gold = tonumber(array[i]["gold"])
                    GameRules.GameMode._vPlayers[i].Data = array[i]
                end 
            end
        end
    end
end

function stats.get_ids()
    local players = {}

    for i = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(i) then
            local steam_id = PlayerResource:GetSteamAccountID(i)
            if steam_id ~= 0 then
                players[steam_id] = i
            end
        end
    end
    return players
end