-- Pure first-shift rules. Keep Roblox services and Instances out of this module.
local Economy = {}

Economy.CART_REWARD = 10
Economy.SALE_REWARD = 25
Economy.SHIFT_REWARD = 20
Economy.UPGRADE_COST = 45
Economy.CASHIER_COST = 100
Economy.STOCKER_COST = 80
Economy.CLEANER_COST = 120
Economy.WAREHOUSE_COST = 200
Economy.DELIVERY_COST = 60
Economy.DELIVERY_QUANTITY = 24
Economy.BACKSTOCK_CAPACITY = 500
Economy.STARTING_STOCK = 3
Economy.CUSTOMERS_PER_SHIFT = 3
Economy.SPILL_CLEAN_REWARD = 5
Economy.BERRY_BITES_STOCK_PER_RESTOCK = 4
Economy.BERRY_BITES_SHELF_CAPACITY = 24
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
    local warehouseInventory = profile.warehouseInventory or {}
    local shipmentQuantity = warehouseInventory.shipmentQuantity or 0
    return {
        stage = savedShift.stage or "Cart",
        cash = profile.balance or 0,
        stock = savedShift.stock or 0,
        berryStock = savedShift.berryStock or 0,
        sales = savedShift.sales or 0,
        cartRecovered = savedShift.cartRecovered or false,
        shiftClosed = savedShift.shiftClosed or false,
        powerOutageUntil = savedShift.powerOutageUntil or 0,
        customerRushUntil = savedShift.customerRushUntil or 0,
        upgradePurchased = upgrades.shelfBay or false,
        warehousePurchased = upgrades.warehouse or false,
        cashierHired = (profile.hiredEmployees and profile.hiredEmployees.cashier) or false,
        stockerHired = (profile.hiredEmployees and profile.hiredEmployees.stocker) or false,
        cleanerHired = (profile.hiredEmployees and profile.hiredEmployees.cleaner) or false,
        backstock = warehouseInventory.citrusPop or 12,
        berryBackstock = warehouseInventory.berryBites or (upgrades.warehouse and 12 or 0),
        shipmentReadyAt = warehouseInventory.shipmentReadyAt or 0,
        shipmentQuantity = shipmentQuantity,
        shipmentProductId = warehouseInventory.shipmentProductId == "berryBites" and "berryBites"
            or (shipmentQuantity > 0 and "citrusPop" or ""),
    }
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
    if state.stage ~= "Stock" then
        return false, "Finish the current objective first."
    end
    if state.backstock < Economy.STARTING_STOCK then
        return false, "The backroom is out of Citrus Pop. Order a delivery from the warehouse."
    end
    state.backstock -= Economy.STARTING_STOCK
    state.stock += Economy.STARTING_STOCK
    state.stage = "Checkout"
    return true, "Citrus Pop stocked. A customer is ready at checkout."
end

function Economy.stockBerryBites(state)
    if
        state.stage == "Cart"
        or state.stage == "Upgrade"
        or state.stage == "Loading"
        or state.stage == "OwnerOffline"
        or state.stage == "PowerOutage"
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
    local currentBackstock = productId == "citrusPop" and state.backstock or state.berryBackstock
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
    local productId = state.shipmentProductId == "berryBites" and "berryBites" or "citrusPop"
    local currentBackstock = productId == "citrusPop" and state.backstock or state.berryBackstock
    if currentBackstock + state.shipmentQuantity > Economy.BACKSTOCK_CAPACITY then
        return false, "The backroom is full. Clear space before receiving this delivery."
    end
    local quantity = state.shipmentQuantity
    if productId == "citrusPop" then
        state.backstock += quantity
    else
        state.berryBackstock += quantity
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
    return basket and basket.items[1].productId or nil
end

-- Basket intent is derived from the next customer number. The server resolves it
-- against current shelf stock, so a rejoin or a depleted preferred SKU is safe.
function Economy.getNextCheckoutBasket(state)
    local customerNumber = state.sales + 1
    local intents = {
        { "citrusPop" },
        { "berryBites" },
        { "citrusPop", "berryBites" },
        { "berryBites", "berryBites" },
        { "citrusPop", "citrusPop" },
    }
    local intent = intents[((customerNumber - 1) % #intents) + 1]
    local available = {
        citrusPop = math.max(0, math.floor(state.stock or 0)),
        berryBites = math.max(0, math.floor(state.berryStock or 0)),
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
        if fallbackId then
            counts[fallbackId] = 1
        end
    end

    for productId, quantity in pairs(counts) do
        table.insert(items, {
            productId = productId,
            quantity = quantity,
            displayName = Economy.PRODUCTS[productId].displayName,
            unitPrice = Economy.PRODUCTS[productId].salePrice,
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
    return {
        items = items,
        total = total,
        displayName = #labels > 0 and table.concat(labels, " + ") or "No shelf stock",
    }
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
        else
            state.berryStock -= item.quantity
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
        and state.stock + state.berryStock >= Economy.CUSTOMER_RUSH_EXTRA_CUSTOMERS
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
    if state.upgradePurchased then
        state.stage = "Complete"
        return true, "Shift complete! +$20. Your store is ready for another shift."
    end
    state.stage = "Upgrade"
    return true, "First shift complete! +$20. Add a shelf bay to grow the store."
end

function Economy.restartShift(state)
    if state.stage ~= "Complete" then
        return false, "Finish this shift before starting another."
    end
    state.stage = "Cart"
    state.stock = 0
    state.berryStock = 0
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
    return true, "Cleaner hired! They will handle checkout spills automatically."
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
    return true, "Warehouse annex purchased! Your retail empire is expanding."
end

return Economy
