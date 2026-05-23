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
                local inventoryComp = CreatedObject.Inventory or CreatedObject.UWEInventory

                if inventoryComp and inventoryComp:IsValid() then
                    local newSlots = math.floor(tonumber(Config[configKeys.slotsKey]) or 35)
                    local newCols  = math.floor(tonumber(Config[configKeys.colsKey]) or 5)

                    if newCols < 1 then newCols = 5 end

                    inventoryComp:SetMaxItems(newSlots)
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

        for i = #pendingLockers, 1, -1 do
            local data = pendingLockers[i]
            data.ticks = data.ticks + 1

            if data.ticks >= 2 then
                local locker = data.obj

                if locker and locker:IsValid() then
                    local inventoryComp = locker.Inventory or locker.UWEInventory

                    if inventoryComp and inventoryComp:IsValid() then
                        local newSlots = math.floor(tonumber(Config[data.keys.slotsKey]) or 35)
                        local newCols  = math.floor(tonumber(Config[data.keys.colsKey]) or 5)
                        if newCols < 1 then newCols = 5 end

                        inventoryComp:SetMaxItems(newSlots)
                        inventoryComp.MaxItems = newSlots
                        inventoryComp.Columns = newCols
                    end
                end

                table.remove(pendingLockers, i)
            end
        end
    end)
end

local function UpdateSpecificLockers(className, slotsVal, colsVal)
    local lockers = FindAllOf(className)
    if lockers then
        for _, locker in ipairs(lockers) do
            if locker:IsValid() then
                local inventoryComp = locker.Inventory or locker.UWEInventory

                if inventoryComp and inventoryComp:IsValid() then
                    local newSlots = math.floor(tonumber(slotsVal) or 35)
                    local newCols  = math.floor(tonumber(colsVal) or 5)
                    if newCols < 1 then newCols = 5 end

                    inventoryComp:SetMaxItems(newSlots)
                    inventoryComp.MaxItems = newSlots
                    inventoryComp.Columns = newCols
                end
            end
        end
    end
end

function StorageMod.UpdateLive(Config)
    UpdateSpecificLockers("BP_Locker_Floor_C", Config.FloorLockerSlots, Config.FloorLockerCols)
    UpdateSpecificLockers("BP_Locker_Wall_C", Config.WallLockerSlots, Config.WallLockerCols)

    if Config.Debug then print("[CapacityQuickBarTweaks] Updated all existing lockers with true integers!") end
end

return StorageMod
