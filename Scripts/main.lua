local T = require("Translations/en")
local ConfigManager = require("ConfigManager")
local Storage = require("Storage")
local Crafting = require("Crafting")
local QuickBar = require("QuickBar")

-- Locations
local KismetInternationalizationLibrary = StaticFindObject("/Script/Engine.Default__KismetInternationalizationLibrary")
local langFilePath = "ue4ss/Mods/CapacityQuickBarTweaks/Scripts/Language.txt"
local lastUsedLanguage = "en";

-- Mod Info and Settings
local MOD_INFO = {
    name = "CapacityQuickBarTweaks",
    display = "Capacity & QuickBar Tweaks",
    version = "1.4.3",
    github = "iTestor/Capacity-QuickBar-Tweaks", -- optional
    nexus_id = "252"                             -- optional
}

local function BuildSettings()
    MOD_INFO.display = T.ModInfo.Display

    return {
        { key = "Debug",                  title = T.Debug.Title,                   description = T.Debug.Description,                   type = "toggle", default = false },

        { key = "QuickBarToggle",         title = T.QuickBar.Title.Toggle,         description = T.QuickBar.Description.Toggle,         type = "toggle", default = true },
        { key = "QuickBarSlots",          title = T.QuickBar.Title.Slots,          description = T.QuickBar.Description.Slots,          type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

        { key = "FloorLockerToggle",      title = T.FloorLocker.Title.Toggle,      description = T.FloorLocker.Description.Toggle,      type = "toggle", default = true },
        { key = "FloorLockerRows",        title = T.FloorLocker.Title.Rows,        description = T.FloorLocker.Description.Rows,        type = "slider", default = 6,    min = 1, max = 200, step = 1, format = "integer" },
        { key = "FloorLockerCols",        title = T.FloorLocker.Title.Cols,        description = T.FloorLocker.Description.Cols,        type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

        { key = "WallLockerToggle",       title = T.WallLocker.Title.Toggle,       description = T.WallLocker.Description.Toggle,       type = "toggle", default = true },
        { key = "WallLockerRows",         title = T.WallLocker.Title.Rows,         description = T.WallLocker.Description.Rows,         type = "slider", default = 4,    min = 1, max = 200, step = 1, format = "integer" },
        { key = "WallLockerCols",         title = T.WallLocker.Title.Cols,         description = T.WallLocker.Description.Cols,         type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

        { key = "TailingChestToggle",     title = T.TailingChest.Title.Toggle,     description = T.TailingChest.Description.Toggle,     type = "toggle", default = true },
        { key = "TailingChestRows",       title = T.TailingChest.Title.Rows,       description = T.TailingChest.Description.Rows,       type = "slider", default = 5,    min = 1, max = 200, step = 1, format = "integer" },
        { key = "TailingChestCols",       title = T.TailingChest.Title.Cols,       description = T.TailingChest.Description.Cols,       type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

        { key = "FloatingLockerToggle",   title = T.FloatingLocker.Title.Toggle,   description = T.FloatingLocker.Description.Toggle,   type = "toggle", default = true },
        { key = "FloatingLockerRows",     title = T.FloatingLocker.Title.Rows,     description = T.FloatingLocker.Description.Rows,     type = "slider", default = 3,    min = 1, max = 200, step = 1, format = "integer" },
        { key = "FloatingLockerCols",     title = T.FloatingLocker.Title.Cols,     description = T.FloatingLocker.Description.Cols,     type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

        { key = "TadpolHaulToggle",       title = T.TadpoleHaul.Title.Toggle,      description = T.TadpoleHaul.Description.Toggle,      type = "toggle", default = true },
        { key = "TadpolHaulRows",         title = T.TadpoleHaul.Title.Rows,        description = T.TadpoleHaul.Description.Rows,        type = "slider", default = 6,    min = 1, max = 200, step = 1, format = "integer" },
        { key = "TadpolHaulCols",         title = T.TadpoleHaul.Title.Cols,        description = T.TadpoleHaul.Description.Cols,        type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

        { key = "BioreactorToggle",       title = T.Bioreactor.Title.Toggle,       description = T.Bioreactor.Description.Toggle,       type = "toggle", default = true },
        { key = "BioreactorRows",         title = T.Bioreactor.Title.Rows,         description = T.Bioreactor.Description.Rows,         type = "slider", default = 2,    min = 1, max = 200, step = 1, format = "integer" },
        { key = "BioreactorCols",         title = T.Bioreactor.Title.Cols,         description = T.Bioreactor.Description.Cols,         type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

        { key = "ProcessorStationToggle", title = T.ProcessorStation.Title.Toggle, description = T.ProcessorStation.Description.Toggle, type = "toggle", default = true },
        { key = "ProcessorStationRows",   title = T.ProcessorStation.Title.Rows,   description = T.ProcessorStation.Description.Rows,   type = "slider", default = 3,    min = 1, max = 200, step = 1, format = "integer" },
        { key = "ProcessorStationCols",   title = T.ProcessorStation.Title.Cols,   description = T.ProcessorStation.Description.Cols,   type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },
    }
end

function setSavedLanguage()
    local langFile = io.open(langFilePath, "r")
    if langFile then
        lastUsedLanguage = langFile:read("*a")
        langFile:close()
        lastUsedLanguage = lastUsedLanguage:gsub("%s+", "") -- Leerzeichen/Zeilenumbrüche entfernen

        print("[CapacityQuickBarTweaks] Detected Language.txt change to: " ..
            lastUsedLanguage .. ". Will apply.")
    end
end

function setLanguage()
    if lastUsedLanguage ~= "en" then
        local success, loadedTranslation = pcall(require, "Translations/" .. lastUsedLanguage)
        if success then
            T = loadedTranslation
            print("[CapacityQuickBarTweaks] Loaded translation for: " .. lastUsedLanguage)
            return true
        else
            print("[CapacityQuickBarTweaks] Translation missing for '" ..
                lastUsedLanguage .. "'. Falling back to English.")
            T = require("Translations/en")
            return true
        end
    else
        T = require("Translations/en")
        print("[CapacityQuickBarTweaks] Switched back to English.")
        return true
    end
end

function updateLanguage()
    if KismetInternationalizationLibrary and KismetInternationalizationLibrary:IsValid() then
        local CurrentLanguageObj = KismetInternationalizationLibrary:GetCurrentLanguage()
        local CurrentLanguage = CurrentLanguageObj:ToString()
        local shortCode = string.sub(CurrentLanguage, 1, 2)

        if lastUsedLanguage ~= shortCode then
            lastUsedLanguage = shortCode

            local file = io.open(langFilePath, "w")
            if file then
                file:write(shortCode)
                file:close()
                print("[CapacityQuickBarTweaks] Detected language change to: " ..
                    shortCode .. ". Will apply on next restart.")
            end

            setLanguage()
            return true
        end
    end
    return false
end

-- Setup
setSavedLanguage();
setLanguage()

local SETTINGS = BuildSettings();
local ConfigLib = ConfigManager.Setup(MOD_INFO, SETTINGS)
ConfigLib:WriteManifest()

-- Config-Table (Initial values)
local Config = {
    Debug = false,

    QuickBarToggle = true,
    QuickBarSlots = 5,

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

    BioreactorToggle = true,
    BioreactorRows = 2,
    BioreactorCols = 5,
}

-- Load modules
Storage.Init(Config)
Crafting.Init(Config);
QuickBar.Init(Config)

-- Loop
local loopTicks = 0
LoopAsync(1000, function()
    loopTicks = loopTicks + 1

    if loopTicks > 5 then
        if updateLanguage() then
            SETTINGS = BuildSettings()
            ConfigLib = ConfigManager.Setup(MOD_INFO, SETTINGS)
            ConfigLib:WriteManifest()
            if Config.Debug then print("[CapacityQuickBarTweaks] Manifest rewritten for new language") end
        end
    end

    if ConfigLib:UpdateConfig(Config) then
        if Config.Debug then print("[CapacityQuickBarTweaks] Config updated") end

        Storage.UpdateLive(Config)
        Crafting.UpdateLive(Config)
        QuickBar.UpdateLive(Config)
    end
end)
