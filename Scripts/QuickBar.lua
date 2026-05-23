-- QuickBar.lua (Optimierte Version)
local QuickBarMod = {}

local INCREASE_TAG = { TagName = FName("EventTracker.IncreaseToolbar") }
local PERMANENT_TAG = { TagName = FName("PermanentUpgrades.Toolbar") }
local BASE_SLOTS = 5
local BASE_EXTRA_SLOTS = nil

local function GetTracker()
    local context = StaticFindObject("/Script/UWEEventTracker.UWEEventTrackerStatics")
    if not context or not context:IsValid() then return nil end
    local get_event_tracker = StaticFindObject(
        "/Script/UWEEventTracker.UWEEventTrackerStatics:GetLocalPlayerEventTracker")
    if not get_event_tracker or not get_event_tracker:IsValid() then return nil end
    local tracker = get_event_tracker(context, context)
    if tracker and tracker:IsValid() then return tracker end
    return nil
end

function QuickBarMod.UpdateLive(Config)
    local tracker = GetTracker()
    if not tracker then return end

    local current_extra = tracker:GetValue(INCREASE_TAG, PERMANENT_TAG) or 0
    local current_total = BASE_SLOTS + current_extra
    if BASE_EXTRA_SLOTS == nil then BASE_EXTRA_SLOTS = current_extra end

    if Config.QuickBarToggle then
        if Config.QuickBarSlots ~= current_total then
            tracker:Notify(INCREASE_TAG, PERMANENT_TAG, Config.QuickBarSlots - current_total)
            if Config.Debug then print("[QuickBar] Set to " .. Config.QuickBarSlots) end
        end
    else
        tracker:Notify(INCREASE_TAG, PERMANENT_TAG, BASE_EXTRA_SLOTS - current_extra)
        if Config.Debug then print("[QuickBar] Reset to original") end
    end
end

-- Init wird nur für den Initialen Trigger gebraucht
function QuickBarMod.Init(Config)
    NotifyOnNewObject("/Game/Blueprints/Core/BP_SN2PlayerCharacter.BP_SN2PlayerCharacter_C", function(CreatedObject)
        if CreatedObject:IsValid() then
            QuickBarMod.UpdateLive(Config)
        end
    end)
end

return QuickBarMod
