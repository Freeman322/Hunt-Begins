modifier_thinker_delay = class ({})

function modifier_thinker_delay:OnCreated(event)
    if IsServer() then
        local nFXIndex = ParticleManager:CreateParticle( "particles/customgames/capturepoints/cp_neutral_3.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
        ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetAbsOrigin())
        self:AddParticle( nFXIndex, false, false, -1, false, true )

        EmitSoundOn("PlusPopup.expired", thinker)

        self._hKiller = event.killer
    end
end

function modifier_thinker_delay:OnDestroy()
    if IsServer() then
        local nFXIndex = ParticleManager:CreateParticle( "particles/neutral_fx/roshan_death_aegis_starfall.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
        ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetAbsOrigin());
        ParticleManager:ReleaseParticleIndex( nFXIndex );

        EmitSoundOn( "underlord_debut_takeover_stinger", self:GetParent() )

        for i=1,2 do
            local newItem = CreateItem("item_trophy", nil, nil)
            CreateItemOnPositionForLaunch(self:GetParent():GetOrigin(), newItem)
        end
    end
end
