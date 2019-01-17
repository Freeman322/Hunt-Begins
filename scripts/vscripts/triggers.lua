if triggers == nil then
    triggers = {}
    triggers.__index = triggers
end

LOCATION_HOUSE = 0
LOCATION_SANCTUARY = 1
LOCATION_CITY = 2
LOCATION_SWAMP = 3
LOCATION_MINE = 4
LOCATION_ARENA = 5
LOCATION_FARM = 7
LOCATION_LIGHTHOUSE = 8
LOCATION_DVIDE = 9
LOCATION_PALACE = 10
LOCATION_FORT = 11

function OnHouseFound( params )
    triggers:OnAreaDiscovered({id = LOCATION_HOUSE, area = "House"}, params.activator:GetPlayerOwner())
end

function OnSanctuaryFound( params )
    triggers:OnAreaDiscovered({id = LOCATION_SANCTUARY, area = "Sanctuaty"}, params.activator:GetPlayerOwner())
end

function OnCityFound( params )
    triggers:OnAreaDiscovered({id = LOCATION_CITY, area = "City"}, params.activator:GetPlayerOwner())
end

function OnSwampFound( params )
    triggers:OnAreaDiscovered({id = LOCATION_SWAMP, area = "Swamp"}, params.activator:GetPlayerOwner())
end

function OnMineFound( params )
    triggers:OnAreaDiscovered({id = LOCATION_MINE, area = "Mine"}, params.activator:GetPlayerOwner())
end

function OnArenaFound( params )
    triggers:OnAreaDiscovered({id = LOCATION_ARENA, area = "Arena"}, params.activator:GetPlayerOwner())
end

function OnFarmFound( params )
    triggers:OnAreaDiscovered({id = LOCATION_FARM, area = "Farm"}, params.activator:GetPlayerOwner())
end

function OnLighhouseFound( params )
    triggers:OnAreaDiscovered({id = LOCATION_LIGHTHOUSE, area = "Lighthouse"}, params.activator:GetPlayerOwner())
end

function OnDvideFound( params )
    triggers:OnAreaDiscovered({id = LOCATION_DVIDE, area = "Great Dvide"}, params.activator:GetPlayerOwner())
end

function OnFortFound( params )
    triggers:OnAreaDiscovered({id = LOCATION_FORT, area = "Fort"}, params.activator:GetPlayerOwner())
end

function OnPalaceFound( params )
    triggers:OnAreaDiscovered({id = LOCATION_PALACE, area = "Palace"}, params.activator:GetPlayerOwner())
end

function OnEscape( params )
    local player = params.activator:GetPlayerOwner()
	local hero = params.activator

	if not GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return end

	if not hero:HasModifier("modifier_escape") then hero:AddNewModifier(hero, nil, "modifier_escape", {duration = 8}) end 
end

function OnEndEscape( params )
    local player = params.activator:GetPlayerOwner()
	local hero = params.activator

	if hero:HasModifier("modifier_escape") then hero:RemoveModifierByName("modifier_escape") end 
end

function triggers:OnAreaDiscovered( data, player )
    if IsServer() then 
		if not GameRules.GameMode._vPlayers[player:GetPlayerID()].Locations[data.id] then 
			CustomGameEventManager:Send_ServerToPlayer(player, "on_area_discovered", data)

            GameRules.GameMode._vPlayers[player:GetPlayerID()].Locations[data.id] = true
            
            GameRules.GameMode:AddExperience(player:GetPlayerID(), GameRules.GameMode.DESCOVER_EXP)

			EmitAnnouncerSoundForPlayer("Event.AreaDiscovered", player:GetPlayerID())
		end
	end
end

function OnShopEnter( params )
    local player = params.activator:GetPlayerOwner()
	local hero = params.activator

    if not hero:HasModifier("modifier_shop") then hero:AddNewModifier(hero, nil, "modifier_shop", nil) end 
    
    EmitAnnouncerSoundForPlayer("Shop.Available", player:GetPlayerID())
end

function OnShopLeave( params )
    local player = params.activator:GetPlayerOwner()
	local hero = params.activator

    if hero:HasModifier("modifier_shop") then hero:RemoveModifierByName("modifier_shop") end 
    
    EmitAnnouncerSoundForPlayer("Shop.Unavailable", player:GetPlayerID())
end