local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")

local previousRepairCost = 0
local inCombat = false
local repairInProgress = false
local characterWindowOpen = false
local vendorWindowOpen = false
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
    return (totalCost / 2)
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
    elseif event == "MERCHANT_SHOW" then
        vendorWindowOpen = true
    elseif event == "MERCHANT_CLOSED" then
        vendorWindowOpen = false
    elseif event == "PLAYER_ENTERING_WORLD" then
        CharacterFrame:HookScript("OnShow", function()
            characterWindowOpen = true
            previousRepairCost = GetTotalRepairCost()
        end)
        CharacterFrame:HookScript("OnHide", function()
            characterWindowOpen = false
            if not vendorWindowOpen then
                HandleRepairCost()
            end
        end)
    end
end

frame:SetScript("OnEvent", OnEvent)
