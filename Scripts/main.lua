local ConfigManager = require("ConfigManager")
local Storage = require("Storage")
local QuickBar = require("QuickBar")

-- Mod Info and Settings
local MOD_INFO = {
    name = "CapacityQuickBarTweaks",
    display = "Capacity & QuickBar Tweaks",
    version = "1.0.4",
    github = "iTestor/Capacity-QuickBar-Tweaks", -- optional
    nexus_id = "252"                             -- optional
}

local SETTINGS = {
    { key = "Debug",             title = "Enable Debug",          description = "Enable debug console logs",                                                                                      type = "toggle", default = false },

    { key = "FloorLockerToggle", title = "Enable Floor Locker",   description = "Enable custom storage capacity for floor locker",                                                                type = "toggle", default = true },
    { key = "FloorLockerSlots",  title = "Floor Locker Slots",    description = "Max Items in Floor Locker",                                                                                      type = "slider", default = 30,   min = 10, max = 200, step = 1, format = "integer" },
    { key = "FloorLockerCols",   title = "Floor Locker Cols",     description = "Columns in Floor Locker",                                                                                        type = "slider", default = 5,    min = 1,  max = 10,  step = 1, format = "integer" },

    { key = "WallLockerToggle",  title = "Enable Wall Locker",    description = "Enable custom storage capacity for wall locker",                                                                 type = "toggle", default = true },
    { key = "WallLockerSlots",   title = "Wall Locker Slots",     description = "Max Items in Wall Locker",                                                                                       type = "slider", default = 20,   min = 10, max = 150, step = 1, format = "integer" },
    { key = "WallLockerCols",    title = "Wall Locker Cols",      description = "Columns in Wall Locker",                                                                                         type = "slider", default = 5,    min = 1,  max = 10,  step = 1, format = "integer" },

    { key = "QuickBarToggle",    title = "Enable QuickBar Slots", description = "Enable or disable custom quickbar slots. When disabled, the quickbar reverts to the game's default slot count.", type = "toggle", default = true },
    { key = "QuickBarSlots",     title = "QuickBar Slots",        description = "Number of QuickBar Slots (1-10)",                                                                                type = "slider", default = 5,    min = 1,  max = 10,  step = 1, format = "integer" }
}

-- Setup
local ConfigLib = ConfigManager.Setup(MOD_INFO, SETTINGS)
ConfigLib:WriteManifest()

-- Config-Table (Initial values)
local Config = {
    Debug = false,

    FloorLockerToggle = true,
    FloorLockerSlots = 30,
    FloorLockerCols = 5,

    WallLockerToggle = true,
    WallLockerSlots = 20,
    WallLockerCols = 5,

    QuickBarToggle = true,
    QuickBarSlots = 5,
}

-- Load modules
Storage.Init(Config)
QuickBar.Init(Config)

-- Loop
LoopAsync(1000, function()
    if ConfigLib:UpdateConfig(Config) then
        if Config.Debug then print("[CapacityQuickBarTweaks] Config updated") end

        Storage.UpdateLive(Config, DefaultConfig)
        QuickBar.UpdateLive(Config)
    end
end)
