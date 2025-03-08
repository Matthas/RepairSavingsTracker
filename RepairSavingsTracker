local frame = CreateFrame("Frame")
frame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")

local previousRepairCost = 0
local EARTHEN_MASTERS_HAMMER_ITEM_ID = 225660
local inCombat = false
local repairInProgress = false
local lastUpdate = 0
local COOLDOWN_PERIOD = 1 -- Cooldown period in seconds

local function GetTotalRepairCost()
    local totalCost = 0
    for i = 1, 18 do
        local repairitemCost = C_TooltipInfo.GetInventoryItem("player", i)
        if repairitemCost and repairitemCost.repairCost then
            totalCost = totalCost + repairitemCost.repairCost
        end
    end
    return (totalCost / 2) --currently addon fires twice, so half it for correct tracking
end

local function HandleRepairCost()
    local currentRepairCost = GetTotalRepairCost()
    local repairSavings = previousRepairCost - currentRepairCost
    if repairSavings > 0 then
        RepairSavings = RepairSavings + repairSavings
        print(string.format("Gold saved: %s (+%s)", GetCoinTextureString(RepairSavings), GetCoinTextureString(repairSavings)))
    end
    previousRepairCost = currentRepairCost
    repairInProgress = false
end

local function OnEvent(self, event)
    local currentTime = GetTime()
    if currentTime - lastUpdate < COOLDOWN_PERIOD then
        return -- Skip processing if the event was triggered less than 1 second ago
    end
    lastUpdate = currentTime

    if event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
    elseif event == "UPDATE_INVENTORY_DURABILITY" and not inCombat then
        if not repairInProgress then
            repairInProgress = true
            C_Timer.After(1, HandleRepairCost) -- Wait 1 second before handling the repair cost
        end
    end
end

frame:SetScript("OnEvent", OnEvent)
