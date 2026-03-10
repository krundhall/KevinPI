-- Events.lua
local KPI = KPI_Global

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    local arg1 = ...
    if event == "ADDON_LOADED" and arg1 == KPI.addonName then
        KPI.GetSafeDB()
    elseif event == "GROUP_ROSTER_UPDATE" then
        KPI.UpdateCDVisibility()
    elseif event == "PLAYER_LOGIN" or event == "ZONE_CHANGED_NEW_AREA" then
        KPI.CheckInstanceStatus()
        if event == "PLAYER_LOGIN" then
            KPI.ApplySettings()
            C_Timer.After(0.5, function()
                self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
                self:RegisterEvent("UNIT_AURA")
            end)
            self:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = (self.elapsed or 0) + elapsed
                if self.elapsed > 0.1 then KPI.UpdateTimer(); self.elapsed = 0 end
            end)
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = ...
        if unit == "player" and spellID == KPI.SPELL_ID then
            local db = KPI.GetSafeDB()
            if db.showSelfPI then
                KPI.justCastPI = false
            else
                KPI.justCastPI = true
                C_Timer.After(2, function() KPI.justCastPI = false end)
            end
        end
    elseif event == "UNIT_AURA" then
        if not KPI.isInValidInstance then return end
        local unit = ...
        if unit ~= "player" then return end
        local currentHaste = GetHaste() or 0
        local ratio = (1 + currentHaste/100) / (1 + KPI.lastHaste/100)
        if ratio >= 1.19 and ratio <= 1.21 then
            if not KPI.isPIActive and not KPI.justCastPI then KPI.ShowPI() end
        end
        if KPI.isPIActive then
            local remain = KPI.PI_DURATION - (GetTime() - KPI.piStartTime)
            if remain <= 0 or ratio <= 0.84 then KPI.HidePI() end
        end
        KPI.lastHaste = currentHaste
    end
end)
