local T = require("Translations/en")
local ConfigManager = require("ConfigManager")
local Storage = require("Storage")
local QuickBar = require("QuickBar")

-- Locations
local KismetInternationalizationLibrary = StaticFindObject("/Script/Engine.Default__KismetInternationalizationLibrary")
local lastUsedLanguage = "en";

-- Mod Info and Settings
local MOD_INFO = {
    name = "CapacityQuickBarTweaks",
    display = "Capacity & QuickBar Tweaks",
    version = "1.3.0",
    github = "iTestor/Capacity-QuickBar-Tweaks", -- optional
    nexus_id = "252"                             -- optional
}

local function BuildSettings()
    return {
        { key = "Debug",                title = T.Debug.Title,                 description = T.Debug.Description,                 type = "toggle", default = false },

        { key = "FloorLockerToggle",    title = T.FloorLocker.Title.Toggle,    description = T.FloorLocker.Description.Toggle,    type = "toggle", default = true },
        { key = "FloorLockerRows",      title = T.FloorLocker.Title.Rows,      description = T.FloorLocker.Description.Rows,      type = "slider", default = 6,    min = 1, max = 200, step = 1, format = "integer" },
        { key = "FloorLockerCols",      title = T.FloorLocker.Title.Cols,      description = T.FloorLocker.Description.Cols,      type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

        { key = "WallLockerToggle",     title = T.WallLocker.Title.Toggle,     description = T.WallLocker.Description.Toggle,     type = "toggle", default = true },
        { key = "WallLockerRows",       title = T.WallLocker.Title.Rows,       description = T.WallLocker.Description.Rows,       type = "slider", default = 4,    min = 1, max = 200, step = 1, format = "integer" },
        { key = "WallLockerCols",       title = T.WallLocker.Title.Cols,       description = T.WallLocker.Description.Cols,       type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

        { key = "TailingChestToggle",   title = T.TailingChest.Title.Toggle,   description = T.TailingChest.Description.Toggle,   type = "toggle", default = true },
        { key = "TailingChestRows",     title = T.TailingChest.Title.Rows,     description = T.TailingChest.Description.Rows,     type = "slider", default = 5,    min = 1, max = 200, step = 1, format = "integer" },
        { key = "TailingChestCols",     title = T.TailingChest.Title.Cols,     description = T.TailingChest.Description.Cols,     type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

        { key = "FloatingLockerToggle", title = T.FloatingLocker.Title.Toggle, description = T.FloatingLocker.Description.Toggle, type = "toggle", default = true },
        { key = "FloatingLockerRows",   title = T.FloatingLocker.Title.Rows,   description = T.FloatingLocker.Description.Rows,   type = "slider", default = 3,    min = 1, max = 200, step = 1, format = "integer" },
        { key = "FloatingLockerCols",   title = T.FloatingLocker.Title.Cols,   description = T.FloatingLocker.Description.Cols,   type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

        { key = "TadpolHaulToggle",     title = T.TadpoleHaul.Title.Toggle,    description = T.TadpoleHaul.Description.Toggle,    type = "toggle", default = true },
        { key = "TadpolHaulRows",       title = T.TadpoleHaul.Title.Rows,      description = T.TadpoleHaul.Description.Rows,      type = "slider", default = 6,    min = 1, max = 200, step = 1, format = "integer" },
        { key = "TadpolHaulCols",       title = T.TadpoleHaul.Title.Cols,      description = T.TadpoleHaul.Description.Cols,      type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

        { key = "QuickBarToggle",       title = T.QuickBar.Title.Toggle,       description = T.QuickBar.Description.Toggle,       type = "toggle", default = true },
        { key = "QuickBarSlots",        title = T.QuickBar.Title.Slots,        description = T.QuickBar.Description.Slots,        type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" }
    }
end

function updateLanguage()
    if KismetInternationalizationLibrary and KismetInternationalizationLibrary:IsValid() then
        local CurrentLanguageObj = KismetInternationalizationLibrary:GetCurrentLanguage()
        local CurrentLanguage = CurrentLanguageObj:ToString()
        local shortCode = string.sub(CurrentLanguage, 1, 2)

        -- Nur etwas machen, wenn sich die Sprache wirklich geändert hat
        if lastUsedLanguage ~= shortCode then
            lastUsedLanguage = shortCode -- Direkt updaten, damit es nicht spammt

            if shortCode ~= "en" then
                local success, loadedTranslation = pcall(require, "Translations/" .. shortCode)
                if success then
                    T = loadedTranslation
                    print("[CapacityQuickBarTweaks] Loaded translation for: " .. shortCode)
                    return true -- Signalisiert: Sprache wurde erfolgreich gewechselt
                else
                    print("[CapacityQuickBarTweaks] Translation missing for '" ..
                        shortCode .. "'. Falling back to English.")
                    T = require("Translations/en") -- Fallback auf EN erzwingen
                    return true
                end
            else
                -- Wieder zurück auf Englisch gewechselt
                T = require("Translations/en")
                print("[CapacityQuickBarTweaks] Switched back to English.")
                return true
            end
        end
    end
    return false
end

-- Setup
updateLanguage()

local SETTINGS = BuildSettings();
local ConfigLib = ConfigManager.Setup(MOD_INFO, SETTINGS)
ConfigLib:WriteManifest()

-- Config-Table (Initial values)
local Config = {
    Debug = false,

    FloorLockerToggle = true,
    FloorLockerRows = 6,
    FloorLockerCols = 5,

    WallLockerToggle = true,
    WallLockerRows = 4,
    WallLockerCols = 5,

    TailingChestToggle = true,
    TailingChestRows = 5,
    TailingChestCols = 5,

    FloatingLockerToggle = true,
    FloatingLockerRows = 3,
    FloatingLockerCols = 5,

    TadpolHaulToggle = true,
    TadpolHaulRows = 6,
    TadpolHaulCols = 5,

    QuickBarToggle = true,
    QuickBarSlots = 5,
}

-- Load modules
Storage.Init(Config)
QuickBar.Init(Config)

-- Loop
LoopAsync(1000, function()
    if updateLanguage() then
        SETTINGS = BuildSettings()
        ConfigLib = ConfigManager.Setup(MOD_INFO, SETTINGS)
        ConfigLib:WriteManifest()
        if Config.Debug then print("[CapacityQuickBarTweaks] Manifest rewritten for new language") end
    end

    if ConfigLib:UpdateConfig(Config) then
        if Config.Debug then print("[CapacityQuickBarTweaks] Config updated") end

        Storage.UpdateLive(Config)
        QuickBar.UpdateLive(Config)
    end
end)
