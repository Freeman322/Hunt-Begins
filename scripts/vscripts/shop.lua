if shop == nil then
    shop = {}
    shop.__index = shop
end

function shop.init()
    
end

function shop.buy_item(pID, name)
    local cost = GetItemCost(name)
    if GameRules.GameMode._vPlayers[pID].Gold >= tonumber(cost) then
        GameRules.GameMode._vPlayers[pID].Gold = GameRules.GameMode._vPlayers[pID].Gold - tonumber(cost)

        local newItem = CreateItem( name, nil, nil )
        local drop = CreateItemOnPositionSync( PlayerResource:GetSelectedHeroEntity(pID):GetAbsOrigin(), newItem )
        
        EmitAnnouncerSoundForPlayer("Quickbuy.Available", pID)
    end 
end

function shop.buy_hero(pID, hero_id)
    local cost = 2000
    local hero = PlayerResource:GetSelectedHeroEntity(pID)

    if hero_id == 1 then 
        cost = 1500

        if GameRules.GameMode._vPlayers[pID].Gold >= tonumber(cost) then
            GameRules.GameMode._vPlayers[pID].Gold = GameRules.GameMode._vPlayers[pID].Gold - tonumber(cost)
        
            hero:SetOriginalModel("models/creeps/omniknight_golem/omniknight_golem.vmdl")
            hero:ModifyStrength(100)
            hero:SetBaseMoveSpeed(240)
            hero:SetPhysicalArmorBaseValue(20)

            hero:SetBaseHealthRegen(80)

            hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)

            GameRules.GameMode._vPlayers[pID].Hero = hero_id
        end 
    elseif hero_id == 2 then 
        cost = 5000

        if GameRules.GameMode._vPlayers[pID].Gold >= tonumber(cost) then
            GameRules.GameMode._vPlayers[pID].Gold = GameRules.GameMode._vPlayers[pID].Gold - tonumber(cost)

            hero:SetOriginalModel("models/creeps/thief/thief_01_archer.vmdl")
            hero:SetRangedProjectileName("particles/units/heroes/hero_drow/drow_base_attack.vpcf")
            hero:ModifyAgility(150)
            hero:SetBaseMoveSpeed(340)
            hero:SetPhysicalArmorBaseValue(-10)
            hero:ModifyStrength(20)
    
            hero:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
            hero:SetPrimaryAttribute(DOTA_ATTRIBUTE_AGILITY)
    
            hero:AddNewModifier(hero, nil, "modifier_attack_range", nil)

            GameRules.GameMode._vPlayers[pID].Hero = hero_id
        end 
    elseif hero_id == 3 then 
        cost = 3000

        if GameRules.GameMode._vPlayers[pID].Gold >= tonumber(cost) then
            GameRules.GameMode._vPlayers[pID].Gold = GameRules.GameMode._vPlayers[pID].Gold - tonumber(cost)

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

            GameRules.GameMode._vPlayers[pID].Hero = hero_id
        end 
    end
    EmitAnnouncerSoundForPlayer("Quickbuy.Available", pID)
end


shop.init()