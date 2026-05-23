-- QuickBar.lua
local QuickBarMod = {}

-- 1. Caching: Create tags and references only once when the mod is loaded
local INCREASE_TAG = { TagName = FName("EventTracker.IncreaseToolbar") }
local PERMANENT_TAG = { TagName = FName("PermanentUpgrades.Toolbar") }
local BASE_SLOTS = 5

-- The core function that calculates and applies the slots
local function ApplyQuickSlots(desired_slots)
    local context = StaticFindObject("/Script/UWEEventTracker.UWEEventTrackerStatics")
    if not context or not context:IsValid() then return false end

    local get_event_tracker = StaticFindObject(
        "/Script/UWEEventTracker.UWEEventTrackerStatics:GetLocalPlayerEventTracker")
    if not get_event_tracker or not get_event_tracker:IsValid() then return false end

    -- Get tracker
    local tracker = get_event_tracker(context, context)
    if not tracker or not tracker:IsValid() then return false end

    -- Get current bonus slots
    local current_extra_slots = tracker:GetValue(INCREASE_TAG, PERMANENT_TAG) or 0
    local current_total_slots = BASE_SLOTS + current_extra_slots

    -- Only update if the desired slots are different from the current total
    if desired_slots ~= current_total_slots then
        local slots_to_add = desired_slots - current_total_slots
        tracker:Notify(INCREASE_TAG, PERMANENT_TAG, slots_to_add)

        return true -- Indicate a change
    end

    return false
end

-- 2. Initialization upon spawn (like in Storage.lua)
function QuickBarMod.Init(Config)
    NotifyOnNewObject("/Game/Blueprints/Core/BP_SN2PlayerCharacter.BP_SN2PlayerCharacter_C", function(CreatedObject)
        if CreatedObject:IsValid() then
            if ApplyQuickSlots(Config.QuickBarSlots) then
                if Config.Debug then
                    print("[CapacityQuickBarTweaks] QuickBar updated to " ..
                        Config.QuickBarSlots .. " slots")
                end
            end
        end
    end)
end

-- 3. Live-update function for the menu
function QuickBarMod.UpdateLive(Config)
    if ApplyQuickSlots(Config.QuickBarSlots) then
        if Config.Debug then print("[CapacityQuickBarTweaks] QuickBar updated to " .. Config.QuickBarSlots .. " slots") end
    end
end

return QuickBarMod
