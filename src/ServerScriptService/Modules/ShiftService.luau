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
local locationId = "neighborhood"
local runtimeOptions = {}

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
        BuildFreezer = true,
        BuildSelfCheckout = true,
        BuildCafe = true,
        RestockCafe = true,
        ServeCafe = true,
        BuildRestaurant = true,
        RestockRestaurant = true,
        ServeRestaurant = true,
        BuildElectronicsStore = true,
        RestockElectronics = true,
        SellElectronics = true,
        BuildGardenStore = true,
        RestockGarden = true,
        SellGarden = true,
        BuildFlorist = true,
        BuildBookshop = true,
        RestockFlorist = true,
        RestockBookshop = true,
        SellFlorist = true,
        SellBookshop = true,
        PlazaStyle = true,
        PreviewPlazaStyle = true,
        DeliveryFleet = true,
        DistributionCenter = true,
        SupplierPartnership = true,
        FulfillOnlineOrder = true,
        SelfCheckout = true,
        EditLayout = true,
        EditRetailLayout = true,
        MarketStyle = true,
        PreviewMarketStyle = true,
        OrderDelivery = true,
        OrderBerryDelivery = true,
        OrderAppleDelivery = true,
        OrderCerealDelivery = true,
        OrderCinnamonTwistsDelivery = true,
        OrderFrozenMealsDelivery = true,
        ReceiveDelivery = true,
        PriceCitrusPop = true,
        PriceBerryBites = true,
        PriceGoldenApples = true,
        PriceSunriseCereal = true,
        PriceCinnamonTwists = true,
        PriceFrozenMeals = true,
        StockBerryBites = true,
        StockGoldenApples = true,
        StockSunriseCereal = true,
        StockCinnamonTwists = true,
        StockFrozenMeals = true,
    },
    Cashier = {
        Checkout = true,
        SelfCheckout = true,
        ServeCafe = true,
        ServeRestaurant = true,
        SellElectronics = true,
        SellGarden = true,
        SellFlorist = true,
        SellBookshop = true,
    },
    Stocker = {
        Stock = true,
        StockBerryBites = true,
        StockGoldenApples = true,
        StockSunriseCereal = true,
        StockCinnamonTwists = true,
        StockFrozenMeals = true,
        FulfillOnlineOrder = true,
        RestockCafe = true,
        RestockRestaurant = true,
        RestockElectronics = true,
        RestockGarden = true,
        RestockFlorist = true,
        RestockBookshop = true,
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
            "Shift complete • payroll $%d + store costs $%d per shift. Visit the shift board to continue.",
            Economy.getShiftPayroll(current),
            Economy.getShiftOperatingCosts(current)
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
        locationId = locationId,
        stage = current.stage,
        objective = objective,
        cash = hasStoreAccess and current.cash or 0,
        customerSatisfaction = hasStoreAccess and current.customerSatisfaction or 0,
        stock = hasStoreAccess and current.stock or 0,
        berryStock = hasStoreAccess and current.berryStock or 0,
        goldenAppleStock = hasStoreAccess and current.goldenAppleStock or 0,
        cerealStock = hasStoreAccess and current.cerealStock or 0,
        cinnamonTwistStock = hasStoreAccess and current.cinnamonTwistStock or 0,
        frozenMealStock = hasStoreAccess and current.frozenMealStock or 0,
        bakeryPurchased = hasStoreAccess and current.bakeryPurchased or false,
        freezerPurchased = hasStoreAccess and current.freezerPurchased or false,
        employeePayroll = hasStoreAccess and Economy.getShiftPayroll(current) or 0,
        operatingCosts = hasStoreAccess and Economy.getShiftOperatingCosts(current) or 0,
        bookshopPurchased = hasStoreAccess and current.bookshopPurchased or false,
        bookshopStock = hasStoreAccess and current.bookshopStock or 0,
        bookshopSales = hasStoreAccess and current.bookshopSales or 0,
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
        frozenMealBackstock = hasStoreAccess and current.frozenMealBackstock or 0,
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
            frozenMeals = current.productPrices.frozenMeals,
        } or nil,
        customerAssistantHired = hasStoreAccess and current.customerAssistantHired or false,
        uptownStorePurchased = current.uptownStorePurchased == true,
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
        locationId = locationId,
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
        if player:GetAttribute("ActiveStoreLocation") == locationId then
            sendMemberState(player)
        end
    end
end

local function broadcast(message)
    if not stateEvent then
        return
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player:GetAttribute("ActiveStoreLocation") == locationId then
            stateEvent:FireClient(player, snapshot(message, player))
        end
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

local function hasOnlyKeys(value, allowedKeys)
    if type(value) ~= "table" then
        return false
    end
    local count = 0
    for key in pairs(value) do
        count += 1
        if count > 5 or type(key) ~= "string" or #key > 24 or allowedKeys[key] ~= true then
            return false
        end
    end
    return count > 0
end

function ShiftService.init(event, membershipRemotes, options)
    runtimeOptions = options or {}
    locationId = runtimeOptions.locationId or "neighborhood"
    stateEvent = event
    joinRequestEvent = membershipRemotes.joinRequest
    memberActionEvent = membershipRemotes.memberAction
    memberStateEvent = membershipRemotes.memberState
    layoutRequestEvent = membershipRemotes.layoutRequest
    retailLayoutRequestEvent = membershipRemotes.retailLayoutRequest
    world = WorldBuilder.build(locationId, runtimeOptions.origin)
    local marketStylePreviewing = false
    local marketStylePreviewIndex = 0
    local marketStylePreviewIds = { "coastal", "urban", "harvest" }
    local marketStyleSelectedId = "coastal"
    local plazaStylePreviewing = false
    local plazaStylePreviewIndex = 0
    local plazaStylePreviewIds = { "coastal", "urban", "harvest" }
    local plazaStyleSelectedId = "coastal"
    world.setStage("Loading")
    if locationId == "neighborhood" then
        ProfileService.startAutosave(function()
            broadcast()
        end)
    end

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
    local saleTransactionInProgress = false
    local lastPlazaSaleAt = {}
    local performSale
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
                world.setFrozenMealStockVisual(state.frozenMealStock)
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
                if saleTransactionInProgress then
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
                local ok, message = performSale()
                if ok then
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

    local onlineOrderWorkerScheduleVersion = 0
    local function scheduleOnlineOrderWorker()
        onlineOrderWorkerScheduleVersion += 1
        local scheduleVersion = onlineOrderWorkerScheduleVersion
        local completedShift = state and state.completedShifts or 0
        local orderLimit = state
                and state.deliveryFleetPurchased
                and Economy.DELIVERY_FLEET_ORDERS_PER_SHIFT
            or 1
        local ordersThisShift = state
                and state.deliveryWorkerOrderShift == completedShift
                and (state.deliveryWorkerOrdersThisShift or 0)
            or 0
        if
            not state
            or state.stage ~= "Complete"
            or not state.warehousePurchased
            or not state.deliveryWorkerHired
            or not state.deliveryWorkerAutomationEnabled
            or ordersThisShift >= orderLimit
            or not Economy.getNextOnlineOrder(state).ready
        then
            return
        end

        task.delay(5, function()
            if
                scheduleVersion ~= onlineOrderWorkerScheduleVersion
                or not ownerReady
                or not ownerPlayer
                or not state
                or state.stage ~= "Complete"
                or state.completedShifts ~= completedShift
                or not state.deliveryWorkerHired
                or not state.deliveryWorkerAutomationEnabled
                or (state.deliveryWorkerOrderShift == completedShift and (state.deliveryWorkerOrdersThisShift or 0) >= orderLimit)
                or not Economy.getNextOnlineOrder(state).ready
            then
                return
            end
            local saveStatus = ProfileService.getSaveStatus(ownerPlayer)
            if saveStatus == "lock lost" then
                return
            elseif saveStatus == "save pending" or saleTransactionInProgress then
                scheduleOnlineOrderWorker()
                return
            end

            saleTransactionInProgress = true
            local ok, message = Economy.fulfillOnlineOrder(state)
            if ok then
                if state.deliveryWorkerOrderShift ~= completedShift then
                    state.deliveryWorkerOrdersThisShift = 0
                end
                state.deliveryWorkerOrderShift = completedShift
                state.deliveryWorkerOrdersThisShift += 1
                commit("onlineOrderFulfilledByWorker")
                broadcast("The delivery worker packed today's online order. " .. message)
            end
            saleTransactionInProgress = false
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
        ProfileService.saveProgress(ownerPlayer, state, eventName, locationId)
        if locationId == "neighborhood" then
            TelemetryService.record(ownerPlayer, eventName)
        end
        if state.stage ~= "Complete" and marketStylePreviewing then
            marketStylePreviewing = false
            marketStylePreviewIndex = 0
            marketStyleSelectedId = state.marketStyleId ~= "" and state.marketStyleId or "coastal"
            world.setMarketStylePreview(nil)
        end
        if state.stage ~= "Complete" and plazaStylePreviewing then
            plazaStylePreviewing = false
            plazaStylePreviewIndex = 0
            plazaStyleSelectedId = state.plazaStyleId ~= "" and state.plazaStyleId or "coastal"
            world.setPlazaStylePreview(nil)
        end
        world.setStage(state.stage)
        world.setUptownStorePurchased(
            state.uptownStorePurchased,
            state.supplierPartnershipPurchased
        )
        world.setRetailLayout(state.retailLayout)
        world.setCustomerProduct(
            Economy.PRODUCTS[Economy.getNextCheckoutProductId(state) or "citrusPop"].displayName
        )
        local nextBasket = Economy.getNextCheckoutBasket(state)
        world.setCustomerBasket(nextBasket.displayName, nextBasket.preferenceName, nextBasket.items)
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
        world.setFrozenMealStockVisual(state.frozenMealStock)
        world.setFrozenMealStockAvailable(
            state.freezerPurchased
                and state.frozenMealBackstock >= Economy.FROZEN_MEALS_STOCK_PER_RESTOCK
                and state.frozenMealStock + Economy.FROZEN_MEALS_STOCK_PER_RESTOCK
                    <= Economy.FROZEN_MEALS_SHELF_CAPACITY
        )
        world.setCustomerCount(
            Economy.getRemainingCustomers(state),
            Economy.getCustomerTarget(state)
        )
        world.setOnlineOrderState(Economy.getNextOnlineOrder(state))
        world.setCafeState(state.cafePurchased, state.cafeStock, state.cafeSales)
        world.setRestaurantState(
            state.restaurantPurchased,
            state.restaurantStock,
            state.restaurantSales
        )
        world.setElectronicsStoreState(
            state.electronicsStorePurchased,
            state.electronicsStock,
            state.electronicsSales
        )
        world.setGardenStoreState(state.gardenStorePurchased, state.gardenStock, state.gardenSales)
        world.setFloristState(state.floristStorePurchased, state.floristStock, state.floristSales)
        world.setBookshopState(state.bookshopPurchased, state.bookshopStock, state.bookshopSales)
        world.setPlazaStyle(state.plazaStylePurchased, state.plazaStyleId)
        world.setUptownStorePurchased(
            state.uptownStorePurchased,
            state.supplierPartnershipPurchased
        )
        world.setDeliveryFleetPurchased(state.deliveryFleetPurchased)
        world.setDistributionCenterPurchased(state.distributionCenterPurchased)
        world.setSupplierPartnershipPurchased(state.supplierPartnershipPurchased)
        broadcast()
        scheduleOnlineOrderWorker()
        scheduleStocker()
        scheduleCashierSale()
        scheduleCleaner()
        scheduleDeliveryArrival()
        scheduleDeliveryWorkerPickup()
        schedulePowerOutageRecovery()
        scheduleCustomerRushExpiry()
    end

    world.plazaVisitEvent.Event:Connect(function(businessId)
        if
            type(businessId) ~= "string"
            or (businessId ~= "cafe" and businessId ~= "restaurant" and businessId ~= "electronics" and businessId ~= "garden" and businessId ~= "florist" and businessId ~= "bookshop")
            or saleTransactionInProgress
            or not ownerReady
            or not ownerPlayer
            or state.stage == "Loading"
            or state.stage == "OwnerOffline"
            or ProfileService.getSaveStatus(ownerPlayer) == "lock lost"
            or ProfileService.getSaveStatus(ownerPlayer) == "save pending"
        then
            return
        end
        local now = os.clock()
        if lastPlazaSaleAt[businessId] and now - lastPlazaSaleAt[businessId] < 15 then
            return
        end

        saleTransactionInProgress = true
        local ok, message
        if businessId == "cafe" then
            ok, message = Economy.serveCafeCoffee(state)
        elseif businessId == "restaurant" then
            ok, message = Economy.serveRestaurantMeal(state)
        elseif businessId == "electronics" then
            ok, message = Economy.sellElectronics(state)
        elseif businessId == "garden" then
            ok, message = Economy.sellGardenItem(state)
        elseif businessId == "florist" then
            ok, message = Economy.sellFloristBouquet(state)
        else
            ok, message = Economy.sellBookshopPaperback(state)
        end
        if ok then
            lastPlazaSaleAt[businessId] = now
            commit("plazaCustomerSale")
            broadcast(message)
        end
        saleTransactionInProgress = false
    end)

    performSale = function()
        if saleTransactionInProgress then
            return false, "Checkout is finishing the previous customer's sale."
        end
        if not world.isCheckoutReady() then
            return false,
                "The customer is still shopping. Checkout will open when they reach the till."
        end

        saleTransactionInProgress = true
        local ok, message = Economy.sellProduct(state, os.time(), world.getCheckoutWaitSeconds())
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
        saleTransactionInProgress = false
        return ok, message
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

    bind("StockFrozenMeals", world.frozenMealStockPrompt(), 12, function()
        local ok, message = Economy.stockFrozenMeals(state)
        if ok then
            world.setFrozenMealStockVisual(state.frozenMealStock)
            world.setFrozenMealStockAvailable(
                state.frozenMealBackstock >= Economy.FROZEN_MEALS_STOCK_PER_RESTOCK
                    and state.frozenMealStock + Economy.FROZEN_MEALS_STOCK_PER_RESTOCK
                        <= Economy.FROZEN_MEALS_SHELF_CAPACITY
            )
            commit("freezerStock")
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
        frozenMeals = "PriceFrozenMeals",
    }) do
        bindPricePrompt(productId, actionId)
    end

    bind("Checkout", world.registerPrompt, 12, function()
        local _, message = performSale()
        broadcast(message)
    end)

    bind("SelfCheckout", world.selfCheckoutPrompt, 12, function()
        local _, message = performSale()
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
                locationId = locationId,
                layout = state.warehouseLayout,
            })
        end
    end)

    bind("EditRetailLayout", world.retailLayoutPrompt, 12, function(player)
        retailLayoutRequestEvent:FireClient(player, {
            action = "Open",
            locationId = locationId,
            layout = state.retailLayout,
            bakeryPurchased = state.bakeryPurchased,
            freezerPurchased = state.freezerPurchased,
            floorExpansionOwned = state.floorExpansionPurchased,
            shelfBayPurchased = state.upgradePurchased,
            householdAislePurchased = state.aisleExpansionPurchased,
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

    bind("BuildFreezer", world.freezerDepartmentPrompt, 12, function()
        local ok, message = Economy.buyFreezerDepartment(state)
        if ok then
            world.addFreezerDepartment()
            world.setDeliveryState(
                state.shipmentReadyAt,
                state.shipmentQuantity,
                state.shipmentProductId
            )
            commit("freezerBuilt")
        end
        broadcast(message)
    end)

    bind("BuildSelfCheckout", world.selfCheckoutBuildPrompt, 12, function()
        local ok, message = Economy.buySelfCheckout(state)
        if ok then
            world.setSelfCheckoutPurchased(true)
            commit("selfCheckoutBuilt")
        end
        broadcast(message)
    end)

    bind("BuildCafe", world.cafeBuildPrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try building the café again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.buyCafe(state)
        if ok then
            world.setCafeState(state.cafePurchased, state.cafeStock, state.cafeSales)
            commit("cafeBuilt")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("RestockCafe", world.cafeRestockPrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try brewing coffee again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.restockCafe(state)
        if ok then
            commit("cafeRestocked")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("ServeCafe", world.cafeServePrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try serving coffee again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.serveCafeCoffee(state)
        if ok then
            commit("cafeCoffeeSold")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("BuildRestaurant", world.restaurantBuildPrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try building Market Table again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.buyRestaurant(state)
        if ok then
            world.setRestaurantState(
                state.restaurantPurchased,
                state.restaurantStock,
                state.restaurantSales
            )
            world.setElectronicsStoreState(
                state.electronicsStorePurchased,
                state.electronicsStock,
                state.electronicsSales
            )
            world.setGardenStoreState(
                state.gardenStorePurchased,
                state.gardenStock,
                state.gardenSales
            )
            world.setFloristState(
                state.floristStorePurchased,
                state.floristStock,
                state.floristSales
            )
            world.setBookshopState(
                state.bookshopPurchased,
                state.bookshopStock,
                state.bookshopSales
            )
            commit("restaurantBuilt")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("RestockRestaurant", world.restaurantRestockPrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try prepping a meal batch again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.restockRestaurant(state)
        if ok then
            commit("restaurantRestocked")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("ServeRestaurant", world.restaurantServePrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try serving the meal again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.serveRestaurantMeal(state)
        if ok then
            commit("restaurantMealSold")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("BuildElectronicsStore", world.electronicsBuildPrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try building Pixel & Plug again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.buyElectronicsStore(state)
        if ok then
            world.setElectronicsStoreState(
                state.electronicsStorePurchased,
                state.electronicsStock,
                state.electronicsSales
            )
            commit("electronicsStoreBuilt")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("RestockElectronics", world.electronicsRestockPrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try restocking Pixel & Plug again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.restockElectronics(state)
        if ok then
            commit("electronicsRestocked")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("SellElectronics", world.electronicsSalePrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try selling headphones again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.sellElectronics(state)
        if ok then
            commit("electronicsItemSold")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("BuildGardenStore", world.gardenBuildPrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try building Little Sprout again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.buyGardenStore(state)
        if ok then
            world.setGardenStoreState(
                state.gardenStorePurchased,
                state.gardenStock,
                state.gardenSales
            )
            commit("gardenStoreBuilt")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("RestockGarden", world.gardenRestockPrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try restocking Little Sprout again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.restockGarden(state)
        if ok then
            commit("gardenRestocked")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("SellGarden", world.gardenSalePrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try selling the plant again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.sellGardenItem(state)
        if ok then
            commit("gardenItemSold")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("BuildFlorist", world.floristBuildPrompt, 12, function()
        if saleTransactionInProgress then
            broadcast(
                "A store transaction is saving. Try opening Maple Corner Florist again shortly."
            )
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.buyFloristStore(state)
        if ok then
            world.setFloristState(
                state.floristStorePurchased,
                state.floristStock,
                state.floristSales
            )
            commit("floristStoreBuilt")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("BuildBookshop", world.bookshopBuildPrompt, 12, function()
        if saleTransactionInProgress then
            broadcast(
                "A store transaction is saving. Try opening Riverside Bookshop again shortly."
            )
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.buyBookshop(state)
        if ok then
            world.setBookshopState(
                state.bookshopPurchased,
                state.bookshopStock,
                state.bookshopSales
            )
            commit("bookshopBuilt")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    if world.uptownPurchasePrompt then
        bind("BuildUptownStore", world.uptownPurchasePrompt, 14, function()
            local ok, message = Economy.buyUptownStore(state)
            if not ok then
                broadcast(message)
                return
            end
            if not ProfileService.createLocation(ownerPlayer, "uptown") then
                state.cash += Economy.UPTOWN_STORE_COST
                state.uptownStorePurchased = false
                broadcast("Uptown Market could not be created. No money was charged.")
                return
            end
            commit("uptownStorePurchased")
            broadcast("Uptown Market opened. Use the gold travel pad to visit.")
            if runtimeOptions.onUptownOpened then
                runtimeOptions.onUptownOpened(ownerPlayer)
            end
        end)
    end

    world.locationTravelPrompt.Triggered:Connect(function(player)
        if not ownerReady or player.Parent ~= Players then
            return
        end
        if locationId == "neighborhood" and not state.uptownStorePurchased then
            return
        end
        local now = os.clock()
        if interactionTimes[player] and now - interactionTimes[player] < 0.45 then
            return
        end
        if not atPrompt(player, world.locationTravelPrompt, 14) then
            return
        end
        interactionTimes[player] = now
        local character = player.Character
        if not character then
            return
        end
        player:SetAttribute(
            "ActiveStoreLocation",
            locationId == "uptown" and "neighborhood" or "uptown"
        )
        character:PivotTo(world.travelDestination)
        broadcast()
        broadcastMemberState()
    end)

    bind("RestockFlorist", world.floristRestockPrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try restocking Maple Corner again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.restockFlorist(state)
        if ok then
            commit("floristRestocked")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("SellFlorist", world.floristSalePrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try selling the bouquet again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.sellFloristBouquet(state)
        if ok then
            commit("floristBouquetSold")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("RestockBookshop", world.bookshopRestockPrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try restocking Riverside Bookshop shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.restockBookshop(state)
        if ok then
            commit("bookshopRestocked")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("SellBookshop", world.bookshopSalePrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try selling the paperback again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.sellBookshopPaperback(state)
        if ok then
            commit("bookshopPaperbackSold")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("MarketStyle", world.marketStylePrompt, 13, function()
        local ok, message = Economy.buyMarketStyle(state, marketStyleSelectedId)
        if ok then
            marketStylePreviewing = false
            marketStylePreviewIndex = 0
            world.setMarketStylePreview(nil)
            world.setMarketStyle(state.marketStylePurchased, state.marketStyleId)
            commit("marketStyle")
        end
        broadcast(message)
    end)

    bind("PreviewMarketStyle", world.marketStylePreviewPrompt, 13, function()
        marketStylePreviewIndex += 1
        if marketStylePreviewIndex > #marketStylePreviewIds then
            marketStylePreviewIndex = 0
            marketStylePreviewing = false
            marketStyleSelectedId = state.marketStyleId ~= "" and state.marketStyleId or "coastal"
            world.setMarketStylePreview(nil)
            broadcast("Storefront preview canceled. The original look is restored.")
            return
        end
        marketStylePreviewing = true
        marketStyleSelectedId = marketStylePreviewIds[marketStylePreviewIndex]
        world.setMarketStylePreview(marketStyleSelectedId)
        broadcast(
            world.getMarketStyleName(marketStyleSelectedId)
                .. " preview applied. Preview the next style or install this one at the refresh pad."
        )
    end)

    bind("PlazaStyle", world.plazaStylePrompt, 13, function()
        local ok, message = Economy.buyPlazaStyle(state, plazaStyleSelectedId)
        if ok then
            plazaStylePreviewing = false
            plazaStylePreviewIndex = 0
            world.setPlazaStylePreview(nil)
            world.setPlazaStyle(state.plazaStylePurchased, state.plazaStyleId)
            commit("plazaStyle")
        end
        broadcast(message)
    end)

    bind("PreviewPlazaStyle", world.plazaStylePreviewPrompt, 13, function()
        plazaStylePreviewIndex += 1
        if plazaStylePreviewIndex > #plazaStylePreviewIds then
            plazaStylePreviewIndex = 0
            plazaStylePreviewing = false
            plazaStyleSelectedId = state.plazaStyleId ~= "" and state.plazaStyleId or "coastal"
            world.setPlazaStylePreview(nil)
            broadcast("Plaza style preview canceled. The current look is restored.")
            return
        end
        plazaStylePreviewing = true
        plazaStyleSelectedId = plazaStylePreviewIds[plazaStylePreviewIndex]
        world.setPlazaStylePreview(plazaStyleSelectedId)
        broadcast(
            world.getPlazaStyleName(plazaStyleSelectedId)
                .. " preview applied. Preview the next style or install this one."
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

    bind("OrderFrozenMealsDelivery", world.frozenMealDeliveryPrompt(), 12, function()
        local ok, message = Economy.orderDelivery(state, os.time(), "frozenMeals")
        if ok then
            world.setDeliveryState(
                state.shipmentReadyAt,
                state.shipmentQuantity,
                state.shipmentProductId
            )
            commit("freezerDeliveryOrdered")
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

    bind("FulfillOnlineOrder", world.onlineOrderPrompt(), 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try packing the order again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.fulfillOnlineOrder(state)
        if ok then
            if state.deliveryWorkerOrderShift ~= state.completedShifts then
                state.deliveryWorkerOrdersThisShift = 0
            end
            state.deliveryWorkerOrderShift = state.completedShifts
            state.deliveryWorkerOrdersThisShift = math.min(
                (state.deliveryWorkerOrdersThisShift or 0) + 1,
                Economy.DELIVERY_FLEET_ORDERS_PER_SHIFT
            )
            commit("onlineOrderFulfilled")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("Complete", world.restartPrompt, 12, function()
        local ok, message = Economy.restartShift(state)
        if ok then
            world.setStockVisual(0)
            world.setBerryStockVisual(0)
            world.setGoldenAppleStockVisual(0)
            world.setCerealStockVisual(0)
            world.setCinnamonTwistStockVisual(0)
            world.setFrozenMealStockVisual(0)
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

    bind("DeliveryFleet", world.deliveryFleetPrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try adding the fleet again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.buyDeliveryFleet(state)
        if ok then
            world.setDeliveryFleetPurchased(state.deliveryFleetPurchased)
            commit("deliveryFleetPurchased")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("DistributionCenter", world.distributionCenterPrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try the distribution center again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.buyDistributionCenter(state)
        if ok then
            world.setDistributionCenterPurchased(state.distributionCenterPurchased)
            commit("distributionCenterPurchased")
        end
        saleTransactionInProgress = false
        broadcast(message)
    end)

    bind("SupplierPartnership", world.supplierPartnershipPrompt, 12, function()
        if saleTransactionInProgress then
            broadcast("A store transaction is saving. Try the supplier partnership again shortly.")
            return
        end
        saleTransactionInProgress = true
        local ok, message = Economy.buySupplierPartnership(state)
        if ok then
            world.setSupplierPartnershipPurchased(state.supplierPartnershipPurchased)
            commit("supplierPartnershipPurchased")
        end
        saleTransactionInProgress = false
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

    joinRequestEvent.OnServerEvent:Connect(function(player, requestedLocationId)
        if requestedLocationId ~= locationId then
            return
        end
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

    layoutRequestEvent.OnServerEvent:Connect(function(player, request, requestedLocationId)
        if requestedLocationId ~= locationId then
            return
        end
        local function reject(message)
            layoutRequestEvent:FireClient(player, {
                action = "Rejected",
                locationId = locationId,
                message = message,
            })
        end

        local now = os.clock()
        local previousRequest = layoutActionTimes[player]
        if previousRequest and now - previousRequest < 0.4 then
            return
        end
        layoutActionTimes[player] = now

        if type(request) ~= "table" or type(request.action) ~= "string" or #request.action > 16 then
            return reject("That layout request is invalid.")
        end
        local allowedKeys
        if request.action == "PlaceShelf" then
            allowedKeys = { action = true, x = true, z = true, rotation = true }
        elseif request.action == "MoveShelf" then
            allowedKeys = { action = true, id = true, x = true, z = true, rotation = true }
        elseif request.action == "RemoveShelf" then
            allowedKeys = { action = true, id = true }
        end
        if not allowedKeys or not hasOnlyKeys(request, allowedKeys) then
            return reject("That layout request is invalid.")
        end

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
        ProfileService.saveProgress(ownerPlayer, state, "layoutChanged", locationId)
        broadcast(message)
        layoutRequestEvent:FireClient(player, {
            action = "Updated",
            locationId = locationId,
            layout = state.warehouseLayout,
            message = message,
        })
    end)

    retailLayoutRequestEvent.OnServerEvent:Connect(function(player, request, requestedLocationId)
        if requestedLocationId ~= locationId then
            return
        end
        local function reject(message)
            retailLayoutRequestEvent:FireClient(player, {
                action = "Rejected",
                locationId = locationId,
                message = message,
            })
        end

        local now = os.clock()
        local previousRequest = retailLayoutActionTimes[player]
        if previousRequest and now - previousRequest < 0.4 then
            return
        end
        retailLayoutActionTimes[player] = now

        if type(request) ~= "table" or type(request.action) ~= "string" or #request.action > 16 then
            return reject("That retail layout request is invalid.")
        end
        local allowedKeys
        if request.action == "MoveShelf" then
            allowedKeys = {
                action = true,
                productId = true,
                x = true,
                z = true,
                rotation = true,
            }
        elseif request.action == "MoveCheckout" or request.action == "BuildAisle" then
            allowedKeys = { action = true, x = true, z = true, rotation = true }
        elseif request.action == "MoveFixture" then
            allowedKeys = {
                action = true,
                fixtureId = true,
                x = true,
                z = true,
                rotation = true,
            }
        elseif request.action == "MoveAisle" then
            allowedKeys = { action = true, id = true, x = true, z = true, rotation = true }
        end
        if not allowedKeys or not hasOnlyKeys(request, allowedKeys) then
            return reject("That retail layout request is invalid.")
        end

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
                request.rotation,
                state.retailLayout.fixtures,
                state.upgradePurchased,
                state.aisleExpansionPurchased,
                state.retailLayout.aisles
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
            local saved =
                ProfileService.saveProgress(ownerPlayer, state, "checkoutLayoutChanged", locationId)
            local resultMessage = saved and "Checkout lane and customer queue moved and saved."
                or "Checkout lane and customer queue moved for this session; the save was not confirmed."
            broadcast(resultMessage)
            retailLayoutRequestEvent:FireClient(player, {
                action = "Updated",
                locationId = locationId,
                layout = state.retailLayout,
                message = resultMessage,
            })
            return
        end

        if request.action == "MoveFixture" then
            local fixtureId = request.fixtureId
            if type(fixtureId) ~= "string" or not RetailLayoutService.isFixtureId(fixtureId) then
                return reject("Choose one of the purchased shelf fixtures.")
            end
            local fixture = state.retailLayout.fixtures[fixtureId]
            if not fixture then
                return reject("Build this fixture before moving it.")
            end
            local valid, reason = RetailLayoutService.canPlaceFixture(
                state.retailLayout,
                fixtureId,
                request.x,
                request.z,
                request.rotation,
                state.bakeryPurchased,
                state.freezerPurchased,
                state.upgradePurchased,
                state.aisleExpansionPurchased,
                fixtureId
            )
            if not valid then
                return reject(reason)
            end
            fixture.x = request.x
            fixture.z = request.z
            fixture.rotation = request.rotation
            world.setRetailLayout(state.retailLayout)
            local saved =
                ProfileService.saveProgress(ownerPlayer, state, "retailLayoutChanged", locationId)
            local resultMessage = saved and "Store fixture moved and saved."
                or "Store fixture moved for this session; the save was not confirmed."
            broadcast(resultMessage)
            retailLayoutRequestEvent:FireClient(player, {
                action = "Updated",
                locationId = locationId,
                layout = state.retailLayout,
                message = resultMessage,
            })
            return
        end

        if request.action == "BuildAisle" then
            local aisleId = HttpService:GenerateGUID(false)
            local ok, resultMessage =
                Economy.buildRetailAisle(state, aisleId, request.x, request.z, request.rotation)
            if not ok then
                return reject(resultMessage)
            end
            world.setRetailLayout(state.retailLayout)
            local saved =
                ProfileService.saveProgress(ownerPlayer, state, "retailAisleBuilt", locationId)
            if not saved then
                resultMessage = resultMessage
                    .. " It is available this session; save confirmation failed."
            end
            broadcast(resultMessage)
            retailLayoutRequestEvent:FireClient(player, {
                action = "Updated",
                locationId = locationId,
                layout = state.retailLayout,
                message = resultMessage,
            })
            return
        elseif request.action == "MoveAisle" then
            local ok, resultMessage =
                Economy.moveRetailAisle(state, request.id, request.x, request.z, request.rotation)
            if not ok then
                return reject(resultMessage)
            end
            world.setRetailLayout(state.retailLayout)
            local saved =
                ProfileService.saveProgress(ownerPlayer, state, "retailAisleMoved", locationId)
            if not saved then
                resultMessage = resultMessage .. " Save confirmation failed."
            else
                resultMessage ..= " Saved."
            end
            broadcast(resultMessage)
            retailLayoutRequestEvent:FireClient(player, {
                action = "Updated",
                locationId = locationId,
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
        local department = state.retailLayout.departments[productId]
        local valid, reason
        if RetailLayoutService.isExpansionProductId(productId) then
            if not department then
                return reject("Build this department before moving it.")
            end
            valid, reason = RetailLayoutService.canPlaceDepartment(
                state.retailLayout,
                productId,
                request.x,
                request.z,
                request.rotation,
                state.floorExpansionPurchased,
                state.bakeryPurchased,
                state.freezerPurchased,
                productId,
                state.upgradePurchased,
                state.aisleExpansionPurchased
            )
            if not valid then
                return reject(reason)
            end
            department.x = request.x
            department.z = request.z
            department.rotation = request.rotation
        else
            if not shelf then
                return reject("Choose one of the installed product department shelves.")
            end
            valid, reason = RetailLayoutService.canPlace(
                state.retailLayout.shelves,
                productId,
                request.x,
                request.z,
                request.rotation,
                state.retailLayout.checkout,
                state.floorExpansionPurchased,
                state.bakeryPurchased,
                state.freezerPurchased,
                state.retailLayout.departments,
                state.retailLayout.fixtures,
                state.upgradePurchased,
                state.aisleExpansionPurchased,
                state.retailLayout.aisles
            )
            if not valid then
                return reject(reason)
            end
            shelf.x = request.x
            shelf.z = request.z
            shelf.rotation = request.rotation
        end
        world.setRetailLayout(state.retailLayout)
        local saved =
            ProfileService.saveProgress(ownerPlayer, state, "retailLayoutChanged", locationId)
        local productName = Economy.PRODUCTS[productId].displayName
        local resultMessage = saved and string.format("%s shelf moved and saved.", productName)
            or string.format(
                "%s shelf moved for this session; the save was not confirmed.",
                productName
            )
        broadcast(resultMessage)
        retailLayoutRequestEvent:FireClient(player, {
            action = "Updated",
            locationId = locationId,
            layout = state.retailLayout,
            message = resultMessage,
        })
    end)

    memberActionEvent.OnServerEvent:Connect(
        function(player, action, targetUserId, role, requestedLocationId)
            if requestedLocationId ~= locationId then
                return
            end
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
        end
    )

    local function claimStore(player)
        if player:GetAttribute("ActiveStoreLocation") == nil then
            player:SetAttribute("ActiveStoreLocation", "neighborhood")
        end
        if ownerPlayer == player then
            return
        end
        if runtimeOptions.ownerUserId and player.UserId ~= runtimeOptions.ownerUserId then
            stateEvent:FireClient(
                player,
                snapshot("This uptown store belongs to its neighborhood owner.", player)
            )
            sendMemberState(player)
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
        if locationId == "neighborhood" and player:GetAttribute("ActiveStoreLocation") == nil then
            player:SetAttribute("ActiveStoreLocation", "neighborhood")
        end
        stateEvent:FireClient(player, snapshot("Loading your saved store…", player))
        task.spawn(function()
            local profile, status
            if locationId == "uptown" then
                profile = ProfileService.get(player)
                status = profile and ProfileService.getSaveStatus(player) or "profile unavailable"
            else
                profile, status = ProfileService.load(player)
            end
            if ownerPlayer ~= player or player.Parent ~= Players then
                if locationId == "neighborhood" then
                    ProfileService.release(player)
                end
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
            local locationProfile = profile
            if locationId == "uptown" then
                locationProfile = ProfileService.getLocation(player, locationId)
                if not locationProfile then
                    ownerPlayer = nil
                    ownerReady = false
                    player:Kick(
                        "Your Uptown Market save could not be opened safely. Please rejoin."
                    )
                    return
                end
                locationProfile.balance = ProfileService.getCompanyBalance(player)
            end
            state = Economy.newState(
                locationProfile,
                player.UserId,
                ProfileService.getCompanyWallet(player)
            )
            if locationId == "neighborhood" then
                TelemetryService.begin(player, profile, state)
            end
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
            world.setSelfCheckoutPurchased(state.selfCheckoutPurchased)
            world.setMarketStyle(state.marketStylePurchased, state.marketStyleId)
            marketStylePreviewing = false
            marketStylePreviewIndex = 0
            world.setWarehousePurchased(state.warehousePurchased)
            if state.bakeryPurchased then
                world.addBakeryDepartment()
            end
            if state.freezerPurchased then
                world.addFreezerDepartment()
            end
            world.setStorageLayout(state.warehouseLayout)
            world.setRetailLayout(state.retailLayout)
            world.setDeliveryState(
                state.shipmentReadyAt,
                state.shipmentQuantity,
                state.shipmentProductId
            )
            world.setOnlineOrderState(Economy.getNextOnlineOrder(state))
            world.setCafeState(state.cafePurchased, state.cafeStock, state.cafeSales)
            world.setRestaurantState(
                state.restaurantPurchased,
                state.restaurantStock,
                state.restaurantSales
            )
            world.setElectronicsStoreState(
                state.electronicsStorePurchased,
                state.electronicsStock,
                state.electronicsSales
            )
            world.setGardenStoreState(
                state.gardenStorePurchased,
                state.gardenStock,
                state.gardenSales
            )
            world.setFloristState(
                state.floristStorePurchased,
                state.floristStock,
                state.floristSales
            )
            world.setBookshopState(
                state.bookshopPurchased,
                state.bookshopStock,
                state.bookshopSales
            )
            world.setPlazaStyle(state.plazaStylePurchased, state.plazaStyleId)
            world.setCashierHired(state.cashierHired)
            world.setStockerHired(state.stockerHired)
            world.setCleanerHired(state.cleanerHired)
            world.setDeliveryWorkerHired(state.deliveryWorkerHired)
            world.setDeliveryFleetPurchased(state.deliveryFleetPurchased)
            world.setDistributionCenterPurchased(state.distributionCenterPurchased)
            world.setSupplierPartnershipPurchased(state.supplierPartnershipPurchased)
            world.setUptownStorePurchased(
                state.uptownStorePurchased,
                state.supplierPartnershipPurchased
            )
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
            world.setFrozenMealStockVisual(state.frozenMealStock)
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
            world.setFrozenMealStockAvailable(
                state.freezerPurchased
                    and state.frozenMealBackstock >= Economy.FROZEN_MEALS_STOCK_PER_RESTOCK
                    and state.frozenMealStock + Economy.FROZEN_MEALS_STOCK_PER_RESTOCK
                        <= Economy.FROZEN_MEALS_SHELF_CAPACITY
            )
            world.setCustomerProduct(
                Economy.PRODUCTS[Economy.getNextCheckoutProductId(state) or "citrusPop"].displayName
            )
            local nextBasket = Economy.getNextCheckoutBasket(state)
            world.setCustomerBasket(
                nextBasket.displayName,
                nextBasket.preferenceName,
                nextBasket.items
            )
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
            if
                locationId == "neighborhood"
                and state.uptownStorePurchased
                and runtimeOptions.onUptownOpened
            then
                runtimeOptions.onUptownOpened(player)
            end
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
            if locationId == "neighborhood" then
                TelemetryService.finish(player)
                ProfileService.release(player)
            end
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

    if locationId == "neighborhood" then
        game:BindToClose(function()
            if ownerPlayer then
                ProfileService.release(ownerPlayer)
            end
            ProfileService.releaseAll()
        end)
    end
end

return ShiftService
