local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local Economy = require(script.Parent.Economy)
local ProfileService = require(script.Parent.ProfileService)
local TelemetryService = require(script.Parent.TelemetryService)
local WorldBuilder = require(script.Parent.WorldBuilder)
local LayoutService = require(script.Parent.LayoutService)
local RetailLayoutService = require(script.Parent.RetailLayoutService)

local ShiftService = {}

local interactionTimes = {}
local membershipTimes = {}
local layoutActionTimes = {}
local retailLayoutActionTimes = {}
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
local layoutRequestEvent
local retailLayoutRequestEvent

local ROLE_ACTIONS = {
    Manager = {
        Cart = true,
        Stock = true,
        Checkout = true,
        Spill = true,
        RestorePower = true,
        CloseShift = true,
        Upgrade = true,
        Complete = true,
        HireCashier = true,
        HireStocker = true,
        HireCleaner = true,
        HireDeliveryWorker = true,
        HireCustomerAssistant = true,
        ToggleCashierAutomation = true,
        ToggleStockerAutomation = true,
        ToggleCleanerAutomation = true,
        ToggleDeliveryWorkerAutomation = true,
        Warehouse = true,
        AisleExpansion = true,
        FloorExpansion = true,
        BuildBakery = true,
        EditLayout = true,
        EditRetailLayout = true,
        MarketStyle = true,
        PreviewMarketStyle = true,
        OrderDelivery = true,
        OrderBerryDelivery = true,
        OrderAppleDelivery = true,
        OrderCerealDelivery = true,
        OrderCinnamonTwistsDelivery = true,
        ReceiveDelivery = true,
        PriceCitrusPop = true,
        PriceBerryBites = true,
        PriceGoldenApples = true,
        PriceSunriseCereal = true,
        PriceCinnamonTwists = true,
        StockBerryBites = true,
        StockGoldenApples = true,
        StockSunriseCereal = true,
        StockCinnamonTwists = true,
    },
    Cashier = { Checkout = true },
    Stocker = {
        Stock = true,
        StockBerryBites = true,
        StockGoldenApples = true,
        StockSunriseCereal = true,
        StockCinnamonTwists = true,
    },
    Maintenance = { Cart = true, Spill = true, RestorePower = true },
}
local ASSIGNABLE_ROLES = { Manager = true, Cashier = true, Stocker = true, Maintenance = true }
local MAX_STORE_PLAYERS = 4
local MAX_PENDING_REQUESTS = 120

local OBJECTIVES = {
    Cart = "First Shift: stop the runaway shopping cart near the entrance.",
    Stock = "Stock three Citrus Pop cans on the marked shelf.",
    Checkout = "Serve the customers waiting in the checkout queue.",
    Spill = "Clean up the dropped groceries by checkout.",
    PowerOutage = "Power outage: restore power at the breaker by checkout.",
    CustomerRush = "Customer rush: serve the bonus queue before the timer ends.",
    CloseShift = "All customers are served. Close the shift at the shift board.",
    Upgrade = "Upgrade: use the gold pad just inside the front entrance. Press E to spend $45.",
    Complete = "Shift complete. Visit the shift board to start another shift.",
}

local function snapshot(message, recipient)
    local current = state or Economy.newState()
    local isOwner = recipient == ownerPlayer and ownerReady
    local isHelper = storeMembers[recipient.UserId] ~= nil
    local hasStoreAccess = isOwner or isHelper
    local objective = OBJECTIVES[current.stage] or "Your store is starting up."
    if current.stage == "Checkout" then
        local remaining = Economy.getRemainingCustomers(current)
        local basket = Economy.getNextCheckoutBasket(current)
        local nextBasket = #basket.items > 0 and basket.displayName or "restock a shelf"
        objective = string.format(
            "Serve %d customer%s • Basket: %s ($%d).",
            remaining,
            remaining == 1 and "" or "s",
            nextBasket,
            basket.total
        )
    elseif current.stage == "Spill" then
        local remaining = Economy.getRemainingCustomers(current)
        local basket = Economy.getNextCheckoutBasket(current)
        local nextBasket = #basket.items > 0 and basket.displayName or "restock a shelf"
        objective = string.format(
            "Clean spill • %d customer%s left • %s ($%d).",
            remaining,
            remaining == 1 and "" or "s",
            nextBasket,
            basket.total
        )
    elseif current.stage == "CustomerRush" then
        objective = "Customer rush: serve the remaining shoppers before the timer ends."
    end
    if current.stage == "Complete" and hasStoreAccess then
        objective = string.format(
            "Shift complete • staff payroll $%d per shift. Visit the shift board to continue.",
            Economy.getShiftPayroll(current)
        )
    end
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
        customerSatisfaction = hasStoreAccess and current.customerSatisfaction or 0,
        stock = hasStoreAccess and current.stock or 0,
        berryStock = hasStoreAccess and current.berryStock or 0,
        goldenAppleStock = hasStoreAccess and current.goldenAppleStock or 0,
        cerealStock = hasStoreAccess and current.cerealStock or 0,
        cinnamonTwistStock = hasStoreAccess and current.cinnamonTwistStock or 0,
        bakeryPurchased = hasStoreAccess and current.bakeryPurchased or false,
        employeePayroll = hasStoreAccess and Economy.getShiftPayroll(current) or 0,
        sales = hasStoreAccess and current.sales or 0,
        message = message or "",
        upgradePurchased = current.upgradePurchased,
        isOwner = isOwner,
        hasStoreAccess = hasStoreAccess,
        memberRole = isOwner and "Owner" or (storeMembers[recipient.UserId] or "Visitor"),
        saveStatus = isOwner and ProfileService.getSaveStatus(recipient) or "view only",
        warehousePurchased = hasStoreAccess and current.warehousePurchased or false,
        backstock = hasStoreAccess and current.backstock or 0,
        berryBackstock = hasStoreAccess and current.berryBackstock or 0,
        goldenAppleBackstock = hasStoreAccess and current.goldenAppleBackstock or 0,
        cerealBackstock = hasStoreAccess and current.cerealBackstock or 0,
        cinnamonTwistBackstock = hasStoreAccess and current.cinnamonTwistBackstock or 0,
        customerRushUntil = hasStoreAccess and current.customerRushUntil or 0,
        rushRemaining = hasStoreAccess and Economy.getRemainingCustomers(current) or 0,
        rushReward = hasStoreAccess and Economy.CUSTOMER_RUSH_REWARD or 0,
        nextBasketName = hasStoreAccess and Economy.getNextCheckoutBasket(current).displayName
            or "",
        nextBasketTotal = hasStoreAccess and Economy.getNextCheckoutBasket(current).total or 0,
        productPrices = hasStoreAccess and {
            citrusPop = current.productPrices.citrusPop,
            berryBites = current.productPrices.berryBites,
            goldenApples = current.productPrices.goldenApples,
            sunriseCereal = current.productPrices.sunriseCereal,
            cinnamonTwists = current.productPrices.cinnamonTwists,
        } or nil,
        customerAssistantHired = hasStoreAccess and current.customerAssistantHired or false,
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
        or not promptObject.Enabled
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
    layoutRequestEvent = membershipRemotes.layoutRequest
    retailLayoutRequestEvent = membershipRemotes.retailLayoutRequest
    world = WorldBuilder.build()
    local marketStylePreviewing = false
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
    local stockerScheduleVersion = 0
    local function scheduleStocker()
        stockerScheduleVersion += 1
        local scheduleVersion = stockerScheduleVersion
        local scheduledStage = state and state.stage
        if
            not state
            or not state.stockerHired
            or not state.stockerAutomationEnabled
            or (
                scheduledStage ~= "Stock"
                and scheduledStage ~= "Checkout"
                and scheduledStage ~= "CustomerRush"
            )
        then
            return
        end
        task.delay(4, function()
            if
                scheduleVersion ~= stockerScheduleVersion
                or not ownerReady
                or not ownerPlayer
                or not state
                or not state.stockerHired
                or not state.stockerAutomationEnabled
                or state.stage ~= scheduledStage
                or ProfileService.getSaveStatus(ownerPlayer) == "lock lost"
                or ProfileService.getSaveStatus(ownerPlayer) == "save pending"
            then
                return
            end
            local ok, message, productId
            if scheduledStage == "Stock" then
                ok, message = Economy.stockProduct(state)
                productId = "citrusPop"
            else
                ok, message, productId = Economy.stockNextRequestedProduct(state)
            end
            if ok then
                world.setStockVisual(state.stock)
                world.setBerryStockVisual(state.berryStock)
                world.setGoldenAppleStockVisual(state.goldenAppleStock)
                world.setCerealStockVisual(state.cerealStock)
                world.setCinnamonTwistStockVisual(state.cinnamonTwistStock)
                commit("stock")
                broadcast(
                    "Stock clerk restocked "
                        .. Economy.PRODUCTS[productId].displayName
                        .. " automatically. "
                        .. message
                )
            end
        end)
    end

    local cashierScheduleVersion = 0
    local function scheduleCashierSale()
        cashierScheduleVersion += 1
        local scheduleVersion = cashierScheduleVersion
        if
            not state
            or not state.cashierHired
            or not state.cashierAutomationEnabled
            or (state.stage ~= "Checkout" and state.stage ~= "CustomerRush")
        then
            return
        end

        local readinessChecks = 0
        local function tryCashierSale(delaySeconds)
            task.delay(delaySeconds, function()
                if
                    scheduleVersion ~= cashierScheduleVersion
                    or not ownerReady
                    or not ownerPlayer
                    or not state
                    or not state.cashierHired
                    or not state.cashierAutomationEnabled
                    or (state.stage ~= "Checkout" and state.stage ~= "CustomerRush")
                    or ProfileService.getSaveStatus(ownerPlayer) == "lock lost"
                    or ProfileService.getSaveStatus(ownerPlayer) == "save pending"
                then
                    return
                end
                if not world.isCheckoutReady() then
                    readinessChecks += 1
                    if readinessChecks >= 24 then
                        world.recoverCustomerQueue()
                    end
                    if readinessChecks < 30 then
                        tryCashierSale(0.5)
                    end
                    return
                end
                local ok, message = Economy.sellProduct(state, os.time())
                if ok then
                    world.setStockVisual(state.stock)
                    world.setBerryStockVisual(state.berryStock)
                    world.setGoldenAppleStockVisual(state.goldenAppleStock)
                    world.setCerealStockVisual(state.cerealStock)
                    world.setCinnamonTwistStockVisual(state.cinnamonTwistStock)
                    world.setBerryStockAvailable(
                        state.berryBackstock >= Economy.BERRY_BITES_STOCK_PER_RESTOCK
                    )
                    commit("sale")
                    broadcast("Cashier served the customer automatically. " .. message)
                end
            end)
        end
        tryCashierSale(4)
    end

    local cleanerScheduleVersion = 0
    local function scheduleCleaner()
        cleanerScheduleVersion += 1
        local scheduleVersion = cleanerScheduleVersion
        if
            not state
            or not state.cleanerHired
            or not state.cleanerAutomationEnabled
            or state.stage ~= "Spill"
        then
            return
        end
        task.delay(5, function()
            if
                scheduleVersion ~= cleanerScheduleVersion
                or not ownerReady
                or not ownerPlayer
                or not state
                or not state.cleanerHired
                or not state.cleanerAutomationEnabled
                or state.stage ~= "Spill"
                or ProfileService.getSaveStatus(ownerPlayer) == "lock lost"
                or ProfileService.getSaveStatus(ownerPlayer) == "save pending"
            then
                return
            end
            local ok, message = Economy.cleanSpill(state)
            if ok then
                world.setSpillVisible(false)
                commit("spillCleaned")
                broadcast("The cleaner handled the spill. " .. message)
            end
        end)
    end

    local deliveryWorkerScheduleVersion = 0
    local function scheduleDeliveryWorkerPickup()
        deliveryWorkerScheduleVersion += 1
        local scheduleVersion = deliveryWorkerScheduleVersion
        local shipmentReadyAt = state and state.shipmentReadyAt or 0
        if
            not state
            or not state.deliveryWorkerHired
            or not state.deliveryWorkerAutomationEnabled
            or state.shipmentQuantity <= 0
            or shipmentReadyAt <= 0
            or os.time() < shipmentReadyAt
        then
            return
        end

        task.delay(3, function()
            if
                scheduleVersion ~= deliveryWorkerScheduleVersion
                or not ownerReady
                or not ownerPlayer
                or not state
                or not state.deliveryWorkerHired
                or not state.deliveryWorkerAutomationEnabled
                or state.shipmentQuantity <= 0
                or state.shipmentReadyAt ~= shipmentReadyAt
            then
                return
            end
            local saveStatus = ProfileService.getSaveStatus(ownerPlayer)
            if saveStatus == "lock lost" then
                return
            elseif saveStatus == "save pending" then
                scheduleDeliveryWorkerPickup()
                return
            end
            local ok, message = Economy.receiveDelivery(state, os.time())
            if ok then
                world.setDeliveryState(
                    state.shipmentReadyAt,
                    state.shipmentQuantity,
                    state.shipmentProductId
                )
                commit("deliveryReceivedByWorker")
                broadcast("The delivery worker received the shipment. " .. message)
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
                world.setDeliveryState(
                    state.shipmentReadyAt,
                    state.shipmentQuantity,
                    state.shipmentProductId
                )
                broadcast(
                    "A "
                        .. Economy.PRODUCTS[state.shipmentProductId].displayName
                        .. " delivery has arrived at the warehouse loading dock."
                )
                scheduleDeliveryWorkerPickup()
            end
        end)
    end

    local scheduledPowerOutageAt
    local function schedulePowerOutageRecovery()
        if not state or state.stage ~= "PowerOutage" or state.powerOutageUntil <= 0 then
            scheduledPowerOutageAt = nil
            return
        end
        local recoveryAt = state.powerOutageUntil
        if scheduledPowerOutageAt == recoveryAt then
            return
        end
        scheduledPowerOutageAt = recoveryAt
        task.delay(math.max(0, recoveryAt - os.time()), function()
            if
                not ownerReady
                or not ownerPlayer
                or not state
                or state.stage ~= "PowerOutage"
                or state.powerOutageUntil ~= recoveryAt
            then
                return
            end
            local saveStatus = ProfileService.getSaveStatus(ownerPlayer)
            if saveStatus == "lock lost" then
                return
            elseif saveStatus == "save pending" then
                scheduledPowerOutageAt = nil
                task.delay(1, schedulePowerOutageRecovery)
                return
            end
            local ok, message = Economy.recoverPower(state, os.time())
            if ok then
                commit("powerRecoveredAuto")
                broadcast(message)
            end
        end)
    end

    local scheduledCustomerRushAt
    local function scheduleCustomerRushExpiry()
        if not state or state.stage ~= "CustomerRush" or state.customerRushUntil <= 0 then
            scheduledCustomerRushAt = nil
            return
        end
        local expiresAt = state.customerRushUntil
        if scheduledCustomerRushAt == expiresAt then
            return
        end
        scheduledCustomerRushAt = expiresAt
        task.delay(math.max(0, expiresAt - os.time()), function()
            if
                not ownerReady
                or not ownerPlayer
                or not state
                or state.stage ~= "CustomerRush"
                or state.customerRushUntil ~= expiresAt
            then
                return
            end
            local saveStatus = ProfileService.getSaveStatus(ownerPlayer)
            if saveStatus == "lock lost" then
                return
            elseif saveStatus == "save pending" then
                scheduledCustomerRushAt = nil
                task.delay(1, scheduleCustomerRushExpiry)
                return
            end
            local ok, message = Economy.expireCustomerRush(state, os.time())
            if ok then
                commit("customerRushExpired")
                broadcast(message)
            end
        end)
    end

    commit = function(eventName)
        ProfileService.saveProgress(ownerPlayer, state, eventName)
        TelemetryService.record(ownerPlayer, eventName)
        if state.stage ~= "Complete" and marketStylePreviewing then
            marketStylePreviewing = false
            world.setMarketStylePreview(false)
        end
        world.setStage(state.stage)
        world.setRetailLayout(state.retailLayout)
        world.setCustomerProduct(
            Economy.PRODUCTS[Economy.getNextCheckoutProductId(state) or "citrusPop"].displayName
        )
        local nextBasket = Economy.getNextCheckoutBasket(state)
        world.setCustomerBasket(nextBasket.displayName, nextBasket.preferenceName)
        for productId in pairs(Economy.PRODUCTS) do
            world.setProductPrice(productId, Economy.getProductPrice(state, productId))
        end
        world.setStockAvailable(
            state.backstock >= Economy.CITRUS_POP_STOCK_PER_RESTOCK
                and state.stock + Economy.CITRUS_POP_STOCK_PER_RESTOCK
                    <= Economy.CITRUS_POP_SHELF_CAPACITY
        )
        world.setBerryStockAvailable(
            state.warehousePurchased
                and state.berryBackstock >= Economy.BERRY_BITES_STOCK_PER_RESTOCK
                and state.berryStock + Economy.BERRY_BITES_STOCK_PER_RESTOCK
                    <= Economy.BERRY_BITES_SHELF_CAPACITY
        )
        world.setGoldenAppleStockAvailable(
            state.warehousePurchased
                and state.goldenAppleBackstock >= Economy.GOLDEN_APPLES_STOCK_PER_RESTOCK
                and state.goldenAppleStock + Economy.GOLDEN_APPLES_STOCK_PER_RESTOCK
                    <= Economy.GOLDEN_APPLES_SHELF_CAPACITY
        )
        world.setCerealStockVisual(state.cerealStock)
        world.setCerealStockAvailable(
            state.warehousePurchased
                and state.cerealBackstock >= Economy.SUNRISE_CEREAL_STOCK_PER_RESTOCK
                and state.cerealStock + Economy.SUNRISE_CEREAL_STOCK_PER_RESTOCK
                    <= Economy.SUNRISE_CEREAL_SHELF_CAPACITY
        )
        world.setCinnamonTwistStockVisual(state.cinnamonTwistStock)
        world.setCinnamonTwistStockAvailable(
            state.bakeryPurchased
                and state.cinnamonTwistBackstock >= Economy.CINNAMON_TWISTS_STOCK_PER_RESTOCK
                and state.cinnamonTwistStock + Economy.CINNAMON_TWISTS_STOCK_PER_RESTOCK
                    <= Economy.CINNAMON_TWISTS_SHELF_CAPACITY
        )
        world.setCustomerCount(
            Economy.getRemainingCustomers(state),
            Economy.getCustomerTarget(state)
        )
        broadcast()
        scheduleStocker()
        scheduleCashierSale()
        scheduleCleaner()
        scheduleDeliveryArrival()
        scheduleDeliveryWorkerPickup()
        schedulePowerOutageRecovery()
        scheduleCustomerRushExpiry()
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

    bind("StockBerryBites", world.berryStockPrompt, 12, function()
        local ok, message = Economy.stockBerryBites(state)
        if ok then
            world.setBerryStockVisual(state.berryStock)
            world.setBerryStockAvailable(
                state.warehousePurchased
                    and state.berryBackstock >= Economy.BERRY_BITES_STOCK_PER_RESTOCK
                    and state.berryStock + Economy.BERRY_BITES_STOCK_PER_RESTOCK
                        <= Economy.BERRY_BITES_SHELF_CAPACITY
            )
            commit("berryStock")
        end
        broadcast(message)
    end)

    bind("StockGoldenApples", world.goldenAppleStockPrompt, 12, function()
        local ok, message = Economy.stockGoldenApples(state)
        if ok then
            world.setGoldenAppleStockVisual(state.goldenAppleStock)
            world.setGoldenAppleStockAvailable(
                state.warehousePurchased
                    and state.goldenAppleBackstock >= Economy.GOLDEN_APPLES_STOCK_PER_RESTOCK
                    and state.goldenAppleStock + Economy.GOLDEN_APPLES_STOCK_PER_RESTOCK
                        <= Economy.GOLDEN_APPLES_SHELF_CAPACITY
            )
            commit("goldenAppleStock")
        end
        broadcast(message)
    end)

    bind("StockSunriseCereal", world.cerealStockPrompt, 12, function()
        local ok, message = Economy.stockSunriseCereal(state)
        if ok then
            commit("cerealStock")
        end
        broadcast(message)
    end)

    bind("StockCinnamonTwists", world.cinnamonTwistStockPrompt(), 12, function()
        local ok, message = Economy.stockCinnamonTwists(state)
        if ok then
            commit("bakeryStock")
        end
        broadcast(message)
    end)

    local function bindPricePrompt(productId, actionId)
        bind(actionId, world.pricePrompt(productId), 12, function()
            local ok, message = Economy.cycleProductPrice(state, productId)
            if ok then
                commit("priceChanged")
            end
            broadcast(message)
        end)
    end

    for productId, actionId in pairs({
        citrusPop = "PriceCitrusPop",
        berryBites = "PriceBerryBites",
        goldenApples = "PriceGoldenApples",
        sunriseCereal = "PriceSunriseCereal",
        cinnamonTwists = "PriceCinnamonTwists",
    }) do
        bindPricePrompt(productId, actionId)
    end

    bind("Checkout", world.registerPrompt, 12, function()
        if not world.isCheckoutReady() then
            broadcast(
                "The customer is still shopping. Checkout will open when they reach the till."
            )
            return
        end
        local ok, message = Economy.sellProduct(state, os.time())
        if ok then
            world.setStockVisual(state.stock)
            world.setStockAvailable(
                state.backstock >= Economy.CITRUS_POP_STOCK_PER_RESTOCK
                    and state.stock + Economy.CITRUS_POP_STOCK_PER_RESTOCK
                        <= Economy.CITRUS_POP_SHELF_CAPACITY
            )
            world.setBerryStockVisual(state.berryStock)
            world.setGoldenAppleStockVisual(state.goldenAppleStock)
            commit("sale")
        end
        broadcast(message)
    end)

    bind("Spill", world.spillPrompt, 12, function()
        local ok, message = Economy.cleanSpill(state)
        if ok then
            world.setSpillVisible(false)
            commit("spillCleaned")
        end
        broadcast(message)
    end)

    bind("RestorePower", world.powerPrompt, 12, function()
        local ok, message = Economy.restorePower(state)
        if ok then
            commit("powerRestored")
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
            world.setStorageLayout(state.warehouseLayout)
            commit("warehouse")
        end
        broadcast(message)
    end)

    bind("EditLayout", world.layoutPrompt, 12, function(player)
        if state.warehousePurchased then
            layoutRequestEvent:FireClient(player, {
                action = "Open",
                layout = state.warehouseLayout,
            })
        end
    end)

    bind("EditRetailLayout", world.retailLayoutPrompt, 12, function(player)
        retailLayoutRequestEvent:FireClient(player, {
            action = "Open",
            layout = state.retailLayout,
            floorExpansionOwned = state.floorExpansionPurchased,
        })
    end)

    bind("AisleExpansion", world.aisleExpansionPrompt, 12, function()
        local ok, message = Economy.buyAisleExpansion(state)
        if ok then
            world.addAisleExpansion()
            commit("aisleExpansion")
        end
        broadcast(message)
    end)

    bind("FloorExpansion", world.floorExpansionPrompt, 12, function()
        local ok, message = Economy.buyFloorExpansion(state)
        if ok then
            world.addFloorExpansion()
            commit("floorExpansion")
        end
        broadcast(message)
    end)

    bind("BuildBakery", world.bakeryDepartmentPrompt, 12, function()
        local ok, message = Economy.buyBakeryDepartment(state)
        if ok then
            world.addBakeryDepartment()
            commit("bakeryBuilt")
        end
        broadcast(message)
    end)

    bind("MarketStyle", world.marketStylePrompt, 13, function()
        local ok, message = Economy.buyMarketStyle(state)
        if ok then
            marketStylePreviewing = false
            world.setMarketStylePreview(false)
            world.setMarketStyle(state.marketStylePurchased)
            commit("marketStyle")
        end
        broadcast(message)
    end)

    bind("PreviewMarketStyle", world.marketStylePreviewPrompt, 13, function()
        marketStylePreviewing = not marketStylePreviewing
        world.setMarketStylePreview(marketStylePreviewing)
        broadcast(
            marketStylePreviewing
                    and "Coastal Market preview applied. Purchase it at the refresh pad to keep it."
                or "Coastal Market preview canceled. Your saved storefront style is restored."
        )
    end)

    bind("OrderDelivery", world.orderDeliveryPrompt(), 12, function()
        local ok, message = Economy.orderDelivery(state, os.time(), "citrusPop")
        if ok then
            world.setDeliveryState(
                state.shipmentReadyAt,
                state.shipmentQuantity,
                state.shipmentProductId
            )
            commit("deliveryOrdered")
        end
        broadcast(message)
    end)

    bind("OrderBerryDelivery", world.berryDeliveryPrompt(), 12, function()
        local ok, message = Economy.orderDelivery(state, os.time(), "berryBites")
        if ok then
            world.setDeliveryState(
                state.shipmentReadyAt,
                state.shipmentQuantity,
                state.shipmentProductId
            )
            commit("berryDeliveryOrdered")
        end
        broadcast(message)
    end)

    bind("OrderAppleDelivery", world.appleDeliveryPrompt(), 12, function()
        local ok, message = Economy.orderDelivery(state, os.time(), "goldenApples")
        if ok then
            world.setDeliveryState(
                state.shipmentReadyAt,
                state.shipmentQuantity,
                state.shipmentProductId
            )
            commit("goldenAppleDeliveryOrdered")
        end
        broadcast(message)
    end)

    bind("OrderCerealDelivery", world.cerealDeliveryPrompt(), 12, function()
        local ok, message = Economy.orderDelivery(state, os.time(), "sunriseCereal")
        if ok then
            world.setDeliveryState(
                state.shipmentReadyAt,
                state.shipmentQuantity,
                state.shipmentProductId
            )
            commit("cerealDeliveryOrdered")
        end
        broadcast(message)
    end)

    bind("OrderCinnamonTwistsDelivery", world.cinnamonTwistDeliveryPrompt(), 12, function()
        local ok, message = Economy.orderDelivery(state, os.time(), "cinnamonTwists")
        if ok then
            world.setDeliveryState(
                state.shipmentReadyAt,
                state.shipmentQuantity,
                state.shipmentProductId
            )
            commit("bakeryDeliveryOrdered")
        end
        broadcast(message)
    end)

    bind("ReceiveDelivery", world.deliveryPrompt(), 12, function()
        local ok, message = Economy.receiveDelivery(state, os.time())
        if ok then
            world.setDeliveryState(
                state.shipmentReadyAt,
                state.shipmentQuantity,
                state.shipmentProductId
            )
            commit("deliveryReceived")
        end
        broadcast(message)
    end)

    bind("Complete", world.restartPrompt, 12, function()
        local ok, message = Economy.restartShift(state)
        if ok then
            world.setStockVisual(0)
            world.setBerryStockVisual(0)
            world.setGoldenAppleStockVisual(0)
            world.setCerealStockVisual(0)
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

    bind("HireCleaner", world.cleanerHirePrompt, 12, function()
        local ok, message = Economy.hireCleaner(state)
        if ok then
            world.setCleanerHired(true)
            commit("employeeHired")
        end
        broadcast(message)
    end)

    bind("HireDeliveryWorker", world.deliveryWorkerHirePrompt, 12, function()
        local ok, message = Economy.hireDeliveryWorker(state)
        if ok then
            world.setDeliveryWorkerHired(true)
            commit("employeeHired")
        end
        broadcast(message)
    end)

    bind("HireCustomerAssistant", world.customerAssistantHirePrompt, 12, function()
        local ok, message = Economy.hireCustomerAssistant(state)
        if ok then
            world.setCustomerAssistantHired(true)
            commit("employeeHired")
        end
        broadcast(message)
    end)

    bind("ToggleCashierAutomation", world.cashierAutomationPrompt, 12, function()
        local ok, message = Economy.toggleEmployeeAutomation(state, "cashier")
        if ok then
            world.setCashierAutomationEnabled(state.cashierAutomationEnabled)
            commit("employeeAutomationChanged")
        end
        broadcast(message)
    end)

    bind("ToggleStockerAutomation", world.stockerAutomationPrompt, 12, function()
        local ok, message = Economy.toggleEmployeeAutomation(state, "stocker")
        if ok then
            world.setStockerAutomationEnabled(state.stockerAutomationEnabled)
            commit("employeeAutomationChanged")
        end
        broadcast(message)
    end)

    bind("ToggleCleanerAutomation", world.cleanerAutomationPrompt, 12, function()
        local ok, message = Economy.toggleEmployeeAutomation(state, "cleaner")
        if ok then
            world.setCleanerAutomationEnabled(state.cleanerAutomationEnabled)
            commit("employeeAutomationChanged")
        end
        broadcast(message)
    end)

    bind("ToggleDeliveryWorkerAutomation", world.deliveryWorkerAutomationPrompt, 12, function()
        local ok, message = Economy.toggleEmployeeAutomation(state, "deliveryWorker")
        if ok then
            world.setDeliveryWorkerAutomationEnabled(state.deliveryWorkerAutomationEnabled)
            commit("employeeAutomationChanged")
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

    layoutRequestEvent.OnServerEvent:Connect(function(player, request)
        local function reject(message)
            layoutRequestEvent:FireClient(player, { action = "Rejected", message = message })
        end

        if type(request) ~= "table" then
            return reject("That layout request is invalid.")
        end
        local now = os.clock()
        local previousRequest = layoutActionTimes[player]
        if previousRequest and now - previousRequest < 0.4 then
            return reject("Please wait before changing the layout again.")
        end
        layoutActionTimes[player] = now

        local role = player == ownerPlayer and "Owner" or storeMembers[player.UserId]
        if
            (role ~= "Owner" and role ~= "Manager")
            or not ownerReady
            or not ownerPlayer
            or player.Parent ~= Players
            or not state.warehousePurchased
            or state.stage ~= "Complete"
            or not world.layoutPrompt.Enabled
            or not atPrompt(player, world.layoutPrompt, 18)
        then
            return reject(
                "Only the Owner or Manager can edit the warehouse during a completed shift."
            )
        end
        local saveStatus = ProfileService.getSaveStatus(ownerPlayer)
        if saveStatus == "lock lost" or saveStatus == "save pending" then
            return reject("Layout editing is paused until the store save is ready.")
        end

        local items = state.warehouseLayout.items
        local action = request.action
        local message
        if action == "PlaceShelf" then
            if #items >= LayoutService.MAX_SHELVES then
                return reject("The warehouse has reached its shelf limit.")
            end
            if state.cash < LayoutService.SHELF_COST then
                return reject(
                    string.format(
                        "You need $%d to place a storage shelf.",
                        LayoutService.SHELF_COST
                    )
                )
            end
            local valid, reason =
                LayoutService.canPlace(items, request.x, request.z, request.rotation)
            if not valid then
                return reject(reason)
            end
            local item = {
                id = HttpService:GenerateGUID(false),
                kind = "Shelf",
                x = request.x,
                z = request.z,
                rotation = request.rotation,
            }
            state.cash -= LayoutService.SHELF_COST
            table.insert(items, item)
            message = "Storage shelf placed for $50."
        elseif action == "MoveShelf" then
            local _, item = LayoutService.find(items, request.id)
            if not item then
                return reject("Select a saved warehouse shelf first.")
            end
            local valid, reason =
                LayoutService.canPlace(items, request.x, request.z, request.rotation, item.id)
            if not valid then
                return reject(reason)
            end
            item.x = request.x
            item.z = request.z
            item.rotation = request.rotation
            message = "Warehouse shelf moved."
        elseif action == "RemoveShelf" then
            local index = LayoutService.find(items, request.id)
            if not index then
                return reject("Select a saved warehouse shelf first.")
            end
            table.remove(items, index)
            state.cash = math.min(state.cash + LayoutService.SHELF_REFUND, 1000000000)
            message = "Shelf removed. $25 was refunded."
        else
            return reject("That warehouse layout action is not supported.")
        end

        world.setStorageLayout(state.warehouseLayout)
        ProfileService.saveProgress(ownerPlayer, state, "layoutChanged")
        broadcast(message)
        layoutRequestEvent:FireClient(player, {
            action = "Updated",
            layout = state.warehouseLayout,
            message = message,
        })
    end)

    retailLayoutRequestEvent.OnServerEvent:Connect(function(player, request)
        local function reject(message)
            retailLayoutRequestEvent:FireClient(player, { action = "Rejected", message = message })
        end

        if
            type(request) ~= "table"
            or (request.action ~= "MoveShelf" and request.action ~= "MoveCheckout")
        then
            return reject("That retail layout request is invalid.")
        end
        local now = os.clock()
        local previousRequest = retailLayoutActionTimes[player]
        if previousRequest and now - previousRequest < 0.4 then
            return reject("Please wait before moving another department shelf.")
        end
        retailLayoutActionTimes[player] = now

        local role = player == ownerPlayer and "Owner" or storeMembers[player.UserId]
        if
            (role ~= "Owner" and role ~= "Manager")
            or not ownerReady
            or not ownerPlayer
            or player.Parent ~= Players
            or state.stage ~= "Complete"
            or not world.retailLayoutPrompt.Enabled
            or not atPrompt(player, world.retailLayoutPrompt, 18)
        then
            return reject(
                "Only the Owner or Manager can edit the store layout during a completed shift."
            )
        end
        local saveStatus = ProfileService.getSaveStatus(ownerPlayer)
        if saveStatus == "lock lost" or saveStatus == "save pending" then
            return reject("Store layout editing is paused until the store save is ready.")
        end

        if request.action == "MoveCheckout" then
            local valid, reason = RetailLayoutService.canPlaceCheckout(
                state.retailLayout.shelves,
                request.x,
                request.z,
                request.rotation
            )
            if not valid then
                return reject(reason)
            end
            state.retailLayout.checkout = {
                x = request.x,
                z = request.z,
                rotation = request.rotation,
            }
            world.setRetailLayout(state.retailLayout)
            local saved = ProfileService.saveProgress(ownerPlayer, state, "checkoutLayoutChanged")
            local resultMessage = saved and "Checkout lane and customer queue moved and saved."
                or "Checkout lane and customer queue moved for this session; the save was not confirmed."
            broadcast(resultMessage)
            retailLayoutRequestEvent:FireClient(player, {
                action = "Updated",
                layout = state.retailLayout,
                message = resultMessage,
            })
            return
        end

        local productId = request.productId
        if type(productId) ~= "string" or not RetailLayoutService.isProductId(productId) then
            return reject("Choose one of the installed product department shelves.")
        end
        local shelf = state.retailLayout.shelves[productId]
        if not shelf then
            return reject("Choose one of the installed product department shelves.")
        end
        local valid, reason = RetailLayoutService.canPlace(
            state.retailLayout.shelves,
            productId,
            request.x,
            request.z,
            request.rotation,
            state.retailLayout.checkout,
            state.floorExpansionPurchased,
            state.bakeryPurchased
        )
        if not valid then
            return reject(reason)
        end
        shelf.x = request.x
        shelf.z = request.z
        shelf.rotation = request.rotation
        world.setRetailLayout(state.retailLayout)
        local saved = ProfileService.saveProgress(ownerPlayer, state, "retailLayoutChanged")
        local productName = Economy.PRODUCTS[productId].displayName
        local resultMessage = saved and string.format("%s shelf moved and saved.", productName)
            or string.format(
                "%s shelf moved for this session; the save was not confirmed.",
                productName
            )
        broadcast(resultMessage)
        retailLayoutRequestEvent:FireClient(player, {
            action = "Updated",
            layout = state.retailLayout,
            message = resultMessage,
        })
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
            state = Economy.newState(profile, player.UserId)
            TelemetryService.begin(player, profile, state)
            ownerReady = true
            if state.upgradePurchased then
                world.addUpgrade()
            end
            if state.aisleExpansionPurchased then
                world.addAisleExpansion()
            end
            if state.floorExpansionPurchased then
                world.addFloorExpansion()
            end
            world.setMarketStyle(state.marketStylePurchased)
            marketStylePreviewing = false
            world.setWarehousePurchased(state.warehousePurchased)
            if state.bakeryPurchased then
                world.addBakeryDepartment()
            end
            world.setStorageLayout(state.warehouseLayout)
            world.setRetailLayout(state.retailLayout)
            world.setDeliveryState(
                state.shipmentReadyAt,
                state.shipmentQuantity,
                state.shipmentProductId
            )
            world.setCashierHired(state.cashierHired)
            world.setStockerHired(state.stockerHired)
            world.setCleanerHired(state.cleanerHired)
            world.setDeliveryWorkerHired(state.deliveryWorkerHired)
            world.setCustomerAssistantHired(state.customerAssistantHired)
            world.setCashierAutomationEnabled(state.cashierAutomationEnabled)
            world.setStockerAutomationEnabled(state.stockerAutomationEnabled)
            world.setCleanerAutomationEnabled(state.cleanerAutomationEnabled)
            world.setDeliveryWorkerAutomationEnabled(state.deliveryWorkerAutomationEnabled)
            world.setStockVisual(state.stock)
            world.setBerryStockVisual(state.berryStock)
            world.setGoldenAppleStockVisual(state.goldenAppleStock)
            world.setCerealStockVisual(state.cerealStock)
            world.setCinnamonTwistStockVisual(state.cinnamonTwistStock)
            world.setStockAvailable(
                state.backstock >= Economy.CITRUS_POP_STOCK_PER_RESTOCK
                    and state.stock + Economy.CITRUS_POP_STOCK_PER_RESTOCK
                        <= Economy.CITRUS_POP_SHELF_CAPACITY
            )
            world.setCerealStockAvailable(
                state.warehousePurchased
                    and state.cerealBackstock >= Economy.SUNRISE_CEREAL_STOCK_PER_RESTOCK
                    and state.cerealStock + Economy.SUNRISE_CEREAL_STOCK_PER_RESTOCK
                        <= Economy.SUNRISE_CEREAL_SHELF_CAPACITY
            )
            world.setBerryStockAvailable(
                state.warehousePurchased
                    and state.berryBackstock >= Economy.BERRY_BITES_STOCK_PER_RESTOCK
                    and state.berryStock + Economy.BERRY_BITES_STOCK_PER_RESTOCK
                        <= Economy.BERRY_BITES_SHELF_CAPACITY
            )
            world.setGoldenAppleStockAvailable(
                state.warehousePurchased
                    and state.goldenAppleBackstock >= Economy.GOLDEN_APPLES_STOCK_PER_RESTOCK
                    and state.goldenAppleStock + Economy.GOLDEN_APPLES_STOCK_PER_RESTOCK
                        <= Economy.GOLDEN_APPLES_SHELF_CAPACITY
            )
            world.setCinnamonTwistStockAvailable(
                state.bakeryPurchased
                    and state.cinnamonTwistBackstock >= Economy.CINNAMON_TWISTS_STOCK_PER_RESTOCK
                    and state.cinnamonTwistStock + Economy.CINNAMON_TWISTS_STOCK_PER_RESTOCK
                        <= Economy.CINNAMON_TWISTS_SHELF_CAPACITY
            )
            world.setCustomerProduct(
                Economy.PRODUCTS[Economy.getNextCheckoutProductId(state) or "citrusPop"].displayName
            )
            local nextBasket = Economy.getNextCheckoutBasket(state)
            world.setCustomerBasket(nextBasket.displayName, nextBasket.preferenceName)
            for productId in pairs(Economy.PRODUCTS) do
                world.setProductPrice(productId, Economy.getProductPrice(state, productId))
            end
            world.setStage(state.stage)
            world.setCustomerCount(
                Economy.getRemainingCustomers(state),
                Economy.getCustomerTarget(state)
            )
            if state.stage == "Cart" then
                startCart()
            end
            scheduleCashierSale()
            scheduleStocker()
            scheduleCleaner()
            scheduleDeliveryArrival()
            scheduleDeliveryWorkerPickup()
            schedulePowerOutageRecovery()
            scheduleCustomerRushExpiry()
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
        layoutActionTimes[player] = nil
        retailLayoutActionTimes[player] = nil
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
            world.setCustomerVisible(false)
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
