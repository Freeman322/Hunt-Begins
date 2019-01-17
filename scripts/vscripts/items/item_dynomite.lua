LinkLuaModifier ("modifier_item_dynomite", "items/item_dynomite.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_dynomite_thinker", "items/item_dynomite.lua", LUA_MODIFIER_MOTION_NONE)

if not item_dynomite then item_dynomite = class({}) end 

function item_dynomite:GetConceptRecipientType()
	return DOTA_SPEECH_USER_ALL
end
--------------------------------------------------------------------------------

function item_dynomite:SpeakTrigger()
	return DOTA_ABILITY_SPEAK_CAST
end

--------------------------------------------------------------------------------

function item_dynomite:GetChannelTime()
	return 1
end

--------------------------------------------------------------------------------

function item_dynomite:OnAbilityPhaseStart()
    if IsServer() then
        if self:IsChargesEnough() then 
            self.vPoint = self:GetCursorPosition()
            
            local caster = self:GetCaster()
            local team_id = caster:GetTeamNumber()
            self.hThinker = CreateModifierThinker(caster, self, "modifier_item_dynomite_thinker", {duration = 4}, self.vPoint, team_id, false)
        end
	end

	return true
end

function item_dynomite:OnChannelFinish( bInterrupted )
    if bInterrupted == false and self.vPoint and self.hThinker then
        local info = 
        {
            Target = self.hThinker,
            Source = self:GetCaster(),
            Ability = self,	
            EffectName = "particles/hunt/dynomite_projectile.vpcf",
            iMoveSpeed = 400,
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
        EmitSoundOn( "Hero_Rattletrap.Battery_Assault_Launch" , self:GetCaster() )

        self:SetCurrentCharges(self:GetCurrentCharges() - 1)
    end
    if bInterrupted then 
        self:EndCooldown()
    end
end

function item_dynomite:OnProjectileHit( hTarget, vLocation )
    if IsServer() then
        local hCaster = self:GetCaster()

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_batrider/batrider_flamebreak_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil );
        ParticleManager:SetParticleControl( nFXIndex, 0, vLocation);
        ParticleManager:SetParticleControl( nFXIndex, 3, vLocation);
        ParticleManager:ReleaseParticleIndex( nFXIndex );

        EmitSoundOnLocationWithCaster(vLocation, "Hero_Rattletrap.Rocket_Flare.Explode", hCaster)

        local units = FindUnitsInRadius(hCaster:GetTeam(), vLocation, nil, 380, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
        for i, target in ipairs(units) do  
            local damage = {
                victim = target,
                attacker = hCaster,
                damage = 1300,
                damage_type = DAMAGE_TYPE_PURE,
                ability = self,
            }

            ApplyDamage( damage )
        end

        AddFOWViewer(self:GetCaster():GetTeamNumber(), vLocation, 400, 5, true)

        self.vPoint = nil
        if self.hThinker then UTIL_Remove(self.hThinker) end 
        if self:GetCurrentCharges() <= 0 then self:GetParent():RemoveItem(self) end 
        return nil
    end
end

if not modifier_item_dynomite_thinker then modifier_item_dynomite_thinker = class({}) end 