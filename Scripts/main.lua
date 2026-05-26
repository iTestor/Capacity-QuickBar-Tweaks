local ConfigManager = require("ConfigManager")
local Storage = require("Storage")
local QuickBar = require("QuickBar")

-- Mod Info and Settings
local MOD_INFO = {
    name = "CapacityQuickBarTweaks",
    display = "Capacity & QuickBar Tweaks",
    version = "1.2.0",
    github = "iTestor/Capacity-QuickBar-Tweaks", -- optional
    nexus_id = "252"                             -- optional
}

local SETTINGS = {
    { key = "Debug",                title = "Enable Debug",           description = "Enable debug console logs",                                                                                      type = "toggle", default = false },

    { key = "FloorLockerToggle",    title = "Enable Floor Locker",    description = "Enable custom storage capacity for Floor locker",                                                                type = "toggle", default = true },
    { key = "FloorLockerRows",      title = "Floor Locker Rows",      description = "Rows in Floor Locker",                                                                                           type = "slider", default = 6,    min = 1, max = 200, step = 1, format = "integer" },
    { key = "FloorLockerCols",      title = "Floor Locker Cols",      description = "Columns in Floor Locker",                                                                                        type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

    { key = "WallLockerToggle",     title = "Enable Wall Locker",     description = "Enable custom storage capacity for Wall locker",                                                                 type = "toggle", default = true },
    { key = "WallLockerRows",       title = "Wall Locker Rows",       description = "Rows in Wall Locker",                                                                                            type = "slider", default = 4,    min = 1, max = 200, step = 1, format = "integer" },
    { key = "WallLockerCols",       title = "Wall Locker Cols",       description = "Columns in Wall Locker",                                                                                         type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

    { key = "TailingChestToggle",   title = "Enable Tailing Chest",   description = "Enable custom storage capacity for Tailing Chest",                                                               type = "toggle", default = true },
    { key = "TailingChestRows",     title = "Tailing Chest Rows",     description = "Rows in Tailing Chest",                                                                                          type = "slider", default = 5,    min = 1, max = 200, step = 1, format = "integer" },
    { key = "TailingChestCols",     title = "Tailing Chest Cols",     description = "Columns in Tailing Chest",                                                                                       type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

    { key = "FloatingLockerToggle", title = "Enable Portable Locker", description = "Enable custom storage capacity for Portable locker",                                                             type = "toggle", default = true },
    { key = "FloatingLockerRows",   title = "Portable Locker Rows",   description = "Rows in Portable Locker",                                                                                        type = "slider", default = 3,    min = 1, max = 200, step = 1, format = "integer" },
    { key = "FloatingLockerCols",   title = "Portable Locker Cols",   description = "Columns in Portable Locker",                                                                                     type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

    { key = "TadpolHaulToggle",     title = "Enable Tadpol Haul",     description = "Enable custom storage capacity for Tadpol Haul",                                                                 type = "toggle", default = true },
    { key = "TadpolHaulRows",       title = "Tadpol Haul Rows",       description = "Rows in Tadpol Haul",                                                                                            type = "slider", default = 6,    min = 1, max = 200, step = 1, format = "integer" },
    { key = "TadpolHaulCols",       title = "Tadpol Haul Cols",       description = "Columns in Tadpol Haul",                                                                                         type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" },

    { key = "QuickBarToggle",       title = "Enable QuickBar Slots",  description = "Enable or disable custom quickbar slots. When disabled, the quickbar reverts to the game's default slot count.", type = "toggle", default = true },
    { key = "QuickBarSlots",        title = "QuickBar Slots",         description = "Number of QuickBar Slots (1-10)",                                                                                type = "slider", default = 5,    min = 1, max = 10,  step = 1, format = "integer" }
}

-- Setup
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
    if ConfigLib:UpdateConfig(Config) then
        if Config.Debug then print("[CapacityQuickBarTweaks] Config updated") end

        Storage.UpdateLive(Config)
        QuickBar.UpdateLive(Config)
    end
end)
