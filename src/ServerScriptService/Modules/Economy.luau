-- Pure first-shift rules. Keep Roblox services and Instances out of this module.
local Economy = {}

Economy.CART_REWARD = 10
Economy.SALE_REWARD = 25
Economy.SHIFT_REWARD = 20
Economy.UPGRADE_COST = 45
Economy.CASHIER_COST = 100
Economy.STOCKER_COST = 80
Economy.CLEANER_COST = 120
Economy.DELIVERY_WORKER_COST = 140
Economy.CUSTOMER_ASSISTANT_COST = 160
Economy.WAREHOUSE_COST = 200
Economy.MARKET_STYLE_COST = 180
Economy.AISLE_EXPANSION_COST = 220
Economy.EMPLOYEE_WAGES = {
    cashier = 4,
    stocker = 4,
    cleaner = 3,
    deliveryWorker = 3,
    customerAssistant = 2,
}
Economy.DELIVERY_COST = 60
Economy.DELIVERY_QUANTITY = 24
Economy.BACKSTOCK_CAPACITY = 500
Economy.STARTING_STOCK = 3
Economy.CITRUS_POP_STOCK_PER_RESTOCK = 3
Economy.CITRUS_POP_SHELF_CAPACITY = 24
Economy.CUSTOMERS_PER_SHIFT = 3
Economy.SPILL_CLEAN_REWARD = 5
Economy.BERRY_BITES_STOCK_PER_RESTOCK = 4
Economy.BERRY_BITES_SHELF_CAPACITY = 24
Economy.GOLDEN_APPLES_STOCK_PER_RESTOCK = 3
Economy.GOLDEN_APPLES_SHELF_CAPACITY = 24
Economy.SUNRISE_CEREAL_STOCK_PER_RESTOCK = 3
Economy.SUNRISE_CEREAL_SHELF_CAPACITY = 24
Economy.POWER_OUTAGE_DURATION = 30
Economy.CUSTOMER_RUSH_DURATION = 60
Economy.CUSTOMER_RUSH_EXTRA_CUSTOMERS = 2
Economy.CUSTOMER_RUSH_REWARD = 20
Economy.MAX_CUSTOMERS_PER_SHIFT = Economy.CUSTOMERS_PER_SHIFT
    + Economy.CUSTOMER_RUSH_EXTRA_CUSTOMERS

Economy.PRODUCTS = {
    citrusPop = {
        displayName = "Citrus Pop",
        salePrice = 25,
        deliveryCost = 60,
        deliveryQuantity = 24,
    },
    berryBites = {
        displayName = "Berry Bites",
        salePrice = 18,
        deliveryCost = 45,
        deliveryQuantity = 24,
    },
    goldenApples = {
        displayName = "Golden Apples",
        salePrice = 12,
        deliveryCost = 35,
        deliveryQuantity = 18,
    },
    sunriseCereal = {
        displayName = "Sunrise Cereal",
        salePrice = 16,
        deliveryCost = 45,
        deliveryQuantity = 18,
    },
}

Economy.CHAOS_EVENTS = {
    CheckoutSpill = {
        id = "checkout_spill",
        eligibility = { stage = "Checkout", triggerSales = 1 },
        triggerSales = 1,
        duration = 0,
        objective = "Clean up the spilled groceries by checkout.",
        reward = Economy.SPILL_CLEAN_REWARD,
        cleanup = "CleanSpill",
        failureRecovery = "WaitForAuthorizedCleanup",
    },
    PowerOutage = {
        id = "power_outage",
        eligibility = { stage = "Checkout", triggerSales = 2 },
        triggerSales = 2,
        duration = Economy.POWER_OUTAGE_DURATION,
        objective = "Restore power at the breaker by checkout.",
        reward = 0,
        cleanup = "RestorePower",
        failureRecovery = "AutoRestoreAfterDeadline",
    },
    CustomerRush = {
        id = "customer_rush",
        eligibility = {
            stage = "Checkout",
            triggerSales = Economy.CUSTOMERS_PER_SHIFT,
            minimumRemainingShelfStock = Economy.CUSTOMER_RUSH_EXTRA_CUSTOMERS,
        },
        triggerSales = Economy.CUSTOMERS_PER_SHIFT,
        extraCustomers = Economy.CUSTOMER_RUSH_EXTRA_CUSTOMERS,
        duration = Economy.CUSTOMER_RUSH_DURATION,
        objective = "Serve the rush customers before time runs out.",
        reward = Economy.CUSTOMER_RUSH_REWARD,
        cleanup = "ServeRushQueue",
        failureRecovery = "EndRushWithoutBonus",
    },
}

function Economy.newState(profile)
    profile = profile or {}
    local savedShift = profile.shift or {}
    local upgrades = profile.ownedUpgrades or {}
    local employeeAutomation = profile.employeeAutomation or {}
    local warehouseInventory = profile.warehouseInventory or {}
    local savedPrices = profile.productPrices or {}
    local shipmentQuantity = warehouseInventory.shipmentQuantity or 0
    return {
        stage = savedShift.stage or "Cart",
        cash = profile.balance or 0,
        stock = savedShift.stock or 0,
        berryStock = savedShift.berryStock or 0,
        goldenAppleStock = savedShift.goldenAppleStock or 0,
        cerealStock = savedShift.cerealStock or 0,
        sales = savedShift.sales or 0,
        cartRecovered = savedShift.cartRecovered or false,
        shiftClosed = savedShift.shiftClosed or false,
        powerOutageUntil = savedShift.powerOutageUntil or 0,
        customerRushUntil = savedShift.customerRushUntil or 0,
        upgradePurchased = upgrades.shelfBay or false,
        warehousePurchased = upgrades.warehouse or false,
        marketStylePurchased = upgrades.marketStyle or false,
        aisleExpansionPurchased = upgrades.aisleExpansion or false,
        cashierHired = (profile.hiredEmployees and profile.hiredEmployees.cashier) or false,
        stockerHired = (profile.hiredEmployees and profile.hiredEmployees.stocker) or false,
        cleanerHired = (profile.hiredEmployees and profile.hiredEmployees.cleaner) or false,
        deliveryWorkerHired = (profile.hiredEmployees and profile.hiredEmployees.deliveryWorker)
            or false,
        customerAssistantHired = (
            profile.hiredEmployees and profile.hiredEmployees.customerAssistant
        ) or false,
        cashierAutomationEnabled = employeeAutomation.cashier ~= false,
        stockerAutomationEnabled = employeeAutomation.stocker ~= false,
        cleanerAutomationEnabled = employeeAutomation.cleaner ~= false,
        deliveryWorkerAutomationEnabled = employeeAutomation.deliveryWorker ~= false,
        backstock = warehouseInventory.citrusPop or 12,
        berryBackstock = warehouseInventory.berryBites or (upgrades.warehouse and 12 or 0),
        goldenAppleBackstock = warehouseInventory.goldenApples or (upgrades.warehouse and 6 or 0),
        cerealBackstock = warehouseInventory.sunriseCereal or (upgrades.warehouse and 6 or 0),
        productPrices = {
            citrusPop = savedPrices.citrusPop or Economy.PRODUCTS.citrusPop.salePrice,
            berryBites = savedPrices.berryBites or Economy.PRODUCTS.berryBites.salePrice,
            goldenApples = savedPrices.goldenApples or Economy.PRODUCTS.goldenApples.salePrice,
            sunriseCereal = savedPrices.sunriseCereal or Economy.PRODUCTS.sunriseCereal.salePrice,
        },
        shipmentReadyAt = warehouseInventory.shipmentReadyAt or 0,
        shipmentQuantity = shipmentQuantity,
        shipmentProductId = shipmentQuantity > 0
                and (Economy.PRODUCTS[warehouseInventory.shipmentProductId] and warehouseInventory.shipmentProductId or "citrusPop")
            or "",
    }
end

function Economy.getProductPrice(state, productId)
    local product = Economy.PRODUCTS[productId]
    if not product then
        return nil
    end
    return (state.productPrices and state.productPrices[productId]) or product.salePrice
end

function Economy.getShiftPayroll(state)
    local total = 0
    for employeeId, wage in pairs(Economy.EMPLOYEE_WAGES) do
        if state[employeeId .. "Hired"] then
            total += wage
        end
    end
    return total
end

function Economy.cycleProductPrice(state, productId)
    local product = Economy.PRODUCTS[productId]
    if not product then
        return false, "That product is not in the store catalog."
    end
    if state.stage == "Loading" or state.stage == "OwnerOffline" then
        return false, "Wait until the store is ready before changing prices."
    end
    local lowPrice = math.max(1, math.floor(product.salePrice * 0.8))
    local highPrice = math.ceil(product.salePrice * 1.25)
    local options = { lowPrice, product.salePrice, highPrice }
    local currentPrice = Economy.getProductPrice(state, productId)
    local currentIndex = 2
    for index, option in ipairs(options) do
        if option == currentPrice then
            currentIndex = index
            break
        end
    end
    local nextPrice = options[(currentIndex % #options) + 1]
    state.productPrices = state.productPrices or {}
    state.productPrices[productId] = nextPrice
    return true, string.format("%s now costs $%d.", product.displayName, nextPrice), nextPrice
end

function Economy.getCustomerTarget(state)
    if (state.customerRushUntil or 0) > 0 then
        return Economy.MAX_CUSTOMERS_PER_SHIFT
    end
    return Economy.CUSTOMERS_PER_SHIFT
end

function Economy.getRemainingCustomers(state)
    return math.max(0, Economy.getCustomerTarget(state) - state.sales)
end

function Economy.canRecoverCart(state)
    return state.stage == "Cart" and not state.cartRecovered
end

function Economy.recoverCart(state)
    if not Economy.canRecoverCart(state) then
        return false, "The cart is already safe."
    end
    state.cartRecovered = true
    state.cash += Economy.CART_REWARD
    state.stage = "Stock"
    return true, "Cart recovered! +$10. Stock Citrus Pop for the waiting customer."
end

function Economy.stockProduct(state)
    local firstRestock = state.stage == "Stock"
    if not firstRestock and state.stage ~= "Checkout" and state.stage ~= "CustomerRush" then
        return false, "Citrus Pop cannot be restocked during this stage."
    end
    if state.backstock < Economy.CITRUS_POP_STOCK_PER_RESTOCK then
        return false, "The backroom is out of Citrus Pop. Order a delivery from the warehouse."
    end
    if state.stock + Economy.CITRUS_POP_STOCK_PER_RESTOCK > Economy.CITRUS_POP_SHELF_CAPACITY then
        return false, "The Citrus Pop shelf is full."
    end
    state.backstock -= Economy.CITRUS_POP_STOCK_PER_RESTOCK
    state.stock += Economy.CITRUS_POP_STOCK_PER_RESTOCK
    if firstRestock then
        state.stage = "Checkout"
        return true, "Citrus Pop stocked. A customer is ready at checkout."
    end
    return true, "Citrus Pop restocked from the warehouse."
end

function Economy.stockBerryBites(state)
    if
        state.stage == "Cart"
        or state.stage == "Upgrade"
        or state.stage == "Loading"
        or state.stage == "OwnerOffline"
        or state.stage == "PowerOutage"
        or state.stage == "Spill"
        or state.stage == "CloseShift"
        or state.stage == "Complete"
    then
        return false, "Wait until store operations are underway before restocking Berry Bites."
    end
    if not state.warehousePurchased then
        return false, "Unlock the warehouse before restocking Berry Bites."
    end
    if state.berryBackstock < Economy.BERRY_BITES_STOCK_PER_RESTOCK then
        return false, "The backroom is out of Berry Bites. Order a delivery from the warehouse."
    end
    if
        state.berryStock + Economy.BERRY_BITES_STOCK_PER_RESTOCK
        > Economy.BERRY_BITES_SHELF_CAPACITY
    then
        return false, "The Berry Bites shelf is full."
    end
    state.berryBackstock -= Economy.BERRY_BITES_STOCK_PER_RESTOCK
    state.berryStock += Economy.BERRY_BITES_STOCK_PER_RESTOCK
    return true, "Berry Bites restocked from the warehouse."
end

function Economy.stockGoldenApples(state)
    if
        state.stage == "Cart"
        or state.stage == "Upgrade"
        or state.stage == "Loading"
        or state.stage == "OwnerOffline"
        or state.stage == "PowerOutage"
        or state.stage == "Spill"
        or state.stage == "CloseShift"
        or state.stage == "Complete"
    then
        return false, "Wait until store operations are underway before restocking Golden Apples."
    end
    if not state.warehousePurchased then
        return false, "Unlock the warehouse before restocking Golden Apples."
    end
    if state.goldenAppleBackstock < Economy.GOLDEN_APPLES_STOCK_PER_RESTOCK then
        return false, "The backroom is out of Golden Apples. Order a delivery from the warehouse."
    end
    if
        state.goldenAppleStock + Economy.GOLDEN_APPLES_STOCK_PER_RESTOCK
        > Economy.GOLDEN_APPLES_SHELF_CAPACITY
    then
        return false, "The Golden Apples display is full."
    end
    state.goldenAppleBackstock -= Economy.GOLDEN_APPLES_STOCK_PER_RESTOCK
    state.goldenAppleStock += Economy.GOLDEN_APPLES_STOCK_PER_RESTOCK
    return true, "Golden Apples restocked from the warehouse."
end

function Economy.stockSunriseCereal(state)
    if
        state.stage == "Cart"
        or state.stage == "Upgrade"
        or state.stage == "Loading"
        or state.stage == "OwnerOffline"
        or state.stage == "PowerOutage"
        or state.stage == "Spill"
        or state.stage == "CloseShift"
        or state.stage == "Complete"
    then
        return false, "Wait until store operations are underway before restocking Sunrise Cereal."
    end
    if not state.warehousePurchased then
        return false, "Unlock the warehouse before restocking Sunrise Cereal."
    end
    if state.cerealBackstock < Economy.SUNRISE_CEREAL_STOCK_PER_RESTOCK then
        return false, "The backroom is out of Sunrise Cereal. Order a delivery from the warehouse."
    end
    if
        state.cerealStock + Economy.SUNRISE_CEREAL_STOCK_PER_RESTOCK
        > Economy.SUNRISE_CEREAL_SHELF_CAPACITY
    then
        return false, "The Sunrise Cereal shelf is full."
    end
    state.cerealBackstock -= Economy.SUNRISE_CEREAL_STOCK_PER_RESTOCK
    state.cerealStock += Economy.SUNRISE_CEREAL_STOCK_PER_RESTOCK
    return true, "Sunrise Cereal restocked from the warehouse."
end

function Economy.orderDelivery(state, now, productId)
    productId = productId or "citrusPop"
    local product = Economy.PRODUCTS[productId]
    if not product then
        return false, "That product is not in the warehouse catalog."
    end
    if not state.warehousePurchased then
        return false, "Unlock the warehouse before ordering stock."
    end
    if state.shipmentQuantity > 0 or state.shipmentReadyAt > 0 then
        return false, "A delivery is already on the way."
    end
    local currentBackstock = productId == "citrusPop" and state.backstock
        or (
            productId == "berryBites" and state.berryBackstock
            or (productId == "goldenApples" and state.goldenAppleBackstock or state.cerealBackstock)
        )
    if currentBackstock + product.deliveryQuantity > Economy.BACKSTOCK_CAPACITY then
        return false, "There is not enough backroom space for another delivery."
    end
    if state.cash < product.deliveryCost then
        return false,
            string.format("You need $%d to order %s.", product.deliveryCost, product.displayName)
    end
    if type(now) ~= "number" or now ~= now or now % 1 ~= 0 or now < 1 then
        return false, "The delivery time could not be confirmed. Try again."
    end
    state.cash -= product.deliveryCost
    state.shipmentQuantity = product.deliveryQuantity
    state.shipmentReadyAt = now + 15
    state.shipmentProductId = productId
    return true,
        string.format(
            "%s delivery ordered for $%d. It will arrive shortly.",
            product.displayName,
            product.deliveryCost
        )
end

function Economy.receiveDelivery(state, now)
    if state.shipmentQuantity <= 0 or state.shipmentReadyAt <= 0 then
        return false, "There is no delivery waiting at the loading dock."
    end
    if type(now) ~= "number" or now ~= now or now % 1 ~= 0 or now < state.shipmentReadyAt then
        return false, "The delivery is still on its way."
    end
    local productId = state.shipmentProductId == "goldenApples" and "goldenApples"
        or (
            state.shipmentProductId == "sunriseCereal" and "sunriseCereal"
            or (state.shipmentProductId == "berryBites" and "berryBites" or "citrusPop")
        )
    local currentBackstock = productId == "citrusPop" and state.backstock
        or (
            productId == "berryBites" and state.berryBackstock
            or (productId == "goldenApples" and state.goldenAppleBackstock or state.cerealBackstock)
        )
    if currentBackstock + state.shipmentQuantity > Economy.BACKSTOCK_CAPACITY then
        return false, "The backroom is full. Clear space before receiving this delivery."
    end
    local quantity = state.shipmentQuantity
    if productId == "citrusPop" then
        state.backstock += quantity
    elseif productId == "berryBites" then
        state.berryBackstock += quantity
    elseif productId == "goldenApples" then
        state.goldenAppleBackstock += quantity
    else
        state.cerealBackstock += quantity
    end
    state.shipmentQuantity = 0
    state.shipmentReadyAt = 0
    state.shipmentProductId = ""
    return true,
        string.format(
            "Delivery received: %d %s added to backroom stock.",
            quantity,
            Economy.PRODUCTS[productId].displayName
        )
end

function Economy.getNextCheckoutProductId(state)
    local basket = Economy.getNextCheckoutBasket(state)
    return basket and basket.items[1] and basket.items[1].productId or nil
end

-- Basket intent is derived from the next customer number. The server resolves it
-- against current shelf stock, so a rejoin or a depleted preferred SKU is safe.
function Economy.getNextCheckoutBasket(state)
    local customerNumber = state.sales + 1
    local intents = {
        { "citrusPop" },
        { "berryBites" },
        { "citrusPop", "sunriseCereal" },
        { "goldenApples" },
        { "berryBites", "berryBites" },
    }
    local intent = intents[((customerNumber - 1) % #intents) + 1]
    local available = {
        citrusPop = math.max(0, math.floor(state.stock or 0)),
        berryBites = math.max(0, math.floor(state.berryStock or 0)),
        goldenApples = math.max(0, math.floor(state.goldenAppleStock or 0)),
        sunriseCereal = math.max(0, math.floor(state.cerealStock or 0)),
    }
    local items = {}
    local counts = {}
    local fulfilledCount = 0

    for _, productId in ipairs(intent) do
        if available[productId] > 0 then
            available[productId] -= 1
            counts[productId] = (counts[productId] or 0) + 1
            fulfilledCount += 1
        end
    end

    -- A customer always has a fulfillable one-item basket when any shelf is stocked.
    if fulfilledCount == 0 then
        local fallbackId = state.stock > 0 and "citrusPop"
            or (state.berryStock > 0 and "berryBites" or nil)
            or (state.goldenAppleStock > 0 and "goldenApples" or nil)
            or (state.cerealStock > 0 and "sunriseCereal" or nil)
        if fallbackId then
            counts[fallbackId] = 1
        end
    end

    local productTypeCount = 0
    local singleProductId
    for productId in pairs(counts) do
        productTypeCount += 1
        singleProductId = productId
    end
    if productTypeCount == 1 then
        local product = Economy.PRODUCTS[singleProductId]
        local currentPrice = Economy.getProductPrice(state, singleProductId)
        if
            currentPrice < product.salePrice
            and counts[singleProductId] == 1
            and available[singleProductId] > 0
        then
            counts[singleProductId] += 1
            available[singleProductId] -= 1
        end
    end
    for productId, quantity in pairs(counts) do
        local product = Economy.PRODUCTS[productId]
        if Economy.getProductPrice(state, productId) > product.salePrice and quantity > 1 then
            counts[productId] -= 1
        end
    end

    for productId, quantity in pairs(counts) do
        table.insert(items, {
            productId = productId,
            quantity = quantity,
            displayName = Economy.PRODUCTS[productId].displayName,
            unitPrice = Economy.getProductPrice(state, productId),
        })
    end
    table.sort(items, function(left, right)
        return left.productId < right.productId
    end)

    local total = 0
    local labels = {}
    for _, item in ipairs(items) do
        total += item.quantity * item.unitPrice
        table.insert(labels, string.format("%s x%d", item.displayName, item.quantity))
    end
    local preferredProductIds = {}
    for _, productId in ipairs(intent) do
        table.insert(preferredProductIds, productId)
    end
    return {
        items = items,
        total = total,
        displayName = #labels > 0 and table.concat(labels, " + ") or "No shelf stock",
        preferredProductIds = preferredProductIds,
    }
end

function Economy.stockNextRequestedProduct(state)
    if state.stage ~= "Checkout" and state.stage ~= "CustomerRush" then
        return false, "The stock clerk is waiting for active checkout."
    end
    local basket = Economy.getNextCheckoutBasket(state)
    local shelfByProduct = {
        citrusPop = state.stock,
        berryBites = state.berryStock,
        goldenApples = state.goldenAppleStock,
        sunriseCereal = state.cerealStock,
    }
    local backstockByProduct = {
        citrusPop = state.backstock,
        berryBites = state.berryBackstock,
        goldenApples = state.goldenAppleBackstock,
        sunriseCereal = state.cerealBackstock,
    }
    local restockByProduct = {
        citrusPop = Economy.CITRUS_POP_STOCK_PER_RESTOCK,
        berryBites = Economy.BERRY_BITES_STOCK_PER_RESTOCK,
        goldenApples = Economy.GOLDEN_APPLES_STOCK_PER_RESTOCK,
        sunriseCereal = Economy.SUNRISE_CEREAL_STOCK_PER_RESTOCK,
    }
    local stockActionByProduct = {
        citrusPop = Economy.stockProduct,
        berryBites = Economy.stockBerryBites,
        goldenApples = Economy.stockGoldenApples,
        sunriseCereal = Economy.stockSunriseCereal,
    }
    for _, productId in ipairs(basket.preferredProductIds) do
        if
            shelfByProduct[productId] == 0
            and backstockByProduct[productId] >= restockByProduct[productId]
        then
            local ok, message = stockActionByProduct[productId](state)
            if ok then
                return true, message, productId
            end
        end
    end
    return false, "The stock clerk found no preferred empty shelf with enough backroom stock."
end

function Economy.sellProduct(state, now)
    if state.stage ~= "Checkout" and state.stage ~= "CustomerRush" then
        return false, "The checkout is waiting for the next customer."
    end
    local target = Economy.getCustomerTarget(state)
    if state.sales >= target then
        return false, "The checkout queue is already clear."
    end
    if
        state.stage == "CustomerRush"
        and (type(now) ~= "number" or now ~= now or now % 1 ~= 0 or now >= state.customerRushUntil)
    then
        return false, "The customer rush has ended. Finish the shift at the board."
    end
    local basket = Economy.getNextCheckoutBasket(state)
    if #basket.items == 0 then
        return false, "The shelves are empty. Restock a product before serving this customer."
    end
    if
        (
            state.sales + 1 == Economy.CHAOS_EVENTS.PowerOutage.triggerSales
            or (
                state.customerRushUntil == 0
                and state.sales + 1 == Economy.CHAOS_EVENTS.CustomerRush.triggerSales
            )
        ) and (type(now) ~= "number" or now ~= now or now % 1 ~= 0 or now < 1)
    then
        return false, "The event time could not be confirmed. Try again."
    end
    for _, item in ipairs(basket.items) do
        if item.productId == "citrusPop" then
            state.stock -= item.quantity
        elseif item.productId == "berryBites" then
            state.berryStock -= item.quantity
        elseif item.productId == "goldenApples" then
            state.goldenAppleStock -= item.quantity
        else
            state.cerealStock -= item.quantity
        end
    end
    state.sales += 1
    state.cash += basket.total
    if state.sales == Economy.CHAOS_EVENTS.CheckoutSpill.triggerSales then
        state.stage = "Spill"
        return true,
            string.format(
                "Basket complete! +$%d for %s. A customer dropped groceries—clean up the spill!",
                basket.total,
                basket.displayName
            )
    end
    if state.sales == Economy.CHAOS_EVENTS.PowerOutage.triggerSales then
        state.powerOutageUntil = now + Economy.CHAOS_EVENTS.PowerOutage.duration
        state.stage = "PowerOutage"
        return true,
            string.format(
                "Basket complete! +$%d for %s. The power is out—restore it at the breaker!",
                basket.total,
                basket.displayName
            )
    end
    if
        state.sales == Economy.CHAOS_EVENTS.CustomerRush.triggerSales
        and state.customerRushUntil == 0
        and state.stock + state.berryStock + state.goldenAppleStock + state.cerealStock
            >= Economy.CUSTOMER_RUSH_EXTRA_CUSTOMERS
    then
        state.customerRushUntil = now + Economy.CHAOS_EVENTS.CustomerRush.duration
        state.stage = "CustomerRush"
        return true,
            string.format(
                "Basket complete! +$%d for %s. Customer rush! Serve %d more shoppers within 60 seconds.",
                basket.total,
                basket.displayName,
                Economy.CUSTOMER_RUSH_EXTRA_CUSTOMERS
            )
    end
    if state.customerRushUntil > 0 and state.sales >= Economy.MAX_CUSTOMERS_PER_SHIFT then
        state.cash += Economy.CUSTOMER_RUSH_REWARD
        state.customerRushUntil = 0
        state.stage = "CloseShift"
        return true,
            string.format(
                "Rush cleared! +$%d bonus. All customers served; close out your shift.",
                Economy.CUSTOMER_RUSH_REWARD
            )
    end
    if state.customerRushUntil == 0 and state.sales >= Economy.CUSTOMERS_PER_SHIFT then
        state.stage = "CloseShift"
        return true,
            string.format(
                "Basket complete! +$%d for %s. All customers served. Close out your shift.",
                basket.total,
                basket.displayName
            )
    end
    return true,
        string.format(
            "Basket complete! +$%d for %s. %d customers remain in the queue.",
            basket.total,
            basket.displayName,
            Economy.getCustomerTarget(state) - state.sales
        )
end

function Economy.expireCustomerRush(state, now)
    if state.stage ~= "CustomerRush" or state.customerRushUntil <= 0 then
        return false, "There is no active customer rush."
    end
    if type(now) ~= "number" or now ~= now or now % 1 ~= 0 or now < state.customerRushUntil then
        return false, "The customer rush is still active."
    end
    state.customerRushUntil = 0
    state.stage = "CloseShift"
    return true, "The rush is over. Finish the shift at the board; no bonus was earned."
end

function Economy.cleanSpill(state)
    if state.stage ~= "Spill" then
        return false, "There is no spill to clean up right now."
    end
    state.cash += Economy.CHAOS_EVENTS.CheckoutSpill.reward
    state.stage = "Checkout"
    return true, "Aisle clear! +$5. The checkout queue is moving again."
end

function Economy.restorePower(state)
    if state.stage ~= "PowerOutage" then
        return false, "The store power is already on."
    end
    state.powerOutageUntil = 0
    state.customerRushUntil = 0
    state.stage = "Checkout"
    return true, "Power restored. The checkout queue is moving again."
end

function Economy.recoverPower(state, now)
    if state.stage ~= "PowerOutage" or state.powerOutageUntil <= 0 then
        return false, "There is no power outage to recover."
    end
    if type(now) ~= "number" or now ~= now or now % 1 ~= 0 or now < state.powerOutageUntil then
        return false, "The outage recovery timer is still active."
    end
    state.powerOutageUntil = 0
    state.stage = "Checkout"
    return true, "Backup power restored. The checkout queue is moving again."
end

function Economy.closeShift(state)
    if state.stage ~= "CloseShift" or state.shiftClosed then
        return false, "Serve the waiting customer before closing."
    end
    state.shiftClosed = true
    state.cash += Economy.SHIFT_REWARD
    local payroll = Economy.getShiftPayroll(state)
    state.cash -= payroll
    local netReward = Economy.SHIFT_REWARD - payroll
    local closeMessage
    if payroll > 0 then
        closeMessage = string.format(
            "Shift complete! +$%d bonus, -$%d staff payroll (net +$%d).",
            Economy.SHIFT_REWARD,
            payroll,
            netReward
        )
    else
        closeMessage = state.upgradePurchased and "Shift complete! +$20."
            or "First shift complete! +$20."
    end
    if state.upgradePurchased then
        state.stage = "Complete"
        return true, closeMessage .. " Your store is ready for another shift."
    end
    state.stage = "Upgrade"
    return true, closeMessage .. " Add a shelf bay to grow the store."
end

function Economy.restartShift(state)
    if state.stage ~= "Complete" then
        return false, "Finish this shift before starting another."
    end
    state.stage = "Cart"
    state.stock = 0
    state.berryStock = 0
    state.goldenAppleStock = 0
    state.cerealStock = 0
    state.powerOutageUntil = 0
    state.sales = 0
    state.cartRecovered = false
    state.shiftClosed = false
    return true, "New shift started. Stop the runaway cart near the entrance."
end

function Economy.buyUpgrade(state)
    if state.stage ~= "Upgrade" or state.upgradePurchased then
        return false, "That store upgrade is not available yet."
    end
    if state.cash < Economy.UPGRADE_COST then
        return false, "You need $45 to add the new shelf bay."
    end
    state.cash -= Economy.UPGRADE_COST
    state.upgradePurchased = true
    state.stage = "Complete"
    return true, "New shelf bay installed! Your store is growing."
end

function Economy.hireCashier(state)
    if state.stage ~= "Complete" or state.cashierHired then
        return false, "The cashier position is not available right now."
    end
    if state.cash < Economy.CASHIER_COST then
        return false, string.format("You need $%d to hire a cashier.", Economy.CASHIER_COST)
    end
    state.cash -= Economy.CASHIER_COST
    state.cashierHired = true
    state.cashierAutomationEnabled = true
    return true, "Cashier hired! They will serve stocked customers automatically."
end

function Economy.hireStocker(state)
    if state.stage ~= "Complete" or state.stockerHired then
        return false, "The stocker position is not available right now."
    end
    if state.cash < Economy.STOCKER_COST then
        return false, string.format("You need $%d to hire a stock clerk.", Economy.STOCKER_COST)
    end
    state.cash -= Economy.STOCKER_COST
    state.stockerHired = true
    state.stockerAutomationEnabled = true
    return true, "Stock clerk hired! They will restock Citrus Pop automatically."
end

function Economy.hireCleaner(state)
    if state.stage ~= "Complete" or state.cleanerHired then
        return false, "The cleaner position is not available right now."
    end
    if state.cash < Economy.CLEANER_COST then
        return false, string.format("You need $%d to hire a cleaner.", Economy.CLEANER_COST)
    end
    state.cash -= Economy.CLEANER_COST
    state.cleanerHired = true
    state.cleanerAutomationEnabled = true
    return true, "Cleaner hired! They will handle checkout spills automatically."
end

function Economy.hireDeliveryWorker(state)
    if state.stage ~= "Complete" or not state.warehousePurchased or state.deliveryWorkerHired then
        return false, "The delivery worker is only available after a shift with a warehouse."
    end
    if state.cash < Economy.DELIVERY_WORKER_COST then
        return false,
            string.format("You need $%d to hire a delivery worker.", Economy.DELIVERY_WORKER_COST)
    end
    state.cash -= Economy.DELIVERY_WORKER_COST
    state.deliveryWorkerHired = true
    state.deliveryWorkerAutomationEnabled = true
    return true, "Delivery worker hired! They will receive arrived shipments automatically."
end

function Economy.hireCustomerAssistant(state)
    if state.stage ~= "Complete" or state.customerAssistantHired then
        return false, "The customer assistant is only available after a completed shift."
    end
    if state.cash < Economy.CUSTOMER_ASSISTANT_COST then
        return false,
            string.format(
                "You need $%d to hire a customer assistant.",
                Economy.CUSTOMER_ASSISTANT_COST
            )
    end
    state.cash -= Economy.CUSTOMER_ASSISTANT_COST
    state.customerAssistantHired = true
    return true, "Customer assistant hired! Shoppers will move through the store faster."
end

function Economy.toggleEmployeeAutomation(state, employeeId)
    local employees = {
        cashier = {
            hiredField = "cashierHired",
            enabledField = "cashierAutomationEnabled",
            name = "Cashier",
        },
        stocker = {
            hiredField = "stockerHired",
            enabledField = "stockerAutomationEnabled",
            name = "Stock clerk",
        },
        cleaner = {
            hiredField = "cleanerHired",
            enabledField = "cleanerAutomationEnabled",
            name = "Cleaner",
        },
        deliveryWorker = {
            hiredField = "deliveryWorkerHired",
            enabledField = "deliveryWorkerAutomationEnabled",
            name = "Delivery worker",
        },
    }
    local employee = employees[employeeId]
    if not employee or not state[employee.hiredField] then
        return false, "Hire this employee before changing its automation."
    end
    state[employee.enabledField] = not state[employee.enabledField]
    local status = state[employee.enabledField] and "resumed" or "paused"
    return true, string.format("%s automation %s.", employee.name, status)
end

function Economy.buyWarehouse(state)
    if state.stage ~= "Complete" or state.warehousePurchased then
        return false, "The warehouse expansion is not available right now."
    end
    if state.cash < Economy.WAREHOUSE_COST then
        return false,
            string.format("You need $%d to expand into the warehouse.", Economy.WAREHOUSE_COST)
    end
    state.cash -= Economy.WAREHOUSE_COST
    state.warehousePurchased = true
    if state.berryBackstock == 0 then
        state.berryBackstock = 12
    end
    if state.goldenAppleBackstock == 0 then
        state.goldenAppleBackstock = 6
    end
    if state.cerealBackstock == 0 then
        state.cerealBackstock = 6
    end
    return true, "Warehouse annex purchased! Your retail empire is expanding."
end

function Economy.buyMarketStyle(state)
    if state.stage ~= "Complete" or state.marketStylePurchased then
        return false, "The storefront style package is not available right now."
    end
    if state.cash < Economy.MARKET_STYLE_COST then
        return false,
            string.format("You need $%d to refresh the storefront.", Economy.MARKET_STYLE_COST)
    end
    state.cash -= Economy.MARKET_STYLE_COST
    state.marketStylePurchased = true
    return true, "Coastal Market style installed! Your storefront has a fresh new look."
end

function Economy.buyAisleExpansion(state)
    if state.stage ~= "Complete" or not state.upgradePurchased or state.aisleExpansionPurchased then
        return false, "The second aisle expansion is not available right now."
    end
    if state.cash < Economy.AISLE_EXPANSION_COST then
        return false,
            string.format("You need $%d to add the household aisle.", Economy.AISLE_EXPANSION_COST)
    end
    state.cash -= Economy.AISLE_EXPANSION_COST
    state.aisleExpansionPurchased = true
    return true, "Household aisle added! Your store has room for more shoppers."
end

return Economy
