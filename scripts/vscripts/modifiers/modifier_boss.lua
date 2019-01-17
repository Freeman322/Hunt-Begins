
if modifier_boss == nil then modifier_boss = class({}) end
function modifier_boss:IsHidden() return true end
function modifier_boss:IsPurgable() return false end
function modifier_boss:RemoveOnDeath() return false end

function modifier_boss:OnCreated(params)
    if IsServer() then 
        self._bFired = false
		self:StartIntervalThink(1)
    end 
end

function modifier_boss:OnIntervalThink()
	if IsServer() and not self._bFired then 
		local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetParent(), 540, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false )
		if #units > 0 then 
            self._bFired = true

            CustomGameEventManager:Send_ServerToTeam(units[1]:GetTeamNumber(), "on_boss_found", {
                boss = self:GetParent():GetUnitLabel(),
                unit_name = self:GetParent():GetUnitName()
			})
			
			GameRules.GameMode:AddExperience(units[1]:GetPlayerOwnerID(), GameRules.GameMode.BOSS_FOUND)
		end 
    end 
end

function modifier_boss:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function modifier_boss:OnTakeDamage(params)
	if params.unit == self:GetParent() then
		
	end
end