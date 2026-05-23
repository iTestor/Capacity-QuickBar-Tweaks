-- Storage.lua

local StorageMod = {}

local pendingLockers = {}
local activeLockers = {}

local function ApplyLockerSettings(inventoryComp, configKeys, Config)
    if not inventoryComp or not inventoryComp:IsValid() then return end

    local newSlots = configKeys.defaultSlots
    local newCols = configKeys.defaultCols

    if Config[configKeys.toggleKey] then
        newSlots = math.floor(tonumber(Config[configKeys.slotsKey]) or configKeys.defaultSlots)
        newCols = math.floor(tonumber(Config[configKeys.colsKey]) or configKeys.defaultCols)
    end

    if newCols < 1 then newCols = configKeys.defaultCols end

    inventoryComp:SetMaxItems(newSlots)
    inventoryComp.MaxItems = newSlots
    inventoryComp.Columns = newCols
end

function StorageMod.Init(Config)
    local storageMapping = {
        ["/Game/Blueprints/BaseBuilding/BP_Locker_Floor.BP_Locker_Floor_C"] = {
            toggleKey = "FloorLockerToggle",
            slotsKey = "FloorLockerSlots",
            colsKey = "FloorLockerCols",
            defaultSlots = 30,
            defaultCols = 5,
        },
        ["/Game/Blueprints/BaseBuilding/BP_Locker_Wall.BP_Locker_Wall_C"] = {
            toggleKey = "WallLockerToggle",
            slotsKey = "WallLockerSlots",
            colsKey = "WallLockerCols",
            defaultSlots = 20,
            defaultCols = 5,
        }
    }

    -- 1. Intercept lockers when they spawn
    for classPath, configKeys in pairs(storageMapping) do
        NotifyOnNewObject(classPath, function(CreatedObject)
            if CreatedObject:IsValid() then
                local inventoryComp = CreatedObject.Inventory or CreatedObject.UWEInventory

                ApplyLockerSettings(inventoryComp, configKeys, Config)

                table.insert(pendingLockers, {
                    obj = CreatedObject,
                    keys = configKeys,
                    ticks = 0
                })

                -- Add to cache
                activeLockers[CreatedObject] = configKeys
            end
        end)
    end

    -- 2. Secret timer (runs once every second)
    LoopAsync(1000, function()
        -- Handle pending lockers
        if #pendingLockers > 0 then
            for i = #pendingLockers, 1, -1 do
                local data = pendingLockers[i]
                data.ticks = data.ticks + 1

                if data.ticks >= 2 then
                    local locker = data.obj
                    if locker and locker:IsValid() then
                        local inventoryComp = locker.Inventory or locker.UWEInventory
                        ApplyLockerSettings(inventoryComp, data.keys, Config)
                    end
                    table.remove(pendingLockers, i)
                end
            end
        end
    end)
end

function StorageMod.UpdateLive(Config, DefaultConfig)
    -- Clean up and update cached lockers
    for locker, keys in pairs(activeLockers) do
        if locker:IsValid() then
            local inventoryComp = locker.Inventory or locker.UWEInventory
            ApplyLockerSettings(inventoryComp, keys, Config)
        else
            -- Remove if no longer valid
            activeLockers[locker] = nil
        end
    end

    if Config.Debug then print("[CapacityQuickBarTweaks] Updated cached lockers") end
end

return StorageMod
