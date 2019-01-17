-- Generated from template
require("utils/timers")
require("triggers")
require("shop")
require("stats")
require("addons")

if CHuntGameMode == nil then
	CHuntGameMode = class({})
end

CHuntGameMode.Waypoints = {}

CHuntGameMode.DESCOVER_EXP = 40
CHuntGameMode.BOSS_FOUND = 200
CHuntGameMode.BOSS_KILLED = 1000
CHuntGameMode.BOSS_PURGED = 1500
CHuntGameMode.TROPHY_SAVED = 2000

CHuntGameMode.BossLocations = {}

CHuntGameMode.BossLocation = ""

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	PrecacheResource( "model", "models/creeps/thief/thief_01_archer.vmdl", context )
	PrecacheResource( "model", "models/creeps/omniknight_golem/omniknight_golem.vmdl", context )
	PrecacheResource( "model", "models/npc/npc_dingus/dingus.vmdl", context )
	PrecacheResource( "model", "models/items/meepo/diggers_divining_rod/diggers_divining_rod_gem_emerald.vmdl", context )

	PrecacheResource( "particle", "particles/neutral_fx/roshan_death.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_drow/drow_base_attack.vpcf", context )
	PrecacheResource( "particle", "particles/generic_gameplay/winter_effects_hero.vpcf", context )
	PrecacheResource( "particle", "particles/frostivus_gameplay/frostivus_hero_light.vpcf", context )
	PrecacheResource( "particle", "particles/rain_fx/econ_rain.vpcf", context )
	
	PrecacheResource( "particle", "particles/neutral_fx/roshan_death_aegis_starfall.vpcf", context )
	PrecacheResource( "particle", "particles/customgames/capturepoints/cp_neutral_3.vpcf", context )

	PrecacheResource( "particle", "particles/hunt/dynomite_projectile.vpcf", context )
	PrecacheResource( "particle", "particles/act_2/campfire_flame.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast_debuff.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_projectile.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_projectile_explosion.vpcf", context )

	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_slardar.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_pudge.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_tiny.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_antimage.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_undying.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_ursa.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/event.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_ui_imported.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/music/dsadowski_02/soundevents_music.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/music/dsadowski_02/soundevents_stingers.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/music/awolnation_01/soundevents_stingers.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_rattletrap.vsndevts", context )

	PrecacheItemByNameSync( "item_tombstone", context )
	PrecacheItemByNameSync( "item_bag_of_gold", context )
	PrecacheItemByNameSync( "item_slippers_of_halcyon", context )
	PrecacheItemByNameSync( "item_greater_clarity", context )
end

-- Create the game mode when we activate
function Activate()
	GameRules.GameMode = CHuntGameMode()
	GameRules.GameMode:InitGameMode()
end

function CHuntGameMode:InitGameMode()
	print( "Template addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 1 )
	
	GameRules:GetGameModeEntity():SetCustomGameForceHero( "npc_dota_hero_thief" ) 
	
	GameRules:SetTimeOfDay( 0 )
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( false )
	GameRules:SetHeroSelectionTime( 10.0 )
	GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 20 )

	Convars:SetBool( "dota_suggest_disable", true )

	GameRules:SetPreGameTime(20.0)
	GameRules:SetPostGameTime( 60.0 )
	GameRules:SetTreeRegrowTime( 9999 )

	GameRules:SetHeroMinimapIconScale( 0.7 )
	GameRules:SetCreepMinimapIconScale( 0.7 )
	GameRules:SetRuneMinimapIconScale( 0.7 )

	GameRules:SetGoldTickTime( 1 )
	GameRules:SetGoldPerTick( 0 )
	GameRules:GetGameModeEntity():SetFixedRespawnTime(0)
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)

	GameRules:GetGameModeEntity():SetFixedRespawnTime(5)
	GameRules:SetHeroRespawnEnabled( false )

	GameRules:SetCustomGameTeamMaxPlayers(3, 2)
	GameRules:SetCustomGameTeamMaxPlayers(2, 2)
	GameRules:SetCustomGameTeamMaxPlayers(6, 2)
	GameRules:SetCustomGameTeamMaxPlayers(7, 2)
	GameRules:SetCustomGameTeamMaxPlayers(8, 2)
	
	GameRules:SetGoldTickTime( 1 )
	GameRules:SetGoldPerTick( 25 )

	GameRules:GetGameModeEntity():SetUnseenFogOfWarEnabled(true)

	Convars:SetInt("dota_wait_for_players_to_load_timeout", 260)
	Convars:SetInt("dota_combine_models", 1 )
	
	SendToServerConsole( "dota_combine_models 1" )	

	-- Hook into game events allowing reload of functions at run time
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CHuntGameMode, "OnNPCSpawned" ), self )
	ListenToGameEvent( "player_reconnected", Dynamic_Wrap( CHuntGameMode, 'OnPlayerReconnected' ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( CHuntGameMode, 'OnEntityKilled' ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CHuntGameMode, "OnGameRulesStateChange" ), self )
	ListenToGameEvent( "inventory_updated", Dynamic_Wrap( CHuntGameMode, 'OnInventoryUpdated' ), self )


	LinkLuaModifier("modifier_monster","modifiers/modifier_monster.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_boss","modifiers/modifier_boss.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_escape","modifiers/modifier_escape.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_attack_range","modifiers/modifier_attack_range.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_shop","modifiers/modifier_shop.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_thinker_delay","modifiers/modifier_thinker_delay.lua", LUA_MODIFIER_MOTION_NONE)


	self._iTime = 0
	self._nUnits = 0
	self._tBosses = {}

	self.Monsters = LoadKeyValues("scripts/spawns.kv")

	CustomGameEventManager:RegisterListener("on_buy_hero", Dynamic_Wrap(CHuntGameMode, 'OnBuyHero'))
	CustomGameEventManager:RegisterListener("on_buy_item", Dynamic_Wrap(CHuntGameMode, 'OnBuyItem'))

	self.Postions = {}

	self.Waypoints = Entities:FindAllByClassname("npc_dota_spawner")
	for k,v in pairs(self.Waypoints) do table.insert( self.Postions , v:GetAbsOrigin() ) end

	local bosses_pos = Entities:FindAllByClassname("point_entity_finder")
	for k,v in pairs(bosses_pos) do 
		table.insert( self.BossLocations, {
			name = v:GetName(),
			vector = v:GetAbsOrigin()
		})
	end

	Timers:CreateTimer(25, function()
		self:Spawn()
		return 120
	end)

	local bosses = LoadKeyValues("scripts/bosses.kv")
	local boss = bosses[tostring(RandomInt(1, 5))]

	PrecacheUnitByNameAsync( boss, function()
		local data = self.BossLocations[RandomInt(1, #self.BossLocations)]
		local vLoc = data.vector
		self.BossLocation = data.name

		print(data.name)

		local entUnit = CreateUnitByName( boss, vLoc, true, nil, nil, DOTA_TEAM_NEUTRALS )
		entUnit:SetChampion(true)

		entUnit:AddNewModifier(nil, nil, "modifier_boss", nil)

		table.insert( self._tBosses, entUnit )
	end)

	local kv = LoadKeyValues( "scripts/maps/" .. GetMapName() .. ".kv" )
	kv = kv or {} -- Handle the case where there is not keyvalues file

	self._vLootItemDropsList = {}
	self._vMonstersSharedXP = kv["LinkedXpEnemies"]

	self._vTeams = {}

	self._vPlayers = {}

	self:_ReadLootItemDropsConfiguration( kv["ItemDrops"] )

	for k,v in pairs(Entities:FindAllByClassname("npc_dota_neutral_spawner")) do
		if v and v:IsNull() == false and IsValidEntity(v) then
			UTIL_RemoveImmediate(v)
		end 
	end

	Convars:RegisterCommand( "get_data", Dynamic_Wrap(CHuntGameMode, 'GetData'), "Test", FCVAR_CHEAT )
	Convars:RegisterCommand( "save_data", Dynamic_Wrap(CHuntGameMode, 'SaveData'), "Test", FCVAR_CHEAT )

	Convars:RegisterCommand("teleport_to", function(command, location )
		local hero = PlayerResource:GetPlayer(tonumber(Convars:GetCommandClient():GetPlayerID())):GetAssignedHero()
		
		print(hero:GetUnitName())

		for k,v in pairs(self.BossLocations) do
			print(v.name == location)
			if v.name == location then 
				hero:SetAbsOrigin(v.vector)
				FindClearSpaceForUnit(hero, v.vector, true)
			end
		end
	end, "Set on or off godmode", FCVAR_CHEAT)

	Convars:RegisterCommand("get_code", function(command, location )
		GameRules:SendCustomMessage(GetDedicatedServerKey("1.0.0"), 0, 0)
	end, "", 0)

	GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(function(ctx, event)
		if event.inventory_parent_entindex_const and event.item_entindex_const then 
			local item = EntIndexToHScript(event.item_entindex_const)
			local player = EntIndexToHScript(event.inventory_parent_entindex_const)

			if item:GetAbilityName() == "item_trophy" and player:HasItemInInventory("item_trophy") then
				local newItem = CreateItem("item_trophy", nil, nil)
				local loot = CreateItemOnPositionForLaunch(player:GetOrigin(), newItem)

				return false 
			end
		end

    	return true
	end, self)
end

function CHuntGameMode:OnInventoryUpdated(params)
	for k,v in pairs(params) do
		print(k,v)
	end
end


function CHuntGameMode:GetData(params)
	stats.get_data()
end

function CHuntGameMode:SaveData(params)
	stats.save_data(0, false)
end

function CHuntGameMode:OnBuyHero(params)
	shop.buy_hero(params.PlayerID, tonumber(params.hero_id))
end

function CHuntGameMode:OnBuyItem(params)
	shop.buy_item(params.PlayerID, params.item)
end

-- Evaluate the state of the game
function CHuntGameMode:OnThink()
	CustomNetTables:SetTableValue("gamemode", "players", self._vPlayers)

	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:CheckForGame();
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		
	end
	return 1
end

function CHuntGameMode:CheckForGame()
	local bAllPlayersDead = true
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
		if hero and hero:IsAlive() then
			bAllPlayersDead = false
		end
	end

	if bAllPlayersDead then
		self:GameEnded()
		GameRules:SetGameWinner(DOTA_TEAM_NEUTRALS)
		return
	end	
end

function CHuntGameMode:OnAllPlayersLoaded()
	for i = 0, DOTA_MAX_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID(i) then 
			self._vTeams[PlayerResource:GetTeam(i)] = self._vTeams[PlayerResource:GetTeam(i)] or {}
			table.insert( self._vTeams[PlayerResource:GetTeam(i)], i )

			self._vPlayers[i] = {}
			self._vPlayers[i].Exp = 0
			self._vPlayers[i].Gold = 0
			self._vPlayers[i].Hero = -1
			self._vPlayers[i].Data = {}
			self._vPlayers[i].Locations = {}
		end 
	end

	self._vPlayersCount = PlayerResource:GetPlayerCount()

	stats.get_data()
end

function CHuntGameMode:UpdatePlayer( pID, hero )
	local function isempty(s)
		return s == nil or s == ''
	end

	if self._vPlayers[pID] and self._vPlayers[pID].Data then 
		local hero_id = tonumber(self._vPlayers[pID].Data["hero_id"])

		if hero_id == 1 then 
			hero:SetOriginalModel("models/creeps/omniknight_golem/omniknight_golem.vmdl")
			hero:ModifyStrength(100)
			hero:SetBaseMoveSpeed(240)
			hero:SetPhysicalArmorBaseValue(20)

			hero:SetBaseHealthRegen(80)

			hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
		elseif hero_id == 2 then 
			hero:SetOriginalModel("models/creeps/thief/thief_01_archer.vmdl")
			hero:SetRangedProjectileName("particles/units/heroes/hero_drow/drow_base_attack.vpcf")
			hero:ModifyAgility(150)
			hero:SetBaseMoveSpeed(340)
			hero:SetPhysicalArmorBaseValue(-10)
			hero:ModifyStrength(20)

			hero:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
			hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_AGILITY)

			hero:AddNewModifier(hero, nil, "modifier_attack_range", nil)
		elseif hero_id == 3 then 
			hero:SetOriginalModel("models/npc/npc_dingus/dingus.vmdl")

			hero:ModifyStrength(80)
			hero:ModifyAgility(80)
			hero:ModifyIntellect(80)
			hero:SetBaseMoveSpeed(290)
			hero:SetPhysicalArmorBaseValue(10)

			hero:SetBaseDamageMin(100)
			hero:SetBaseDamageMax(100)

			hero:SetBaseHealthRegen(20)

			hero:SetBaseAttackTime(0.8)

			hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
		end

		GameRules.GameMode._vPlayers[pID].Hero = hero_id

		if not isempty(self._vPlayers[pID].Data["loadout"]) then 
			local inventory = json.decode(self._vPlayers[pID].Data["loadout"])
			if inventory then
				for k,v in pairs(inventory) do
					if v ~= nil then 
						local newItem = CreateItem( v, nil, nil )
						hero:AddItem(newItem)
					end
				end
			end
		end
	end

	CustomNetTables:SetTableValue("gamemode", "players", self._vPlayers)
end

function CHuntGameMode:GetPlayersInTeam( team )
	return self._vTeams[team]
end

function CHuntGameMode:AddExperience( pID, exp )
	for k,v in pairs(self:GetPlayersInTeam(PlayerResource:GetTeam(pID))) do
		self._vPlayers[v].Exp = (self._vPlayers[v].Exp or 0) + exp
	end
end

function CHuntGameMode:AddGold( pID, gold )
	for k,v in pairs(self:GetPlayersInTeam(PlayerResource:GetTeam(pID))) do
		self._vPlayers[v].Gold = (self._vPlayers[v].Gold or 0) + gold
	end
end

function CHuntGameMode:Spawn( event )
	if self._nUnits < 100 then 
		for _,vector in pairs(self.Postions) do
			for monster, chance in pairs(self.Monsters) do
				if RollPercentage(tonumber(chance)) then
					PrecacheUnitByNameAsync( monster, function()
						local entUnit = CreateUnitByName( monster, vector, true, nil, nil, DOTA_TEAM_NEUTRALS )
						local vPos = Vector(RandomInt(-16228, 16226), RandomInt(-16240, 16201), 128)
						
						entUnit:AddNewModifier(nil, nil, "modifier_monster", nil)

						self._nUnits = self._nUnits + 1
					end)
				end
			end			
		end
	end
end

-- When game state changes set state in script
function CHuntGameMode:OnGameRulesStateChange()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
		self:OnAllPlayersLoaded()
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
	end
end

function CHuntGameMode:GameEnded( )
	for i = 0, DOTA_MAX_PLAYERS do
		if PlayerResource:IsValidPlayerID(i) then
			local hero = PlayerResource:GetSelectedHeroEntity(i)
			if hero and not hero:IsNull() then 
				stats.save_data(i, false)
			end 
		end
	end
end

function CHuntGameMode:_SpawnHeroClientEffects( hero, nPlayerID )
	ParticleManager:ReleaseParticleIndex( ParticleManager:CreateParticleForPlayer( "particles/generic_gameplay/winter_effects_hero.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, PlayerResource:GetPlayer( nPlayerID ) ) )	-- Attaches the breath effects to players for winter maps
	ParticleManager:ReleaseParticleIndex( ParticleManager:CreateParticleForPlayer( "particles/frostivus_gameplay/frostivus_hero_light.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, PlayerResource:GetPlayer( nPlayerID ) ) )

	EmitAnnouncerSoundForPlayer("dsadowski_02.music.killed", nPlayerID)

	ParticleManager:ReleaseParticleIndex( ParticleManager:CreateParticleForPlayer( "particles/rain_fx/econ_rain.vpcf", PATTACH_EYES_FOLLOW, hero, PlayerResource:GetPlayer( nPlayerID ) ) )
end


function CHuntGameMode:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if not spawnedUnit or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:IsPhantom() then
		return
	end

	if spawnedUnit:IsCreature() then

	end

	-- Attach client side hero effects on spawning players
	if spawnedUnit:IsRealHero() then
		if not spawnedUnit._bIsFirstTime then 
			self:UpdatePlayer( spawnedUnit:GetPlayerOwnerID(), spawnedUnit )
			self:_SpawnHeroClientEffects( spawnedUnit, spawnedUnit:GetPlayerOwnerID() )

			spawnedUnit._bIsFirstTime = true
		end
	end
end

function CHuntGameMode:OnPlayerEscaped( hero, pID )
	if IsServer() then
		if hero:HasItemInInventory("item_trophy") then 
			self:AddExperience(pID, self.TROPHY_SAVED)

			hero:RemoveItem(hero:FindItemInInventory("item_trophy"))
		end

		if self:CanSaveData() then
			stats.save_data(pID, true)
		end

		GameRules:SetSafeToLeave(true)

		UTIL_Remove(hero)
	end 
end

-- Attach client-side hero effects for a reconnecting player
function CHuntGameMode:OnPlayerReconnected( event )
	local nReconnectedPlayerID = event.PlayerID
	for _, hero in pairs( Entities:FindAllByClassname( "npc_dota_hero" ) ) do
		if hero:IsRealHero() then
			self:_SpawnHeroClientEffects( hero, nReconnectedPlayerID )
		end
	end
end


function CHuntGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	if killedUnit and killedUnit:IsRealHero() then
		local newItem = CreateItem( "item_tombstone", killedUnit, killedUnit )
		newItem:SetPurchaseTime( 0 )
		newItem:SetPurchaser( killedUnit )
		
		local tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} )
		tombstone:SetContainedItem( newItem )
		tombstone:SetAngles( 0, RandomFloat( 0, 360 ), 0 )
		
		FindClearSpaceForUnit( tombstone, killedUnit:GetAbsOrigin(), true )	

		for i = 0, 8, 1 do
            local current_item = killedUnit:GetItemInSlot(i)
            if current_item then 
				local newItem = CreateItem(current_item:GetAbilityName(), nil, nil)
				local loot = CreateItemOnPositionForLaunch(killedUnit:GetOrigin(), newItem)
				
				killedUnit:RemoveItem(current_item)
            end 
        end
	end
	if killedUnit:IsCreature() then 
		for _,itemDropInfo in pairs( self._vLootItemDropsList ) do
			if RollPercentage( itemDropInfo.nChance ) then
				local newItem = CreateItem( itemDropInfo.szItemName, nil, nil )
				newItem:SetPurchaseTime( 0 )
				if newItem:IsPermanent() and newItem:GetShareability() == ITEM_FULLY_SHAREABLE then
					item:SetStacksWithOtherOwners( true )
				end
				local drop = CreateItemOnPositionSync( killedUnit:GetAbsOrigin(), newItem )
				drop.Holdout_IsLootDrop = true
			end
		end
		if killedUnit:IsChampion() then 
			local nFXIndex = ParticleManager:CreateParticle("particles/neutral_fx/roshan_death.vpcf", PATTACH_CUSTOMORIGIN, killedUnit );
			ParticleManager:SetParticleControl( nFXIndex, 0, killedUnit:GetAbsOrigin());
			ParticleManager:SetParticleControl( nFXIndex, 1, killedUnit:GetAbsOrigin());
			ParticleManager:SetParticleControl( nFXIndex, 3, killedUnit:GetAbsOrigin());
			ParticleManager:ReleaseParticleIndex( nFXIndex );

			CustomGameEventManager:Send_ServerToAllClients("on_boss_killed", {
				location = self.BossLocation,
				name = killedUnit:GetUnitName()
			})

			CreateModifierThinker(killedUnit, killedUnit:GetAbilityByIndex(0), "modifier_thinker_delay", {duration = 40, killer = killedUnit:entindex()}, killedUnit:GetAbsOrigin(), 4, false)
		end 
	end 

	local attacker = EntIndexToHScript( event.entindex_attacker or 0 )
	if attacker:IsRealHero() and self._vMonstersSharedXP[killedUnit:GetUnitName()] ~= nil then 
		self:AddExperience(attacker:GetPlayerOwnerID(), self._vMonstersSharedXP[killedUnit:GetUnitName()].Xp)
		self:AddGold(attacker:GetPlayerOwnerID(), self._vMonstersSharedXP[killedUnit:GetUnitName()].Gold)
	end 
end

function CHuntGameMode:_ReadLootItemDropsConfiguration( kvLootDrops )
	self._vLootItemDropsList = {}
	if type( kvLootDrops ) ~= "table" then
		return
	end
	for _,lootItem in pairs( kvLootDrops ) do
		table.insert( self._vLootItemDropsList, {
			szItemName = lootItem.Item or "",
			nChance = tonumber( lootItem.Chance or 0 )
		})
	end
end

function CHuntGameMode:CanSaveData()
	return (not IsInToolsMode() and not GameRules:IsCheatMode() and self._vPlayersCount >= 4)
end

