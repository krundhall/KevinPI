-- Core.lua
local KPI = {}
KPI_Global = KPI

-- Constants
KPI.addonName = "KevinPI"
KPI.SPELL_ID = 10060
KPI.PI_DURATION = 15
KPI.SOUNDS_DIR = "Interface\\Addons\\KevinPI\\sounds\\"

-- Constants
KPI.PI_COOLDOWN = 120

-- State
KPI.isPIActive = false
KPI.isPreview = false
KPI.piStartTime = 0
KPI.justCastPI = false
KPI.isInValidInstance = false
KPI.lastHaste = 0
KPI.piCDActive = false
KPI.piCDStart = 0

-- DB
function KPI.GetSafeDB()
    if not KevinPIDB then
        KevinPIDB = {
            size = 96,
            pos = {"CENTER", nil, "CENTER", 0, 120},
            glowType = "Button",
            glowThickness = 2,
            showSelfPI = true,
            soundFile = "None",
            soundChannel = "Master",
        }
    end
    return KevinPIDB
end
