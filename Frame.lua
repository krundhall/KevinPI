-- Frame.lua
local KPI = KPI_Global
local LCG = LibStub("LibCustomGlow-1.0", true)

-- Frame
KPI.piFrame = CreateFrame("Frame", "KPI_MainFrame", UIParent)
KPI.piFrame:SetFrameStrata("HIGH")
KPI.piFrame:SetMovable(true)
KPI.piFrame:RegisterForDrag("LeftButton")
KPI.piFrame:SetScript("OnDragStart", KPI.piFrame.StartMoving)
KPI.piFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    KPI.GetSafeDB().pos = {point, nil, relPoint, x, y}
end)
KPI.piFrame:Hide()

-- Texture
local piTexture = KPI.piFrame:CreateTexture(nil, "ARTWORK")
piTexture:SetAllPoints()
piTexture:SetTexture(C_Spell.GetSpellTexture(KPI.SPELL_ID) or "Interface\\Icons\\Spell_Holy_PowerInfusion")
piTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

-- Timer
KPI.piTimer = KPI.piFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
KPI.piTimer:SetPoint("TOP", KPI.piFrame, "BOTTOM", 0, -5)
KPI.piTimer:SetTextColor(1, 0.82, 0, 1)

local function SetActiveVisual()
    piTexture:SetDesaturated(false)
    piTexture:SetAlpha(1)
    KPI.piTimer:SetTextColor(1, 0.82, 0, 1)
end

local function SetCooldownVisual()
    piTexture:SetDesaturated(true)
    piTexture:SetAlpha(0.5)
    KPI.piTimer:SetTextColor(0.6, 0.6, 0.6, 1)
end

local function HasPriestInGroup()
    local numMembers = GetNumGroupMembers()
    if numMembers == 0 then return false end
    for i = 1, numMembers do
        local unit = IsInRaid() and ("raid" .. i) or ("party" .. i)
        local _, class = UnitClass(unit)
        if class == "PRIEST" then return true end
    end
    return false
end

-- Functions
function KPI.UpdateTextScale()
    local size = KPI.piFrame:GetWidth()
    local fontSize = math.max(12, size * 0.35)
    KPI.piTimer:SetFont(STANDARD_TEXT_FONT, fontSize, "OUTLINE")
end

function KPI.ToggleGlow(show)
    if not LCG then return end
    local db = KPI.GetSafeDB()
    LCG.ButtonGlow_Stop(KPI.piFrame)
    LCG.PixelGlow_Stop(KPI.piFrame)
    LCG.AutoCastGlow_Stop(KPI.piFrame)
    if show and db.glowType ~= "None" then
        local t = db.glowThickness
        if db.glowType == "Pixel" then LCG.PixelGlow_Start(KPI.piFrame, {1, 1, 0, 1}, 8, 0.25, 20, t)
        elseif db.glowType == "AutoCast" then LCG.AutoCastGlow_Start(KPI.piFrame, {1, 1, 0, 1}, 8, 0.25, t/2)
        else LCG.ButtonGlow_Start(KPI.piFrame) end
    end
    if show and KPI.isPIActive
    and not KPI.isPreview
    and db.soundFile ~= "None" then
        PlaySoundFile(KPI.SOUNDS_DIR .. db.soundFile, db.soundChannel)
    end
end

function KPI.ShowPI()
    if not KPI.isInValidInstance then return end
    if KPI.isPIActive or KPI.isPreview then return end
    KPI.piCDActive = false
    KPI.isPIActive = true
    KPI.piStartTime = GetTime()
    SetActiveVisual()
    KPI.piFrame:Show()
    KPI.ToggleGlow(true)
end

function KPI.HidePI()
    if not KPI.isPIActive then return end
    KPI.isPIActive = false
    KPI.ToggleGlow(false)
    if KPI.isPreview then return end
    if HasPriestInGroup() then
        KPI.piCDActive = true
        KPI.piCDStart = GetTime()
        SetCooldownVisual()
        KPI.piFrame:Show()
    else
        KPI.piFrame:Hide()
    end
end

function KPI.ShowPreview()
    KPI.isPreview = true
    KPI.piStartTime = GetTime()
    SetActiveVisual()
    KPI.piFrame:Show()
    KPI.ToggleGlow(true)
end

function KPI.HidePreview()
    KPI.isPreview = false
    KPI.ToggleGlow(false)
    KPI.piFrame:Hide()
    KPI.piTimer:SetText("")
end

function KPI.UpdateTimer()
    if KPI.isPreview then
        local elapsed = GetTime() - KPI.piStartTime
        local remain = KPI.PI_DURATION - elapsed
        if remain <= 0 then
            KPI.piStartTime = GetTime()
            KPI.piTimer:SetText(math.ceil(KPI.PI_DURATION))
        else
            KPI.piTimer:SetText(math.ceil(remain))
        end
    elseif KPI.isPIActive then
        local remain = KPI.PI_DURATION - (GetTime() - KPI.piStartTime)
        if remain <= 0 then
            KPI.HidePI()
        else
            KPI.piTimer:SetText(math.ceil(remain))
        end
    elseif KPI.piCDActive then
        local remain = KPI.PI_COOLDOWN - (GetTime() - KPI.piCDStart)
        if remain <= 0 then
            KPI.piCDActive = false
            KPI.piFrame:Hide()
            KPI.piTimer:SetText("")
        else
            KPI.piTimer:SetText(math.ceil(remain))
        end
    end
end

function KPI.CheckInstanceStatus()
    local _, instanceType = GetInstanceInfo()
    if instanceType == "party" or instanceType == "raid" then
        KPI.isInValidInstance = true
    else
        KPI.isInValidInstance = false
        KPI.isPIActive = false
        KPI.piCDActive = false
        KPI.piFrame:Hide()
        KPI.ToggleGlow(false)
    end
end

function KPI.UpdateCDVisibility()
    if KPI.piCDActive and not HasPriestInGroup() then
        KPI.piCDActive = false
        KPI.piFrame:Hide()
        KPI.piTimer:SetText("")
    end
end
