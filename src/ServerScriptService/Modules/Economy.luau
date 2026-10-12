-- Pure first-shift rules. Keep Roblox services and Instances out of this module.
local Economy = {}

Economy.CART_REWARD = 10
Economy.SALE_REWARD = 25
Economy.SHIFT_REWARD = 20
Economy.UPGRADE_COST = 45
Economy.STARTING_STOCK = 3

function Economy.newState()
    return {
        stage = "Cart",
        cash = 0,
        stock = 0,
        sales = 0,
        cartRecovered = false,
        shiftClosed = false,
        upgradePurchased = false,
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
    state.stock += Economy.STARTING_STOCK
    state.stage = "Checkout"
    return true, "Citrus Pop stocked. A customer is ready at checkout."
end

function Economy.sellProduct(state)
    if state.stage ~= "Checkout" then
        return false, "The checkout is waiting for the next customer."
    end
    if state.stock <= 0 then
        return false, "The shelf is empty. Stock Citrus Pop first."
    end
    state.stock -= 1
    state.sales += 1
    state.cash += Economy.SALE_REWARD
    state.stage = "CloseShift"
    return true, "Sale complete! +$25. Close out your first shift."
end

function Economy.closeShift(state)
    if state.stage ~= "CloseShift" or state.shiftClosed then
        return false, "Serve the waiting customer before closing."
    end
    state.shiftClosed = true
    state.cash += Economy.SHIFT_REWARD
    state.stage = "Upgrade"
    return true, "First shift complete! +$20. Add a shelf bay to grow the store."
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

return Economy
