local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Economy = require(script.Parent.Economy)
local ProfileService = require(script.Parent.ProfileService)
local TelemetryService = require(script.Parent.TelemetryService)
local WorldBuilder = require(script.Parent.WorldBuilder)

local ShiftService = {}

local interactionTimes = {}
local membershipTimes = {}
local storeMembers = {}
local joinRequests = {}
local state
local ownerPlayer
local ownerReady = false
local ownershipClaimed = false
local world
local stateEvent
local joinRequestEvent
local memberActionEvent
local memberStateEvent

local ROLE_ACTIONS = {
    Manager = {
        Cart = true,
        Stock = true,
        Checkout = true,
        CloseShift = true,
        Upgrade = true,
        Complete = true,
        HireCashier = true,
        HireStocker = true,
        Warehouse = true,
        OrderDelivery = true,
        ReceiveDelivery = true,
    },
    Cashier = { Checkout = true },
    Stocker = { Stock = true },
    Maintenance = { Cart = true },
}
local ASSIGNABLE_ROLES = { Manager = true, Cashier = true, Stocker = true, Maintenance = true }
local MAX_STORE_PLAYERS = 4
local MAX_PENDING_REQUESTS = 120

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
    local isHelper = storeMembers[recipient.UserId] ~= nil
    local hasStoreAccess = isOwner or isHelper
    local objective = OBJECTIVES[current.stage] or "Your store is starting up."
    if not isOwner and not isHelper then
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
        cash = hasStoreAccess and current.cash or 0,
        stock = hasStoreAccess and current.stock or 0,
        sales = hasStoreAccess and current.sales or 0,
        message = message or "",
        upgradePurchased = current.upgradePurchased,
        isOwner = isOwner,
        hasStoreAccess = hasStoreAccess,
        memberRole = isOwner and "Owner" or (storeMembers[recipient.UserId] or "Visitor"),
        saveStatus = isOwner and ProfileService.getSaveStatus(recipient) or "view only",
        warehousePurchased = hasStoreAccess and current.warehousePurchased or false,
        backstock = hasStoreAccess and current.backstock or 0,
    }
end

local function sendMemberState(player)
    if not memberStateEvent or not player then
        return
    end
    local members = {}
    for userId, role in pairs(storeMembers) do
        local member = Players:GetPlayerByUserId(userId)
        if member then
            table.insert(members, { userId = userId, name = member.DisplayName, role = role })
        end
    end
    local requests = {}
    if player == ownerPlayer then
        for userId, requestedAt in pairs(joinRequests) do
            if os.clock() - requestedAt <= MAX_PENDING_REQUESTS then
                local requester = Players:GetPlayerByUserId(userId)
                if requester then
                    table.insert(requests, { userId = userId, name = requester.DisplayName })
                end
            else
                joinRequests[userId] = nil
            end
        end
    end
    memberStateEvent:FireClient(player, {
        ownerUserId = ownerPlayer and ownerPlayer.UserId or nil,
        ownerName = ownerPlayer and ownerPlayer.DisplayName or "",
        ownRole = player == ownerPlayer and "Owner" or (storeMembers[player.UserId] or "Visitor"),
        requestPending = joinRequests[player.UserId] ~= nil
            and os.clock() - joinRequests[player.UserId] <= MAX_PENDING_REQUESTS,
        members = members,
        requests = requests,
    })
end

local function broadcastMemberState()
    for _, player in ipairs(Players:GetPlayers()) do
        sendMemberState(player)
    end
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

local function permitInteraction(player, actionId, promptObject, maxDistance)
    local role = player and (player == ownerPlayer and "Owner" or storeMembers[player.UserId])
    local allowed = role == "Owner"
        or (role and ROLE_ACTIONS[role] and ROLE_ACTIONS[role][actionId] == true)
    if
        not player
        or not allowed
        or not ownerReady
        or not ownerPlayer
        or ProfileService.getSaveStatus(ownerPlayer) == "lock lost"
        or ProfileService.getSaveStatus(ownerPlayer) == "save pending"
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

local function bind(actionId, promptObject, maxDistance, callback)
    promptObject.Triggered:Connect(function(player)
        if not permitInteraction(player, actionId, promptObject, maxDistance) then
            return
        end
        callback(player)
    end)
end

function ShiftService.init(event, membershipRemotes)
    stateEvent = event
    joinRequestEvent = membershipRemotes.joinRequest
    memberActionEvent = membershipRemotes.memberAction
    memberStateEvent = membershipRemotes.memberState
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

    local commit
    local function scheduleStocker()
        if not state or not state.stockerHired or state.stage ~= "Stock" then
            return
        end
        task.delay(4, function()
            if
                not ownerReady
                or not ownerPlayer
                or not state
                or not state.stockerHired
                or state.stage ~= "Stock"
                or ProfileService.getSaveStatus(ownerPlayer) == "lock lost"
                or ProfileService.getSaveStatus(ownerPlayer) == "save pending"
            then
                return
            end
            local ok, message = Economy.stockProduct(state)
            if ok then
                world.setStockVisual(state.stock)
                commit("stock")
                broadcast("Stock clerk restocked Citrus Pop automatically. " .. message)
            end
        end)
    end

    local function scheduleCashierSale()
        if not state or not state.cashierHired or state.stage ~= "Checkout" then
            return
        end
        task.delay(4, function()
            if
                not ownerReady
                or not ownerPlayer
                or not state
                or not state.cashierHired
                or state.stage ~= "Checkout"
                or ProfileService.getSaveStatus(ownerPlayer) == "lock lost"
                or ProfileService.getSaveStatus(ownerPlayer) == "save pending"
            then
                return
            end
            local ok, message = Economy.sellProduct(state)
            if ok then
                world.setStockVisual(state.stock)
                commit("sale")
                broadcast("Cashier served the customer automatically. " .. message)
            end
        end)
    end

    local scheduledDeliveryAt
    local function scheduleDeliveryArrival()
        if not state or state.shipmentQuantity <= 0 or state.shipmentReadyAt <= 0 then
            scheduledDeliveryAt = nil
            return
        end
        local readyAt = state.shipmentReadyAt
        if scheduledDeliveryAt == readyAt then
            return
        end
        scheduledDeliveryAt = readyAt
        task.delay(math.max(0, readyAt - os.time()), function()
            if not state or state.shipmentReadyAt ~= readyAt or state.shipmentQuantity <= 0 then
                return
            end
            if ownerReady then
                world.setDeliveryState(state.shipmentReadyAt, state.shipmentQuantity)
                broadcast("A Citrus Pop delivery has arrived at the warehouse loading dock.")
            end
        end)
    end

    commit = function(eventName)
        ProfileService.saveProgress(ownerPlayer, state, eventName)
        TelemetryService.record(ownerPlayer, eventName)
        world.setStage(state.stage)
        broadcast()
        scheduleStocker()
        scheduleCashierSale()
        scheduleDeliveryArrival()
    end

    bind("Cart", world.cartPrompt, 12, function()
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

    bind("Stock", world.stockPrompt, 12, function()
        local ok, message = Economy.stockProduct(state)
        if ok then
            world.setStockVisual(state.stock)
            commit("stock")
        end
        broadcast(message)
    end)

    bind("Checkout", world.registerPrompt, 12, function()
        local ok, message = Economy.sellProduct(state)
        if ok then
            world.setStockVisual(state.stock)
            commit("sale")
        end
        broadcast(message)
    end)

    bind("CloseShift", world.closePrompt, 12, function()
        local ok, message = Economy.closeShift(state)
        if ok then
            commit("shiftClosed")
        end
        broadcast(message)
    end)

    bind("Upgrade", world.upgradePrompt, 13, function()
        local ok, message = Economy.buyUpgrade(state)
        if ok then
            world.addUpgrade()
            commit("upgrade")
        end
        broadcast(message)
    end)

    bind("Warehouse", world.warehousePrompt, 12, function()
        local ok, message = Economy.buyWarehouse(state)
        if ok then
            world.addWarehouse()
            commit("warehouse")
        end
        broadcast(message)
    end)

    bind("OrderDelivery", world.orderDeliveryPrompt(), 12, function()
        local ok, message = Economy.orderDelivery(state, os.time())
        if ok then
            world.setDeliveryState(state.shipmentReadyAt, state.shipmentQuantity)
            commit("deliveryOrdered")
        end
        broadcast(message)
    end)

    bind("ReceiveDelivery", world.deliveryPrompt(), 12, function()
        local ok, message = Economy.receiveDelivery(state, os.time())
        if ok then
            world.setDeliveryState(state.shipmentReadyAt, state.shipmentQuantity)
            commit("deliveryReceived")
        end
        broadcast(message)
    end)

    bind("Complete", world.restartPrompt, 12, function()
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

    bind("HireCashier", world.cashierHirePrompt, 12, function()
        local ok, message = Economy.hireCashier(state)
        if ok then
            world.setCashierHired(true)
            commit("employeeHired")
        end
        broadcast(message)
    end)

    bind("HireStocker", world.stockerHirePrompt, 12, function()
        local ok, message = Economy.hireStocker(state)
        if ok then
            world.setStockerHired(true)
            commit("employeeHired")
        end
        broadcast(message)
    end)

    joinRequestEvent.OnServerEvent:Connect(function(player)
        if
            player == ownerPlayer
            or not ownerPlayer
            or not ownerReady
            or player.Parent ~= Players
        then
            return
        end
        local now = os.clock()
        if membershipTimes[player] and now - membershipTimes[player] < 5 then
            return
        end
        membershipTimes[player] = now
        if storeMembers[player.UserId] then
            sendMemberState(player)
            return
        end
        local count = 1
        for _ in pairs(storeMembers) do
            count += 1
        end
        if count >= MAX_STORE_PLAYERS then
            stateEvent:FireClient(player, snapshot("This store is full right now.", player))
            return
        end
        joinRequests[player.UserId] = now
        broadcastMemberState()
        stateEvent:FireClient(player, snapshot("Help request sent to the store owner.", player))
    end)

    memberActionEvent.OnServerEvent:Connect(function(player, action, targetUserId, role)
        if player ~= ownerPlayer or not ownerReady or player.Parent ~= Players then
            return
        end
        local now = os.clock()
        if membershipTimes[player] and now - membershipTimes[player] < 0.25 then
            return
        end
        membershipTimes[player] = now
        if type(action) ~= "string" or type(targetUserId) ~= "number" then
            return
        end
        if
            targetUserId ~= targetUserId
            or targetUserId < 1
            or targetUserId > 9007199254740991
            or targetUserId % 1 ~= 0
        then
            return
        end
        local target = Players:GetPlayerByUserId(targetUserId)
        if not target or target == ownerPlayer then
            return
        end
        if action == "approve" then
            local requestedAt = joinRequests[targetUserId]
            if
                not requestedAt
                or os.clock() - requestedAt > MAX_PENDING_REQUESTS
                or type(role) ~= "string"
                or not ASSIGNABLE_ROLES[role]
            then
                joinRequests[targetUserId] = nil
                broadcastMemberState()
                return
            end
            local count = 1
            for _ in pairs(storeMembers) do
                count += 1
            end
            if count >= MAX_STORE_PLAYERS then
                return
            end
            storeMembers[targetUserId] = role
            joinRequests[targetUserId] = nil
            stateEvent:FireClient(
                target,
                snapshot(
                    "You joined " .. ownerPlayer.DisplayName .. "'s store as " .. role .. ".",
                    target
                )
            )
        elseif action == "decline" then
            if not joinRequests[targetUserId] then
                return
            end
            joinRequests[targetUserId] = nil
            stateEvent:FireClient(
                target,
                snapshot("The store owner declined your help request.", target)
            )
        elseif action == "remove" then
            if not storeMembers[targetUserId] then
                return
            end
            storeMembers[targetUserId] = nil
            stateEvent:FireClient(
                target,
                snapshot("Your store access was removed by the owner.", target)
            )
        else
            return
        end
        broadcastMemberState()
        broadcast()
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
            sendMemberState(player)
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
            TelemetryService.begin(player, profile, state)
            ownerReady = true
            if state.upgradePurchased then
                world.addUpgrade()
            end
            world.setWarehousePurchased(state.warehousePurchased)
            world.setDeliveryState(state.shipmentReadyAt, state.shipmentQuantity)
            world.setCashierHired(state.cashierHired)
            world.setStockerHired(state.stockerHired)
            world.setStockVisual(state.stock)
            world.setStage(state.stage)
            if state.stage == "Cart" then
                startCart()
            end
            scheduleCashierSale()
            scheduleStocker()
            scheduleDeliveryArrival()
            broadcast(
                status == "session only" and "Data saving is off; this session will not persist."
                    or "Store profile loaded."
            )
            broadcastMemberState()
        end)
    end

    Players.PlayerAdded:Connect(claimStore)
    Players.PlayerRemoving:Connect(function(player)
        interactionTimes[player] = nil
        membershipTimes[player] = nil
        storeMembers[player.UserId] = nil
        joinRequests[player.UserId] = nil
        broadcastMemberState()
        if player == ownerPlayer then
            TelemetryService.finish(player)
            ProfileService.release(player)
            ownerReady = false
            ownerPlayer = nil
            ownershipClaimed = true
            storeMembers = {}
            joinRequests = {}
            local activeTween = world.cartTween()
            if activeTween then
                activeTween:Cancel()
            end
            world.setStage("OwnerOffline")
            broadcast("The store owner left. Join a new server to open your store.")
            broadcastMemberState()
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
