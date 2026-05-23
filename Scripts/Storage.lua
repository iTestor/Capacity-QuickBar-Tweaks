-- Storage.lua

local StorageMod = {}

local pendingLockers = {}

function StorageMod.Init(Config)
    local storageMapping = {
        ["/Game/Blueprints/BaseBuilding/BP_Locker_Floor.BP_Locker_Floor_C"] = {
            slotsKey = "FloorLockerSlots",
            colsKey = "FloorLockerCols"
        },
        ["/Game/Blueprints/BaseBuilding/BP_Locker_Wall.BP_Locker_Wall_C"] = {
            slotsKey = "WallLockerSlots",
            colsKey = "WallLockerCols"
        }
    }

    -- 1. Intercept lockers when they spawn
    for classPath, configKeys in pairs(storageMapping) do
        NotifyOnNewObject(classPath, function(CreatedObject)
            if CreatedObject:IsValid() then
                local inventoryComp = CreatedObject.Inventory
                if inventoryComp and inventoryComp:IsValid() then
                    local newSlots = math.floor(tonumber(Config[configKeys.slotsKey]) or 35)
                    local newCols  = math.floor(tonumber(Config[configKeys.colsKey]) or 5)

                    if newCols < 1 then newCols = 5 end

                    inventoryComp.SetMaxItems(newSlots)
                    inventoryComp.MaxItems = newSlots
                    inventoryComp.Columns = newCols
                end

                -- Instead of writing directly, queue it!
                table.insert(pendingLockers, {
                    obj = CreatedObject,
                    keys = configKeys,
                    ticks = 0
                })
            end
        end)
    end

    -- 2. Secret timer (runs once every second)
    LoopAsync(1000, function()
        if #pendingLockers == 0 then return end

        -- Iterate backwards through the table to safely remove elements
        for i = #pendingLockers, 1, -1 do
            local data = pendingLockers[i]
            data.ticks = data.ticks + 1

            -- If 2 seconds (ticks) have passed, the savegame is guaranteed to be finished
            if data.ticks >= 2 then
                local locker = data.obj

                if locker and locker:IsValid() and locker.Inventory and locker.Inventory:IsValid() then
                    -- Now force our values on the engine!
                    local newSlots = math.floor(tonumber(Config[data.keys.slotsKey]) or 35)
                    local newCols  = math.floor(tonumber(Config[data.keys.colsKey]) or 5)

                    if newCols < 1 then newCols = 5 end

                    locker.Inventory.SetMaxItems(newSlots)
                    locker.Inventory.MaxItems = newSlots
                    locker.Inventory.Columns = newCols

                    if Config.Debug then print("[CapacityQuickBarTweaks] Applied settings to new locker") end
                end

                -- Locker is finished and removed from the list
                table.remove(pendingLockers, i)
            end
        end
    end)
end

function StorageMod.UpdateLive(Config)
    -- 1. Rescue floor lockers
    local floorLockers = FindAllOf("BP_Locker_Floor_C")
    if floorLockers then
        for _, locker in ipairs(floorLockers) do
            if locker:IsValid() and locker.Inventory and locker.Inventory:IsValid() then
                -- Get values and FORCE them to be true integers
                local newSlots = math.floor(tonumber(Config.FloorLockerSlots) or 35)
                local newCols  = math.floor(tonumber(Config.FloorLockerCols) or 5)

                -- HARD-FAILSAFE
                if newCols < 1 then newCols = 5 end

                locker.Inventory.SetMaxItems(newSlots)
                locker.Inventory.MaxItems = newSlots
                locker.Inventory.Columns = newCols
            end
        end
    end

    -- 2. Rescue wall lockers
    local wallLockers = FindAllOf("BP_Locker_Wall_C")
    if wallLockers then
        for _, locker in ipairs(wallLockers) do
            if locker:IsValid() and locker.Inventory and locker.Inventory:IsValid() then
                -- Get values and FORCE them to be true integers
                local newSlots = math.floor(tonumber(Config.WallLockerSlots) or 35)
                local newCols  = math.floor(tonumber(Config.WallLockerCols) or 5)

                -- HARD-FAILSAFE
                if newCols < 1 then newCols = 5 end

                locker.Inventory.SetMaxItems(newSlots)
                locker.Inventory.MaxItems = newSlots
                locker.Inventory.Columns = newCols
            end
        end
    end

    if Config.Debug then print("[CapacityQuickBarTweaks] Updated all existing lockers with true integers!") end
end

return StorageMod
