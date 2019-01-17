LinkLuaModifier ("modifier_item_molotov", "items/item_molotov.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_molotov_thinker", "items/item_molotov.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_molotov_thinker_fire", "items/item_molotov.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_molotov_fire", "items/item_molotov.lua", LUA_MODIFIER_MOTION_NONE)

local flPEREOD_DAMAGE = 150
local nRADIUS = 380
local nDAMAGE = 400

if not item_molotov then item_molotov = class({}) end 

function item_molotov:GetConceptRecipientType()
	return DOTA_SPEECH_USER_ALL
end
--------------------------------------------------------------------------------

function item_molotov:SpeakTrigger()
	return DOTA_ABILITY_SPEAK_CAST
end

--------------------------------------------------------------------------------

function item_molotov:GetChannelTime()
	return 1
end

--------------------------------------------------------------------------------

function item_molotov:OnAbilityPhaseStart()
    if IsServer() then
        if self:IsChargesEnough() then 
            self.vPoint = self:GetCursorPosition()
            
            local caster = self:GetCaster()
            local team_id = caster:GetTeamNumber()
            self.hThinker = CreateModifierThinker(caster, self, "modifier_item_molotov_thinker", {duration = 4}, self.vPoint, team_id, false)
        end
	end

	return true
end

function item_molotov:OnChannelFinish( bInterrupted )
    if bInterrupted == false and self.vPoint and self.hThinker then
        local info = 
        {
            Target = self.hThinker,
            Source = self:GetCaster(),
            Ability = self,	
            EffectName = "particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_projectile.vpcf",
            iMoveSpeed = 700,
            vSourceLoc= self:GetCaster():GetAbsOrigin(),                -- Optional (HOW)
            bDrawsOnMinimap = false,                          -- Optional
            bDodgeable = true,                                -- Optional
            bIsAttack = false,                                -- Optional
            bVisibleToEnemies = true,                         -- Optional
            bReplaceExisting = false,                         -- Optional
            flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
            bProvidesVision = true,                           -- Optional
            iVisionRadius = 400,                              -- Optional
            iVisionTeamNumber = self:GetCaster():GetTeamNumber()        -- Optional
        }

        ProjectileManager:CreateTrackingProjectile(info)

        EmitSoundOn( "Hero_Alchemist.UnstableConcoction.Throw" , self:GetCaster() )

        self:SetCurrentCharges(self:GetCurrentCharges() - 1)
    end
    if bInterrupted then 
        self:EndCooldown()
    end
end

function item_molotov:OnProjectileHit( hTarget, vLocation )
    if IsServer() then
        local hCaster = self:GetCaster()

        local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_projectile_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil );
        ParticleManager:SetParticleControl( nFXIndex, 0, vLocation);
        ParticleManager:SetParticleControl( nFXIndex, 3, vLocation);
        ParticleManager:ReleaseParticleIndex( nFXIndex );

        EmitSoundOnLocationWithCaster(vLocation, "Hero_Alchemist.UnstableConcoction.Stun", hCaster)

        local units = FindUnitsInRadius(hCaster:GetTeam(), vLocation, nil, nRADIUS, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
        for i, target in ipairs(units) do  
            local damage = {
                victim = target,
                attacker = hCaster,
                damage = nDAMAGE,
                damage_type = DAMAGE_TYPE_PURE,
                ability = self,
            }

            ApplyDamage( damage )
        end

        AddFOWViewer(self:GetCaster():GetTeamNumber(), vLocation, 400, 5, true)

        CreateModifierThinker(caster, self, "modifier_item_molotov_thinker_fire", {duration = 6, attacker = self:GetCaster():entindex()}, vLocation, self:GetCaster():GetTeamNumber(), false)

        self.vPoint = nil
        if self.hThinker then UTIL_Remove(self.hThinker) end 
        if self:GetCurrentCharges() <= 0 then self:GetParent():RemoveItem(self) end 
        return nil
    end
end

if not modifier_item_molotov_thinker then modifier_item_molotov_thinker = class({}) end 

modifier_item_molotov_thinker_fire = class ({})

function modifier_item_molotov_thinker_fire:OnCreated(event)
    if IsServer() then
        local nFXIndex = ParticleManager:CreateParticle( "particles/act_2/campfire_flame.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
        ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl( nFXIndex, 1, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl( nFXIndex, 3, self:GetParent():GetAbsOrigin())
        self:AddParticle( nFXIndex, false, false, -1, false, true )

        AddFOWViewer( self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), 1500, 5, false)

        GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 1500, false)

        self.hAttacker = EntIndexToHScript(event.attacker)

        self:StartIntervalThink(FrameTime())
    end
end

function modifier_item_molotov_thinker_fire:OnDestroy()
    if IsServer() then
        
    end
end

function modifier_item_molotov_thinker_fire:OnIntervalThink()
    local nearby_targets = FindUnitsInRadius(self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil, nRADIUS, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

    for i, target in ipairs(nearby_targets) do
        local damage = {
            victim = target,
            attacker = self.hAttacker,
            damage = flPEREOD_DAMAGE * FrameTime(),
            damage_type = DAMAGE_TYPE_PURE,
            ability = self,
        }

        ApplyDamage( damage )
    end
end

function modifier_item_molotov_thinker_fire:CheckState()
    return {[MODIFIER_STATE_PROVIDES_VISION] = true}
end

function modifier_item_molotov_thinker_fire:IsAura()
    return true
end

function modifier_item_molotov_thinker_fire:GetAuraRadius()
    return nRADIUS
end

function modifier_item_molotov_thinker_fire:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_molotov_thinker_fire:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_molotov_thinker_fire:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
end

function modifier_item_molotov_thinker_fire:GetModifierAura()
    return "modifier_item_molotov_fire"
end

modifier_item_molotov_fire = class ( {})

function modifier_item_molotov_fire:IsDebuff ()
    return true
end

function modifier_item_molotov_fire:DeclareFunctions ()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_item_molotov_fire:GetModifierMoveSpeedBonus_Percentage()
    return -50
end

function modifier_item_molotov_fire:GetEffectName()
    return "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast_debuff.vpcf"
end

function modifier_item_molotov_fire:GetEffectAttachType ()
    return PATTACH_POINT_FOLLOW
end
