local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Economy = require(script.Parent.Economy)
local WorldBuilder = require(script.Parent.WorldBuilder)

local ShiftService = {}

local state = Economy.newState()
local interactionTimes = {}
local world
local stateEvent

local OBJECTIVES = {
    Cart = "First Shift: stop the runaway shopping cart near the entrance.",
    Stock = "Stock three Citrus Pop cans on the marked shelf.",
    Checkout = "Help the waiting customer at the checkout.",
    CloseShift = "Your first sale is done. Close the shift at the shift board.",
    Upgrade = "Upgrade: use the gold pad just inside the front entrance. Press E to spend $45.",
    Complete = "First shift complete! Your store has a new shelf bay.",
}

local function snapshot(message)
    return {
        stage = state.stage,
        objective = OBJECTIVES[state.stage],
        cash = state.cash,
        stock = state.stock,
        sales = state.sales,
        message = message or "",
        upgradePurchased = state.upgradePurchased,
    }
end

local function broadcast(message)
    if not stateEvent then
        return
    end
    stateEvent:FireAllClients(snapshot(message))
end

local function atPrompt(player, promptObject, maxDistance)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local host = promptObject.Parent
    local position
    if host and host:IsA("Attachment") then
        position = host.WorldPosition
    elseif host and host:IsA("BasePart") then
        position = host.Position
    elseif host and host:IsA("Model") then
        position = host:GetPivot().Position
    end
    if not root or not position then
        return false
    end
    return (root.Position - position).Magnitude <= maxDistance
end

local function permitInteraction(player, promptObject, maxDistance)
    if
        not player
        or player.Parent ~= Players
        or not promptObject
        or not promptObject:IsDescendantOf(workspace)
    then
        return false
    end
    local now = os.clock()
    local last = interactionTimes[player]
    if last and now - last < 0.45 then
        return false
    end
    if not atPrompt(player, promptObject, maxDistance) then
        return false
    end
    interactionTimes[player] = now
    return true
end

local function bind(promptObject, maxDistance, callback)
    promptObject.Triggered:Connect(function(player)
        if not permitInteraction(player, promptObject, maxDistance) then
            return
        end
        callback(player)
    end)
end

function ShiftService.init(event)
    stateEvent = event
    world = WorldBuilder.build()

    -- Roll the opening cart along a short, anchored path until the server accepts a nearby stop.
    local root = world.cartModel.PrimaryPart
    local function startCart()
        if state.stage ~= "Cart" or not root or not root.Parent then
            return
        end
        root.CFrame = CFrame.new(-5, 1.3, 25)
        local tween = TweenService:Create(
            root,
            TweenInfo.new(3.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
            {
                CFrame = CFrame.new(5, 1.3, 25),
            }
        )
        world.setCartTween(tween)
        tween:Play()
    end
    startCart()

    bind(world.cartPrompt, 12, function()
        local activeTween = world.cartTween()
        if activeTween then
            activeTween:Cancel()
        end
        local ok, message = Economy.recoverCart(state)
        if ok then
            root.CFrame = CFrame.new(0, 1.3, 24)
            world.cartPrompt.Enabled = false
        end
        broadcast(message)
    end)

    bind(world.stockPrompt, 12, function()
        local ok, message = Economy.stockProduct(state)
        if ok then
            world.stockPrompt.Enabled = false
            world.setStockVisual(state.stock)
            world.setCustomerVisible(true)
        end
        broadcast(message)
    end)

    bind(world.registerPrompt, 12, function()
        local ok, message = Economy.sellProduct(state)
        if ok then
            world.setStockVisual(state.stock)
            world.registerPrompt.Enabled = false
        end
        broadcast(message)
    end)

    bind(world.closePrompt, 12, function()
        local ok, message = Economy.closeShift(state)
        if ok then
            world.closePrompt.Enabled = false
            world.setUpgradeReady(true)
        end
        broadcast(message)
    end)

    bind(world.upgradePrompt, 13, function()
        local ok, message = Economy.buyUpgrade(state)
        if ok then
            world.upgradePrompt.Enabled = false
            world.addUpgrade()
        end
        broadcast(message)
    end)

    Players.PlayerAdded:Connect(function(player)
        task.delay(1, function()
            if player.Parent == Players then
                stateEvent:FireClient(player, snapshot("Welcome to the neighborhood store!"))
            end
        end)
    end)
    Players.PlayerRemoving:Connect(function(player)
        interactionTimes[player] = nil
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        task.delay(1, function()
            if player.Parent == Players then
                stateEvent:FireClient(player, snapshot("Welcome to the neighborhood store!"))
            end
        end)
    end
    broadcast("First Shift: Welcome to Chaos!")
end

return ShiftService
