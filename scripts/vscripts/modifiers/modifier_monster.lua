
if modifier_monster == nil then modifier_monster = class({}) end
function modifier_monster:IsHidden() return true end
function modifier_monster:IsPurgable() return false end
function modifier_monster:RemoveOnDeath() return false end

function modifier_monster:OnCreated(params)
	if IsServer() then 
		self.iIterations = 37

        self.vCenter = Vector( 1399, 804, 128 )
    
		self:StartIntervalThink(1)
    end 
end

function modifier_monster:OnIntervalThink()
	if IsServer() then 
		self.iIterations = self.iIterations + 1
		if self.iIterations >= 40 then 
			if self:GetParent():IsAttacking() then return end 

			ExecuteOrderFromTable({
				UnitIndex = self:GetParent():entindex(),
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
				Position = self.vCenter + RandomVector( 9500 )
			})

			self.iIterations = 0
		end

		local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetParent(), 540, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false )
		if #units > 0 then 
			ExecuteOrderFromTable({
				UnitIndex = self:GetParent():entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
				Target = units[1]:entindex()
			})
		end 
    end 
end

function modifier_monster:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function modifier_monster:OnTakeDamage(params)
	if params.unit == self:GetParent() then
		if self:GetParent():IsAttacking() then return end 
		
		ExecuteOrderFromTable({
			UnitIndex = self:GetParent():entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Target = params.attacker:entindex()
		})
	end
end