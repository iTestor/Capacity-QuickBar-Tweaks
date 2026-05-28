-- Crafting.lua

local CraftingMod = {}

local pendingStations = {}
local activeStations = {}
setmetatable(activeStations, { __mode = "k" })

local function ApplyCraftingSettings(InventoryInput, InventoryOutput, configKeys, Config)
    if not InventoryInput or not InventoryInput:IsValid() then return end
    if not InventoryOutput or not InventoryOutput:IsValid() then return end

    local newCols = configKeys.defaultCols
    local newSlots = configKeys.defaultRows * newCols

    if Config[configKeys.toggleKey] then
        newCols = math.floor(tonumber(Config[configKeys.colsKey]) or configKeys.defaultCols)
        newSlots = math.floor(tonumber(Config[configKeys.rowsKey]) or configKeys.defaultRows) * newCols
    end

    if newCols < 1 then newCols = configKeys.defaultCols end

    if InventoryInput.Columns ~= newCols or InventoryInput.MaxItems ~= newSlots then
        InventoryInput:SetMaxItems(newSlots)
        InventoryInput.MaxItems = newSlots
        InventoryInput.Columns = newCols
    end

    if InventoryOutput.Columns ~= newCols or InventoryOutput.MaxItems ~= newSlots then
        InventoryOutput:SetMaxItems(newSlots)
        InventoryOutput.MaxItems = newSlots
        InventoryOutput.Columns = newCols
    end
end

function CraftingMod.Init(Config)
    local storageMapping = {
        ["/Game/Blueprints/Crafting/BP_ProcessorStation.BP_ProcessorStation_C"] = {
            toggleKey = "ProcessorStationToggle",
            rowsKey = "ProcessorStationRows",
            colsKey = "ProcessorStationCols",
            defaultRows = 3,
            defaultCols = 5,
        },
    }

    -- 1. Intercept lockers when they spawn
    for classPath, configKeys in pairs(storageMapping) do
        NotifyOnNewObject(classPath, function(CreatedObject)
            if CreatedObject:IsValid() then
                local inputComp = CreatedObject.InputInventory
                local outputComp = CreatedObject.OutputInventory

                ApplyCraftingSettings(inputComp, outputComp, configKeys, Config)

                table.insert(pendingStations, {
                    obj = CreatedObject,
                    keys = configKeys,
                    ticks = 0
                })

                -- Add to cache
                activeStations[CreatedObject] = configKeys
            end
        end)
    end

    -- 2. Secret timer (runs once every second)
    LoopAsync(1000, function()
        -- Handle pending lockers
        if #pendingStations > 0 then
            for i = #pendingStations, 1, -1 do
                local data = pendingStations[i]
                data.ticks = data.ticks + 1

                if data.ticks >= 2 then
                    local station = data.obj
                    if station and station:IsValid() then
                        local inputComp = station.InputInventory
                        local outputComp = station.OutputInventory

                        ApplyCraftingSettings(inputComp, outputComp, data.keys, Config)
                    end
                    table.remove(pendingStations, i)
                end
            end
        end
    end)
end

function CraftingMod.UpdateLive(Config)
    for station, keys in pairs(activeStations) do
        if station:IsValid() then
            local inputComp = station.InputInventory
            local outputComp = station.OutputInventory

            ApplyCraftingSettings(inputComp, outputComp, keys, Config)
        else
            -- Remove if no longer valid
            activeStations[station] = nil
        end
    end

    if Config.Debug then print("[CapacityQuickBarTweaks] Updated cached stations") end
end

return CraftingMod
