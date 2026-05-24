-- Storage.lua

local StorageMod = {}

local pendingLockers = {}
local activeLockers = {}

local floatingLockerKeys = {
    toggleKey = "FloatingLockerToggle",
    rowsKey = "FloatingLockerRows",
    colsKey = "FloatingLockerCols",
    defaultRows = 3,
    defaultCols = 5,
}

local function ApplyLockerSettings(Inventory, configKeys, Config)
    if not Inventory or not Inventory:IsValid() then return end

    local newCols = configKeys.defaultCols
    local newSlots = configKeys.defaultrows * newCols

    if Config[configKeys.toggleKey] then
        newCols = math.floor(tonumber(Config[configKeys.colsKey]) or configKeys.defaultCols)
        newSlots = math.floor(tonumber(Config[configKeys.rowsKey]) or configKeys.defaultrows) * newCols
    end

    if newCols < 1 then newCols = configKeys.defaultCols end

    if Inventory.Columns ~= newCols or Inventory.MaxItems ~= newSlots then
        Inventory:SetMaxItems(newSlots)
        Inventory.MaxItems = newSlots
        Inventory.Columns = newCols
    end
end

function StorageMod.Init(Config)
    local storageMapping = {
        ["/Game/Blueprints/BaseBuilding/BP_Locker_Floor.BP_Locker_Floor_C"] = {
            toggleKey = "FloorLockerToggle",
            rowsKey = "FloorLockerRows",
            colsKey = "FloorLockerCols",
            defaultRows = 6,
            defaultCols = 5,
        },
        ["/Game/Blueprints/BaseBuilding/BP_Locker_Wall.BP_Locker_Wall_C"] = {
            toggleKey = "WallLockerToggle",
            rowsKey = "WallLockerRows",
            colsKey = "WallLockerCols",
            defaultRows = 4,
            defaultCols = 5,
        }
    }

    --[14:06:25.7348776] [Lua] BlueprintGeneratedClass /Game/Blueprints/Items/Deployables/BP_FloatingLocker_Carryable.BP_FloatingLocker_Carryable_C

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

function StorageMod.UpdateLive(Config)
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

function StorageMod.UpdateFloatingLockers(Config)
    local FloatingLockers = FindAllOf("BP_FloatingLocker_Carryable_C")
    if not FloatingLockers then return end

    for _, Locker in ipairs(FloatingLockers) do
        if Locker:IsValid() then
            local Inventory = Locker.UWEInventory

            ApplyLockerSettings(Inventory, floatingLockerKeys, Config)
        end
    end
end

return StorageMod
