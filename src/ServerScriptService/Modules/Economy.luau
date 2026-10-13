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

Economy.CHAOS_EVENTS = {
    CheckoutSpill = {
        id = "checkout_spill",
        triggerSales = 1,
        objective = "Clean up the spilled groceries by checkout.",
        reward = Economy.SPILL_CLEAN_REWARD,
    },
}

function Economy.newState(profile)
    profile = profile or {}
    local savedShift = profile.shift or {}
    local upgrades = profile.ownedUpgrades or {}
    local warehouseInventory = profile.warehouseInventory or {}
    return {
        stage = savedShift.stage or "Cart",
        cash = profile.balance or 0,
        stock = savedShift.stock or 0,
        sales = savedShift.sales or 0,
        cartRecovered = savedShift.cartRecovered or false,
        shiftClosed = savedShift.shiftClosed or false,
        upgradePurchased = upgrades.shelfBay or false,
        warehousePurchased = upgrades.warehouse or false,
        cashierHired = (profile.hiredEmployees and profile.hiredEmployees.cashier) or false,
        stockerHired = (profile.hiredEmployees and profile.hiredEmployees.stocker) or false,
        cleanerHired = (profile.hiredEmployees and profile.hiredEmployees.cleaner) or false,
        backstock = warehouseInventory.citrusPop or 12,
        shipmentReadyAt = warehouseInventory.shipmentReadyAt or 0,
        shipmentQuantity = warehouseInventory.shipmentQuantity or 0,
    }
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

function Economy.orderDelivery(state, now)
    if not state.warehousePurchased then
        return false, "Unlock the warehouse before ordering stock."
    end
    if state.shipmentQuantity > 0 or state.shipmentReadyAt > 0 then
        return false, "A delivery is already on the way."
    end
    if state.backstock + Economy.DELIVERY_QUANTITY > Economy.BACKSTOCK_CAPACITY then
        return false, "There is not enough backroom space for another delivery."
    end
    if state.cash < Economy.DELIVERY_COST then
        return false,
            string.format("You need $%d to order a Citrus Pop delivery.", Economy.DELIVERY_COST)
    end
    if type(now) ~= "number" or now ~= now or now % 1 ~= 0 or now < 1 then
        return false, "The delivery time could not be confirmed. Try again."
    end
    state.cash -= Economy.DELIVERY_COST
    state.shipmentQuantity = Economy.DELIVERY_QUANTITY
    state.shipmentReadyAt = now + 15
    return true, "Delivery ordered for $60. It will arrive at the warehouse loading dock shortly."
end

function Economy.receiveDelivery(state, now)
    if state.shipmentQuantity <= 0 or state.shipmentReadyAt <= 0 then
        return false, "There is no delivery waiting at the loading dock."
    end
    if type(now) ~= "number" or now ~= now or now % 1 ~= 0 or now < state.shipmentReadyAt then
        return false, "The delivery is still on its way."
    end
    if state.backstock + state.shipmentQuantity > Economy.BACKSTOCK_CAPACITY then
        return false, "The backroom is full. Clear space before receiving this delivery."
    end
    local quantity = state.shipmentQuantity
    state.backstock += quantity
    state.shipmentQuantity = 0
    state.shipmentReadyAt = 0
    return true,
        string.format("Delivery received: %d Citrus Pop cans added to backroom stock.", quantity)
end

function Economy.sellProduct(state)
    if state.stage ~= "Checkout" then
        return false, "The checkout is waiting for the next customer."
    end
    if state.sales >= Economy.CUSTOMERS_PER_SHIFT then
        return false, "The checkout queue is already clear."
    end
    if state.stock <= 0 then
        return false, "The shelf is empty. Stock Citrus Pop first."
    end
    state.stock -= 1
    state.sales += 1
    state.cash += Economy.SALE_REWARD
    if state.sales == Economy.CHAOS_EVENTS.CheckoutSpill.triggerSales then
        state.stage = "Spill"
        return true, "Sale complete! +$25. A customer dropped groceries—clean up the spill!"
    end
    if state.sales >= Economy.CUSTOMERS_PER_SHIFT then
        state.stage = "CloseShift"
        return true, "Sale complete! +$25. All customers served. Close out your shift."
    end
    return true,
        string.format(
            "Sale complete! +$25. %d customers remain in the queue.",
            Economy.CUSTOMERS_PER_SHIFT - state.sales
        )
end

function Economy.cleanSpill(state)
    if state.stage ~= "Spill" then
        return false, "There is no spill to clean up right now."
    end
    state.cash += Economy.CHAOS_EVENTS.CheckoutSpill.reward
    state.stage = "Checkout"
    return true, "Aisle clear! +$5. The checkout queue is moving again."
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
    return true, "Warehouse annex purchased! Your retail empire is expanding."
end

return Economy
