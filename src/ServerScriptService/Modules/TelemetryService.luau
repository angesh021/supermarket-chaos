-- Development-only onboarding funnel. The API associates the event with Player; no custom fields are sent.
local AnalyticsService = game:GetService("AnalyticsService")
local HttpService = game:GetService("HttpService")

local TelemetryService = {}

local DEVELOPMENT_UNIVERSE_ID = 10770581249
local FUNNEL_NAME = "FirstShift"
local RETURN_FUNNEL_NAME = "RepeatShift"
local sessions = {}
local STEPS = {
    [1] = "Store profile ready",
    [2] = "Cart recovered",
    [3] = "Product stocked",
    [4] = "First sale",
    [5] = "First shift closed",
    [6] = "First shelf upgrade",
}

local function recordStep(player, session, step)
    if step <= session.lastStep then
        return
    end
    local ok = pcall(function()
        AnalyticsService:LogFunnelStepEvent(player, FUNNEL_NAME, session.id, step, STEPS[step])
    end)
    if ok then
        session.lastStep = step
    end
end

local function reachedStep(state)
    if state.upgradePurchased then
        return 6
    end
    if state.shiftClosed then
        return 5
    end
    if state.sales > 0 then
        return 4
    end
    if state.stock > 0 then
        return 3
    end
    if state.cartRecovered then
        return 2
    end
    return 1
end

local function recordReturnStep(player, session, step, stepName)
    if step <= session.returnLastStep then
        return
    end
    local ok = pcall(function()
        AnalyticsService:LogFunnelStepEvent(
            player,
            RETURN_FUNNEL_NAME,
            session.returnFunnelId,
            step,
            stepName
        )
    end)
    if ok then
        session.returnLastStep = step
    end
end

function TelemetryService.begin(player, profile, state)
    if game.GameId ~= DEVELOPMENT_UNIVERSE_ID or not player then
        return
    end
    local session = {
        id = HttpService:GenerateGUID(false),
        lastStep = 0,
        returnFunnelId = HttpService:GenerateGUID(false),
        returnLastStep = 0,
    }
    sessions[player.UserId] = session
    if (profile.completedShifts or 0) > 0 then
        recordReturnStep(player, session, 1, "Returning Store Profile Loaded")
    end
    if profile.ownedUpgrades.shelfBay then
        return
    end
    local highestStep = reachedStep(state)
    for step = 1, highestStep do
        recordStep(player, session, step)
    end
end

function TelemetryService.record(player, eventName)
    if game.GameId ~= DEVELOPMENT_UNIVERSE_ID or not player then
        return
    end
    local session = sessions[player.UserId]
    if not session then
        return
    end
    if eventName == "shiftClosed" then
        if session.returnLastStep == 0 then
            recordReturnStep(player, session, 1, "First Shift Completed")
        elseif session.returnLastStep == 2 then
            recordReturnStep(player, session, 3, "Repeat Shift Completed")
        end
    elseif eventName == "restart" and session.returnLastStep == 1 then
        recordReturnStep(player, session, 2, "Another Shift Started")
    end
    local milestoneSteps = {
        cart = 2,
        stock = 3,
        sale = 4,
        shiftClosed = 5,
        upgrade = 6,
    }
    local step = milestoneSteps[eventName]
    if step then
        recordStep(player, session, step)
    end
end

function TelemetryService.finish(player)
    if player then
        sessions[player.UserId] = nil
    end
end

return TelemetryService
