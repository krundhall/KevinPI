-- UI.lua
local KPI = KPI_Global

local GLOW_TYPES = {
    { text = "None",     value = "None" },
    { text = "Button",   value = "Button" },
    { text = "Pixel",    value = "Pixel" },
    { text = "AutoCast", value = "AutoCast" }
}
local SOUND_CHANNELS = {
    { text = "Master",   value = "Master" },
    { text = "SFX",      value = "SFX" },
    { text = "Music",    value = "Music" },
    { text = "Dialog",   value = "Dialog" },
    { text = "Ambience", value = "Ambience" }
}

local SOUND_FILES = { { text = "None", value = "None" } }
for _, file in ipairs(KPI.soundFiles) do
    table.insert(SOUND_FILES, { text = file, value = file })
end

local previewSoundHandle = nil
local function PlayPreview(file, channel)
    if previewSoundHandle then StopSound(previewSoundHandle) end
    local _, handle = PlaySoundFile(KPI.SOUNDS_DIR .. file, channel)
    previewSoundHandle = handle
end

-------------------------------------------------
-- Config Panel
-------------------------------------------------
KPI.config = CreateFrame("Frame", "KPI_ConfigPanel", UIParent, "BackdropTemplate")
KPI.config:SetFrameStrata("HIGH")
KPI.config:SetSize(350, 640)
KPI.config:SetPoint("CENTER")
KPI.config:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12
})
KPI.config:SetBackdropColor(0, 0, 0, 0.8)
KPI.config:SetMovable(true)
KPI.config:EnableMouse(true)
KPI.config:RegisterForDrag("LeftButton")
KPI.config:SetScript("OnDragStart", KPI.config.StartMoving)
KPI.config:SetScript("OnDragStop", KPI.config.StopMovingOrSizing)
KPI.config:Hide()

local title = KPI.config:CreateFontString(nil, "OVERLAY")
title:SetPoint("TOP", 0, -15)
title:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")
title:SetText("Kevin PI Settings")

local close = CreateFrame("Button", nil, KPI.config, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -4, -4)
close:SetScript("OnClick", function()
    KPI.config:Hide()
    KPI.HidePreview()
    KPI.HideCDPreview()
    KPI.piFrame:EnableMouse(false)
    KPI.piCDFrame:EnableMouse(false)
end)

-------------------------------------------------
-- Icon Size
-------------------------------------------------
local sizeSlider = CreateFrame("Slider", "KPI_SizeSlider", KPI.config, "OptionsSliderTemplate")
sizeSlider:SetPoint("TOP", 0, -60)
sizeSlider:SetMinMaxValues(40, 400)
sizeSlider:SetValueStep(1)
sizeSlider:SetWidth(220)
_G["KPI_SizeSliderText"]:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
_G["KPI_SizeSliderText"]:SetText("Icon Size")
sizeSlider:SetScript("OnValueChanged", function(self, v)
    local db = KPI.GetSafeDB()
    db.size = math.floor(v)
    KPI.piFrame:SetSize(db.size, db.size)
    KPI.piCDFrame:SetSize(db.size, db.size)
    KPI.UpdateTextScale()
    if KPI.piFrame:IsShown() then KPI.ToggleGlow(true) end
end)

-------------------------------------------------
-- Glow Thickness
-------------------------------------------------
local thickSlider = CreateFrame("Slider", "KPI_ThickSlider", KPI.config, "OptionsSliderTemplate")
thickSlider:SetPoint("TOP", 0, -110)
thickSlider:SetMinMaxValues(1, 10)
thickSlider:SetValueStep(0.5)
thickSlider:SetWidth(220)
_G["KPI_ThickSliderText"]:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
_G["KPI_ThickSliderText"]:SetText("Glow Thickness")
thickSlider:SetScript("OnValueChanged", function(self, v)
    local db = KPI.GetSafeDB()
    db.glowThickness = v
    if KPI.piFrame:IsShown() then KPI.ToggleGlow(true) end
end)

-------------------------------------------------
-- Glow Type
-------------------------------------------------
local glowLabel = KPI.config:CreateFontString(nil, "OVERLAY")
glowLabel:SetPoint("TOP", 0, -155)
glowLabel:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
glowLabel:SetText("Glow Type")

local glowDropdown = CreateFrame("Frame", "KPI_GlowDropdown", KPI.config, "UIDropDownMenuTemplate")
glowDropdown:SetPoint("TOP", 0, -175)
UIDropDownMenu_SetWidth(glowDropdown, 180)

-------------------------------------------------
-- Sound
-------------------------------------------------
local soundLabel = KPI.config:CreateFontString(nil, "OVERLAY")
soundLabel:SetPoint("TOP", 0, -220)
soundLabel:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
soundLabel:SetText("Sound")

local soundDropdown = CreateFrame("Frame", "KPI_SoundDropdown", KPI.config, "UIDropDownMenuTemplate")
soundDropdown:SetPoint("TOP", 0, -240)
UIDropDownMenu_SetWidth(soundDropdown, 180)

-------------------------------------------------
-- Sound Channel
-------------------------------------------------
local channelLabel = KPI.config:CreateFontString(nil, "OVERLAY")
channelLabel:SetPoint("TOP", 0, -285)
channelLabel:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
channelLabel:SetText("Sound Channel")

local channelDropdown = CreateFrame("Frame", "KPI_ChannelDropdown", KPI.config, "UIDropDownMenuTemplate")
channelDropdown:SetPoint("TOP", 0, -305)
UIDropDownMenu_SetWidth(channelDropdown, 180)

-------------------------------------------------
-- Show Self PI
-------------------------------------------------
local selfPICheck = CreateFrame("CheckButton", "KPI_SelfPICheck", KPI.config, "ChatConfigCheckButtonTemplate")
selfPICheck:SetPoint("TOP", -100, -350)
_G["KPI_SelfPICheckText"]:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
_G["KPI_SelfPICheckText"]:SetText("Show My Own PI")
selfPICheck:SetScript("OnClick", function(self)
    KPI.GetSafeDB().showSelfPI = self:GetChecked()
end)

-------------------------------------------------
-- Active Icon Position
-------------------------------------------------
local iconPosLabel = KPI.config:CreateFontString(nil, "OVERLAY")
iconPosLabel:SetPoint("TOP", 0, -390)
iconPosLabel:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
iconPosLabel:SetText("Active Icon Position")

local iconXSlider = CreateFrame("Slider", "KPI_IconXSlider", KPI.config, "OptionsSliderTemplate")
iconXSlider:SetPoint("TOP", -15, -423)
iconXSlider:SetMinMaxValues(-1000, 1000)
iconXSlider:SetValueStep(1)
iconXSlider:SetWidth(180)
_G["KPI_IconXSliderText"]:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
_G["KPI_IconXSliderText"]:SetText("X")

local iconXInput = CreateFrame("EditBox", "KPI_IconXInput", KPI.config, "InputBoxTemplate")
iconXInput:SetPoint("LEFT", iconXSlider, "RIGHT", 8, 0)
iconXInput:SetSize(55, 20)
iconXInput:SetAutoFocus(false)

iconXSlider:SetScript("OnValueChanged", function(self, v)
    local db = KPI.GetSafeDB()
    db.pos[4] = math.floor(v)
    iconXInput:SetText(tostring(db.pos[4]))
    KPI.piFrame:ClearAllPoints()
    KPI.piFrame:SetPoint(db.pos[1], UIParent, db.pos[3], db.pos[4], db.pos[5])
end)
iconXInput:SetScript("OnEnterPressed", function(self)
    local v = tonumber(self:GetText())
    if v then iconXSlider:SetValue(v) end
    self:ClearFocus()
end)

local iconYSlider = CreateFrame("Slider", "KPI_IconYSlider", KPI.config, "OptionsSliderTemplate")
iconYSlider:SetPoint("TOP", -15, -473)
iconYSlider:SetMinMaxValues(-700, 700)
iconYSlider:SetValueStep(1)
iconYSlider:SetWidth(180)
_G["KPI_IconYSliderText"]:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
_G["KPI_IconYSliderText"]:SetText("Y")

local iconYInput = CreateFrame("EditBox", "KPI_IconYInput", KPI.config, "InputBoxTemplate")
iconYInput:SetPoint("LEFT", iconYSlider, "RIGHT", 8, 0)
iconYInput:SetSize(55, 20)
iconYInput:SetAutoFocus(false)

iconYSlider:SetScript("OnValueChanged", function(self, v)
    local db = KPI.GetSafeDB()
    db.pos[5] = math.floor(v)
    iconYInput:SetText(tostring(db.pos[5]))
    KPI.piFrame:ClearAllPoints()
    KPI.piFrame:SetPoint(db.pos[1], UIParent, db.pos[3], db.pos[4], db.pos[5])
end)
iconYInput:SetScript("OnEnterPressed", function(self)
    local v = tonumber(self:GetText())
    if v then iconYSlider:SetValue(v) end
    self:ClearFocus()
end)

-------------------------------------------------
-- Cooldown Icon Position
-------------------------------------------------
local cdPosLabel = KPI.config:CreateFontString(nil, "OVERLAY")
cdPosLabel:SetPoint("TOP", 0, -515)
cdPosLabel:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
cdPosLabel:SetText("Cooldown Icon Position")

local cdXSlider = CreateFrame("Slider", "KPI_CDXSlider", KPI.config, "OptionsSliderTemplate")
cdXSlider:SetPoint("TOP", -15, -548)
cdXSlider:SetMinMaxValues(-1000, 1000)
cdXSlider:SetValueStep(1)
cdXSlider:SetWidth(180)
_G["KPI_CDXSliderText"]:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
_G["KPI_CDXSliderText"]:SetText("X")

local cdXInput = CreateFrame("EditBox", "KPI_CDXInput", KPI.config, "InputBoxTemplate")
cdXInput:SetPoint("LEFT", cdXSlider, "RIGHT", 8, 0)
cdXInput:SetSize(55, 20)
cdXInput:SetAutoFocus(false)

cdXSlider:SetScript("OnValueChanged", function(self, v)
    local db = KPI.GetSafeDB()
    db.cdPos[4] = math.floor(v)
    cdXInput:SetText(tostring(db.cdPos[4]))
    KPI.piCDFrame:ClearAllPoints()
    KPI.piCDFrame:SetPoint(db.cdPos[1], UIParent, db.cdPos[3], db.cdPos[4], db.cdPos[5])
end)
cdXInput:SetScript("OnEnterPressed", function(self)
    local v = tonumber(self:GetText())
    if v then cdXSlider:SetValue(v) end
    self:ClearFocus()
end)

local cdYSlider = CreateFrame("Slider", "KPI_CDYSlider", KPI.config, "OptionsSliderTemplate")
cdYSlider:SetPoint("TOP", -15, -598)
cdYSlider:SetMinMaxValues(-700, 700)
cdYSlider:SetValueStep(1)
cdYSlider:SetWidth(180)
_G["KPI_CDYSliderText"]:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
_G["KPI_CDYSliderText"]:SetText("Y")

local cdYInput = CreateFrame("EditBox", "KPI_CDYInput", KPI.config, "InputBoxTemplate")
cdYInput:SetPoint("LEFT", cdYSlider, "RIGHT", 8, 0)
cdYInput:SetSize(55, 20)
cdYInput:SetAutoFocus(false)

cdYSlider:SetScript("OnValueChanged", function(self, v)
    local db = KPI.GetSafeDB()
    db.cdPos[5] = math.floor(v)
    cdYInput:SetText(tostring(db.cdPos[5]))
    KPI.piCDFrame:ClearAllPoints()
    KPI.piCDFrame:SetPoint(db.cdPos[1], UIParent, db.cdPos[3], db.cdPos[4], db.cdPos[5])
end)
cdYInput:SetScript("OnEnterPressed", function(self)
    local v = tonumber(self:GetText())
    if v then cdYSlider:SetValue(v) end
    self:ClearFocus()
end)

-------------------------------------------------
-- Dropdown Initializers
-------------------------------------------------
UIDropDownMenu_Initialize(glowDropdown, function(self, level)
    local db = KPI.GetSafeDB()
    for _, g in ipairs(GLOW_TYPES) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = g.text
        info.value = g.value
        info.func = function(self)
            db.glowType = self.value
            UIDropDownMenu_SetText(glowDropdown, g.text)
            if KPI.piFrame:IsShown() then KPI.ToggleGlow(true) end
        end
        info.checked = (db.glowType == g.value)
        UIDropDownMenu_AddButton(info)
    end
end)

UIDropDownMenu_Initialize(soundDropdown, function(self, level)
    local db = KPI.GetSafeDB()
    for _, s in ipairs(SOUND_FILES) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = s.text
        info.value = s.value
        info.func = function(self)
            db.soundFile = self.value
            UIDropDownMenu_SetText(soundDropdown, s.text)
            if self.value ~= "None" then
                PlayPreview(self.value, db.soundChannel)
            end
        end
        info.checked = (db.soundFile == s.value)
        UIDropDownMenu_AddButton(info)
    end
end)

UIDropDownMenu_Initialize(channelDropdown, function(self, level)
    local db = KPI.GetSafeDB()
    for _, c in ipairs(SOUND_CHANNELS) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = c.text
        info.value = c.value
        info.func = function(self)
            db.soundChannel = self.value
            UIDropDownMenu_SetText(channelDropdown, c.text)
            if db.soundFile ~= "None" then
                PlayPreview(db.soundFile, self.value)
            end
        end
        info.checked = (db.soundChannel == c.value)
        UIDropDownMenu_AddButton(info)
    end
end)

-------------------------------------------------
-- Apply Settings
-------------------------------------------------
function KPI.ApplySettings()
    local db = KPI.GetSafeDB()

    -- Active frame
    KPI.piFrame:SetSize(db.size, db.size)
    local p = db.pos
    KPI.piFrame:ClearAllPoints()
    KPI.piFrame:SetPoint(p[1], UIParent, p[3], p[4], p[5])

    -- CD frame
    KPI.piCDFrame:SetSize(db.size, db.size)
    local cp = db.cdPos
    KPI.piCDFrame:ClearAllPoints()
    KPI.piCDFrame:SetPoint(cp[1], UIParent, cp[3], cp[4], cp[5])

    sizeSlider:SetValue(db.size)
    thickSlider:SetValue(db.glowThickness)
    selfPICheck:SetChecked(db.showSelfPI)

    iconXSlider:SetValue(db.pos[4])
    iconYSlider:SetValue(db.pos[5])
    iconXInput:SetText(tostring(db.pos[4]))
    iconYInput:SetText(tostring(db.pos[5]))

    cdXSlider:SetValue(db.cdPos[4])
    cdYSlider:SetValue(db.cdPos[5])
    cdXInput:SetText(tostring(db.cdPos[4]))
    cdYInput:SetText(tostring(db.cdPos[5]))

    KPI.UpdateTextScale()
    for _, g in ipairs(GLOW_TYPES) do
        if g.value == db.glowType then UIDropDownMenu_SetText(glowDropdown, g.text) end
    end
    for _, s in ipairs(SOUND_FILES) do
        if s.value == db.soundFile then UIDropDownMenu_SetText(soundDropdown, s.text) end
    end
    for _, c in ipairs(SOUND_CHANNELS) do
        if c.value == db.soundChannel then UIDropDownMenu_SetText(channelDropdown, c.text) end
    end
end

-------------------------------------------------
-- Slash Command
-------------------------------------------------
SLASH_KPIALERT1 = "/kpi"
SlashCmdList["KPIALERT"] = function()
    if KPI.config:IsShown() then
        KPI.config:Hide()
        KPI.HidePreview()
        KPI.HideCDPreview()
        KPI.piFrame:EnableMouse(false)
        KPI.piCDFrame:EnableMouse(false)
    else
        KPI.config:Show()
        KPI.ShowPreview()
        KPI.ShowCDPreview()
        KPI.piFrame:EnableMouse(true)
        KPI.piCDFrame:EnableMouse(true)
        KPI.ApplySettings()
    end
end
