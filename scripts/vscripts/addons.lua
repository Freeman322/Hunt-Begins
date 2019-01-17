function CDOTA_Item:IsChargesEnough(bDestroyIfNot)
    return self:GetCurrentCharges() >= 1
end