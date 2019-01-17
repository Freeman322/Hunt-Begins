if item_health_shot == nil then item_health_shot = class({}) end

function item_health_shot:OnSpellStart()
    if IsServer() and self:IsChargesEnough() then  
        local particle_lifesteal = "particles/items3_fx/octarine_core_lifesteal.vpcf"

        local lifesteal_fx = ParticleManager:CreateParticle(particle_lifesteal, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(lifesteal_fx, 0, self:GetCaster():GetAbsOrigin())
        
        EmitSoundOn("DOTA_Item.Mango.Activate", self:GetCaster())

        self:GetCaster():Heal(self:GetSpecialValueFor("health_restore"), self)

        self:SetCurrentCharges(self:GetCurrentCharges() - 1)
        if self:GetCurrentCharges() <= 0 then self:GetParent():RemoveItem(self) end 
    end 
end
