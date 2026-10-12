local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Economy = require(script.Parent.Economy)
local ProfileService = require(script.Parent.ProfileService)
local WorldBuilder = require(script.Parent.WorldBuilder)

local ShiftService = {}

local interactionTimes = {}
local state
local ownerPlayer
local ownerReady = false
local ownershipClaimed = false
local world
local stateEvent

local OBJECTIVES = {
    Cart = "First Shift: stop the runaway shopping cart near the entrance.",
    Stock = "Stock three Citrus Pop cans on the marked shelf.",
    Checkout = "Help the waiting customer at the checkout.",
    CloseShift = "Your first sale is done. Close the shift at the shift board.",
    Upgrade = "Upgrade: use the gold pad just inside the front entrance. Press E to spend $45.",
    Complete = "Shift complete. Visit the shift board to start another shift.",
}

local function snapshot(message, recipient)
    local current = state or Economy.newState()
    local isOwner = recipient == ownerPlayer and ownerReady
    local objective = OBJECTIVES[current.stage] or "Your store is starting up."
    if not isOwner then
        if ownerPlayer then
            objective = "This store belongs to " .. ownerPlayer.DisplayName .. "."
        elseif ownershipClaimed then
            objective = "The store owner left. Join a new server to open your store."
        else
            objective = "Loading your store profile…"
        end
    end
    return {
        stage = current.stage,
        objective = objective,
        cash = current.cash,
        stock = current.stock,
        sales = current.sales,
        message = message or "",
        upgradePurchased = current.upgradePurchased,
        isOwner = isOwner,
        saveStatus = isOwner and ProfileService.getSaveStatus(recipient) or "view only",
    }
end

local function broadcast(message)
    if not stateEvent then
        return
    end
    for _, player in ipairs(Players:GetPlayers()) do
        stateEvent:FireClient(player, snapshot(message, player))
    end
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
        or player ~= ownerPlayer
        or not ownerReady
        or ProfileService.getSaveStatus(player) == "lock lost"
        or ProfileService.getSaveStatus(player) == "save pending"
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
    world.setStage("Loading")
    ProfileService.startAutosave(function()
        broadcast()
    end)

    local root = world.cartModel.PrimaryPart
    local function startCart()
        if state.stage ~= "Cart" or not root or not root.Parent then
            return
        end
        local activeTween = world.cartTween()
        if activeTween then
            activeTween:Cancel()
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

    local function commit(eventName)
        ProfileService.saveProgress(ownerPlayer, state, eventName)
        world.setStage(state.stage)
        broadcast()
    end

    bind(world.cartPrompt, 12, function()
        local activeTween = world.cartTween()
        if activeTween then
            activeTween:Cancel()
        end
        local ok, message = Economy.recoverCart(state)
        if ok then
            root.CFrame = CFrame.new(0, 1.3, 24)
            commit("cart")
        end
        broadcast(message)
    end)

    bind(world.stockPrompt, 12, function()
        local ok, message = Economy.stockProduct(state)
        if ok then
            world.setStockVisual(state.stock)
            commit("stock")
        end
        broadcast(message)
    end)

    bind(world.registerPrompt, 12, function()
        local ok, message = Economy.sellProduct(state)
        if ok then
            world.setStockVisual(state.stock)
            commit("sale")
        end
        broadcast(message)
    end)

    bind(world.closePrompt, 12, function()
        local ok, message = Economy.closeShift(state)
        if ok then
            commit("shiftClosed")
        end
        broadcast(message)
    end)

    bind(world.upgradePrompt, 13, function()
        local ok, message = Economy.buyUpgrade(state)
        if ok then
            world.addUpgrade()
            commit("upgrade")
        end
        broadcast(message)
    end)

    bind(world.restartPrompt, 12, function()
        local ok, message = Economy.restartShift(state)
        if ok then
            world.setStockVisual(0)
            world.setCustomerVisible(false)
            world.setStage(state.stage)
            startCart()
            commit("restart")
        end
        broadcast(message)
    end)

    local function claimStore(player)
        if ownerPlayer == player then
            return
        end
        if ownerPlayer or ownershipClaimed then
            stateEvent:FireClient(
                player,
                snapshot("You can visit, but this store is owned by another player.", player)
            )
            return
        end
        ownerPlayer = player
        ownershipClaimed = true
        stateEvent:FireClient(player, snapshot("Loading your saved store…", player))
        task.spawn(function()
            local profile, status = ProfileService.load(player)
            if ownerPlayer ~= player or player.Parent ~= Players then
                ProfileService.release(player)
                return
            end
            if not profile then
                ownerPlayer = nil
                ownershipClaimed = false
                player:Kick(
                    status or "Your store profile could not be opened safely. Please rejoin."
                )
                return
            end
            state = Economy.newState(profile)
            ownerReady = true
            if state.upgradePurchased then
                world.addUpgrade()
            end
            world.setStockVisual(state.stock)
            world.setStage(state.stage)
            if state.stage == "Cart" then
                startCart()
            end
            broadcast(
                status == "session only" and "Data saving is off; this session will not persist."
                    or "Store profile loaded."
            )
        end)
    end

    Players.PlayerAdded:Connect(claimStore)
    Players.PlayerRemoving:Connect(function(player)
        interactionTimes[player] = nil
        if player == ownerPlayer then
            ProfileService.release(player)
            ownerReady = false
            ownerPlayer = nil
            ownershipClaimed = true
            local activeTween = world.cartTween()
            if activeTween then
                activeTween:Cancel()
            end
            world.setStage("OwnerOffline")
            broadcast("The store owner left. Join a new server to open your store.")
        end
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        claimStore(player)
    end

    game:BindToClose(function()
        if ownerPlayer then
            ProfileService.release(ownerPlayer)
        end
        ProfileService.releaseAll()
    end)
end

return ShiftService
