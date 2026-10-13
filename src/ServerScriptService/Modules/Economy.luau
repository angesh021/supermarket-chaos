-- Pure first-shift rules. Keep Roblox services and Instances out of this module.
local Economy = {}
local RetailLayoutService = require(script.Parent.RetailLayoutService)

Economy.CART_REWARD = 10
Economy.SALE_REWARD = 25
Economy.SHIFT_REWARD = 20
Economy.UPGRADE_COST = 45
Economy.CASHIER_COST = 100
Economy.STOCKER_COST = 80
Economy.CLEANER_COST = 120
Economy.DELIVERY_WORKER_COST = 140
Economy.CUSTOMER_ASSISTANT_COST = 160
Economy.STORE_UTILITIES_PER_SHIFT = 2
Economy.WAREHOUSE_UPKEEP_PER_SHIFT = 2
Economy.REAR_WING_UPKEEP_PER_SHIFT = 1
Economy.DEPARTMENT_UPKEEP_PER_SHIFT = 1
Economy.SELF_CHECKOUT_UPKEEP_PER_SHIFT = 1
Economy.RETAIL_AISLE_UPKEEP_PER_SHIFT = 1
Economy.WAREHOUSE_COST = 200
Economy.MARKET_STYLE_COST = 180
Economy.AISLE_EXPANSION_COST = 220
Economy.FLOOR_EXPANSION_COST = 500
Economy.BAKERY_DEPARTMENT_COST = 350
Economy.FREEZER_DEPARTMENT_COST = 400
Economy.RETAIL_AISLE_COST = 250
Economy.SELF_CHECKOUT_COST = 300
Economy.CAFE_COST = 650
Economy.CAFE_RESTOCK_COST = 45
Economy.CAFE_RESTOCK_QUANTITY = 6
Economy.CAFE_SHELF_CAPACITY = 24
Economy.CAFE_COFFEE_PRICE = 18
Economy.RESTAURANT_COST = 1200
Economy.RESTAURANT_RESTOCK_COST = 80
Economy.RESTAURANT_RESTOCK_QUANTITY = 4
Economy.RESTAURANT_SHELF_CAPACITY = 16
Economy.RESTAURANT_MEAL_PRICE = 38
Economy.ELECTRONICS_STORE_COST = 2400
Economy.ELECTRONICS_RESTOCK_COST = 300
Economy.ELECTRONICS_RESTOCK_QUANTITY = 2
Economy.ELECTRONICS_SHELF_CAPACITY = 8
Economy.ELECTRONICS_ITEM_PRICE = 220
Economy.GARDEN_STORE_COST = 1800
Economy.GARDEN_RESTOCK_COST = 120
Economy.GARDEN_RESTOCK_QUANTITY = 3
Economy.GARDEN_SHELF_CAPACITY = 12
Economy.GARDEN_ITEM_PRICE = 75
Economy.FLORIST_STORE_COST = 1500
Economy.FLORIST_RESTOCK_COST = 320
Economy.FLORIST_RESTOCK_QUANTITY = 4
Economy.FLORIST_SHELF_CAPACITY = 12
Economy.FLORIST_BOUQUET_PRICE = 240
Economy.BOOKSHOP_COST = 2500
Economy.BOOKSHOP_RESTOCK_COST = 300
Economy.BOOKSHOP_RESTOCK_QUANTITY = 3
Economy.BOOKSHOP_SHELF_CAPACITY = 12
Economy.BOOKSHOP_BOOK_PRICE = 130
Economy.UPTOWN_STORE_COST = 15000
Economy.PLAZA_STYLE_COST = 750
Economy.DELIVERY_FLEET_COST = 3000
Economy.DELIVERY_FLEET_ORDERS_PER_SHIFT = 3
Economy.DISTRIBUTION_CENTER_COST = 6000
Economy.DISTRIBUTION_CENTER_BACKSTOCK_CAPACITY = 1000
Economy.SUPPLIER_PARTNERSHIP_COST = 2500
Economy.SUPPLIER_PARTNERSHIP_DISCOUNT = 0.2
Economy.ONLINE_ORDER_PRODUCTS = {
    { "citrusPop", "berryBites", "goldenApples" },
    { "sunriseCereal", "citrusPop", "goldenApples" },
    { "berryBites", "sunriseCereal", "citrusPop" },
    { "goldenApples", "berryBites", "sunriseCereal" },
}
Economy.MARKET_STYLE_PRESETS = {
    coastal = { name = "Coastal Market", cost = 180 },
    urban = { name = "City Grocer", cost = 180 },
    harvest = { name = "Harvest Market", cost = 180 },
}
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
Economy.CINNAMON_TWISTS_STOCK_PER_RESTOCK = 3
Economy.CINNAMON_TWISTS_SHELF_CAPACITY = 24
Economy.FROZEN_MEALS_STOCK_PER_RESTOCK = 3
Economy.FROZEN_MEALS_SHELF_CAPACITY = 24
Economy.POWER_OUTAGE_DURATION = 30
Economy.CUSTOMER_RUSH_DURATION = 90
Economy.CUSTOMER_RUSH_EXTRA_CUSTOMERS = 3
Economy.CUSTOMER_RUSH_REWARD = 30
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
    cinnamonTwists = {
        displayName = "Cinnamon Twists",
        salePrice = 18,
        deliveryCost = 50,
        deliveryQuantity = 18,
    },
    frozenMeals = {
        displayName = "Freezer Meals",
        salePrice = 22,
        priceOptions = { 18, 22, 28 },
        deliveryCost = 55,
        deliveryQuantity = 18,
    },
}

-- Ordered, server-owned substitutes. Customer demand never accepts a client SKU.
local PRODUCT_SUBSTITUTES = {
    citrusPop = { "berryBites" },
    berryBites = { "citrusPop" },
    goldenApples = { "sunriseCereal" },
    sunriseCereal = { "goldenApples" },
    cinnamonTwists = { "berryBites", "sunriseCereal" },
    frozenMeals = { "sunriseCereal", "cinnamonTwists" },
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

local function makeChaosPlan(playerSeed, completedShifts)
    local seed = math.floor(playerSeed or 0) % 997
    local shift = math.floor(completedShifts or 0) % 997
    local stride = seed % 2 == 0 and 1 or 3
    local planIndex = (seed + shift * stride) % 4
    local plans = {
        { spillAt = 1, powerOutageAt = 2 },
        { spillAt = 2, powerOutageAt = 1 },
        { spillAt = 1, powerOutageAt = nil },
        { spillAt = nil, powerOutageAt = 2 },
    }
    local selected = plans[planIndex + 1]
    return { spillAt = selected.spillAt, powerOutageAt = selected.powerOutageAt }
end

function Economy.newState(profile, playerSeed, companyWallet)
    profile = profile or {}
    local savedShift = profile.shift or {}
    local upgrades = profile.ownedUpgrades or {}
    local employeeAutomation = profile.employeeAutomation or {}
    local warehouseInventory = profile.warehouseInventory or {}
    local warehouseLayout = profile.warehouseLayout or { version = 1, items = {} }
    local savedPrices = profile.productPrices or {}
    local shipmentQuantity = warehouseInventory.shipmentQuantity or 0
    local completedShifts = math.max(0, math.floor(profile.completedShifts or 0))
    local state = {
        stage = savedShift.stage or "Cart",
        cash = profile.balance or 0,
        customerSatisfaction = profile.customerSatisfaction or 75,
        stock = savedShift.stock or 0,
        berryStock = savedShift.berryStock or 0,
        goldenAppleStock = savedShift.goldenAppleStock or 0,
        cerealStock = savedShift.cerealStock or 0,
        cinnamonTwistStock = savedShift.cinnamonTwistStock or 0,
        frozenMealStock = savedShift.frozenMealStock or 0,
        sales = savedShift.sales or 0,
        completedShifts = completedShifts,
        playerSeed = playerSeed or 0,
        chaosPlan = makeChaosPlan(playerSeed, completedShifts),
        cartRecovered = savedShift.cartRecovered or false,
        shiftClosed = savedShift.shiftClosed or false,
        powerOutageUntil = savedShift.powerOutageUntil or 0,
        customerRushUntil = savedShift.customerRushUntil or 0,
        upgradePurchased = upgrades.shelfBay or false,
        warehousePurchased = upgrades.warehouse or false,
        marketStylePurchased = upgrades.marketStyle or false,
        marketStyleId = upgrades.marketStyleId or (upgrades.marketStyle and "coastal" or ""),
        aisleExpansionPurchased = upgrades.aisleExpansion or false,
        floorExpansionPurchased = upgrades.floorExpansion or false,
        bakeryPurchased = upgrades.bakery or false,
        freezerPurchased = upgrades.freezer or false,
        selfCheckoutPurchased = upgrades.selfCheckout or false,
        warehouseLayout = warehouseLayout,
        retailLayout = RetailLayoutService.normalize(
            profile.retailLayout,
            upgrades.floorExpansion == true,
            upgrades.bakery == true,
            upgrades.freezer == true,
            upgrades.shelfBay == true,
            upgrades.aisleExpansion == true
        ) or RetailLayoutService.default(),
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
        cinnamonTwistBackstock = warehouseInventory.cinnamonTwists or (upgrades.bakery and 6 or 0),
        frozenMealBackstock = warehouseInventory.frozenMeals or (upgrades.freezer and 6 or 0),
        productPrices = {
            citrusPop = savedPrices.citrusPop or Economy.PRODUCTS.citrusPop.salePrice,
            berryBites = savedPrices.berryBites or Economy.PRODUCTS.berryBites.salePrice,
            goldenApples = savedPrices.goldenApples or Economy.PRODUCTS.goldenApples.salePrice,
            sunriseCereal = savedPrices.sunriseCereal or Economy.PRODUCTS.sunriseCereal.salePrice,
            cinnamonTwists = savedPrices.cinnamonTwists
                or Economy.PRODUCTS.cinnamonTwists.salePrice,
            frozenMeals = savedPrices.frozenMeals or Economy.PRODUCTS.frozenMeals.salePrice,
        },
        shipmentReadyAt = warehouseInventory.shipmentReadyAt or 0,
        shipmentQuantity = shipmentQuantity,
        shipmentProductId = shipmentQuantity > 0
                and (Economy.PRODUCTS[warehouseInventory.shipmentProductId] and warehouseInventory.shipmentProductId or "citrusPop")
            or "",
        onlineOrdersFulfilled = profile.onlineOrdersFulfilled or 0,
        deliveryWorkerOrderShift = savedShift.deliveryWorkerOrderShift or 0,
        cafePurchased = upgrades.cafe or false,
        cafeStock = savedShift.cafeStock or 0,
        cafeSales = savedShift.cafeSales or 0,
        restaurantPurchased = upgrades.restaurant or false,
        restaurantStock = savedShift.restaurantStock or 0,
        restaurantSales = savedShift.restaurantSales or 0,
        electronicsStorePurchased = upgrades.electronicsStore or false,
        electronicsStock = savedShift.electronicsStock or 0,
        electronicsSales = savedShift.electronicsSales or 0,
        gardenStorePurchased = upgrades.gardenStore or false,
        gardenStock = savedShift.gardenStock or 0,
        gardenSales = savedShift.gardenSales or 0,
        floristStorePurchased = upgrades.floristStore or false,
        floristStock = savedShift.floristStock or 0,
        floristSales = savedShift.floristSales or 0,
        bookshopPurchased = upgrades.bookshop or false,
        bookshopStock = savedShift.bookshopStock or 0,
        bookshopSales = savedShift.bookshopSales or 0,
        plazaStylePurchased = upgrades.plazaStyleId ~= nil and upgrades.plazaStyleId ~= "",
        plazaStyleId = upgrades.plazaStyleId or "",
        deliveryFleetPurchased = upgrades.deliveryFleet or false,
        distributionCenterPurchased = upgrades.distributionCenter or false,
        supplierPartnershipPurchased = upgrades.supplierPartnership or false,
        uptownStorePurchased = profile.locations ~= nil and profile.locations.uptown ~= nil,
        deliveryWorkerOrdersThisShift = savedShift.deliveryWorkerOrdersThisShift or 0,
    }
    if companyWallet then
        companyWallet.cash = companyWallet.cash or state.cash
        state.cash = nil
        return setmetatable(state, {
            __index = function(_, key)
                if key == "cash" then
                    return companyWallet.cash
                end
            end,
            __newindex = function(target, key, value)
                if key == "cash" then
                    companyWallet.cash = value
                else
                    rawset(target, key, value)
                end
            end,
        })
    end
    return state
end

function Economy.buyUptownStore(state)
    if
        state.stage ~= "Complete"
        or not state.supplierPartnershipPurchased
        or state.uptownStorePurchased
    then
        return false, "The Uptown Market opens after the supplier partnership, between shifts."
    end
    if state.cash < Economy.UPTOWN_STORE_COST then
        return false,
            string.format("You need $%d to open Uptown Market.", Economy.UPTOWN_STORE_COST)
    end
    state.cash -= Economy.UPTOWN_STORE_COST
    state.uptownStorePurchased = true
    return true, "Uptown Market purchased! Use the gold travel pad to visit your new store."
end

function Economy.buyCafe(state)
    if state.stage ~= "Complete" or not state.warehousePurchased or state.cafePurchased then
        return false, "The café is available after a completed shift with a warehouse."
    end
    if state.cash < Economy.CAFE_COST then
        return false, string.format("You need $%d to open the Corner Café.", Economy.CAFE_COST)
    end
    state.cash -= Economy.CAFE_COST
    state.cafePurchased = true
    state.cafeStock = 0
    return true, "Corner Café opened! Stock coffee at the counter to start serving."
end

function Economy.restockCafe(state)
    if not state.cafePurchased or state.stage ~= "Complete" then
        return false, "Restock the café between supermarket shifts."
    end
    if state.cafeStock + Economy.CAFE_RESTOCK_QUANTITY > Economy.CAFE_SHELF_CAPACITY then
        return false, "The café coffee shelf is full."
    end
    if state.cash < Economy.CAFE_RESTOCK_COST then
        return false, string.format("You need $%d to brew six coffees.", Economy.CAFE_RESTOCK_COST)
    end
    state.cash -= Economy.CAFE_RESTOCK_COST
    state.cafeStock += Economy.CAFE_RESTOCK_QUANTITY
    return true, string.format("Brewed %d coffees for the café.", Economy.CAFE_RESTOCK_QUANTITY)
end

function Economy.serveCafeCoffee(state)
    if not state.cafePurchased then
        return false, "Open the Corner Café before serving coffee."
    end
    if state.stage == "Loading" or state.stage == "OwnerOffline" then
        return false, "Wait until the café owner profile is ready."
    end
    if state.cafeStock < 1 then
        return false, "The café is out of coffee. Brew another batch at the counter."
    end
    if state.cafeSales >= 1000000000 then
        return false, "The café sales counter has reached its supported limit."
    end
    state.cafeStock -= 1
    state.cash += Economy.CAFE_COFFEE_PRICE
    state.cafeSales += 1
    return true, string.format("Coffee served! +$%d.", Economy.CAFE_COFFEE_PRICE)
end

function Economy.buyRestaurant(state)
    if state.stage ~= "Complete" or not state.cafePurchased or state.restaurantPurchased then
        return false, "The Market Table restaurant opens after the café, between shifts."
    end
    if state.cash < Economy.RESTAURANT_COST then
        return false,
            string.format("You need $%d to open the Market Table.", Economy.RESTAURANT_COST)
    end
    state.cash -= Economy.RESTAURANT_COST
    state.restaurantPurchased = true
    state.restaurantStock = 0
    return true, "Market Table is open! Prep a batch of meals to start serving."
end

function Economy.restockRestaurant(state)
    if not state.restaurantPurchased or state.stage ~= "Complete" then
        return false, "Prep restaurant meals between supermarket shifts."
    end
    if
        state.restaurantStock + Economy.RESTAURANT_RESTOCK_QUANTITY
        > Economy.RESTAURANT_SHELF_CAPACITY
    then
        return false, "The restaurant meal warmer is full."
    end
    if state.cash < Economy.RESTAURANT_RESTOCK_COST then
        return false,
            string.format("You need $%d to prep four meals.", Economy.RESTAURANT_RESTOCK_COST)
    end
    state.cash -= Economy.RESTAURANT_RESTOCK_COST
    state.restaurantStock += Economy.RESTAURANT_RESTOCK_QUANTITY
    return true, string.format("Prepped %d Garden Bowls.", Economy.RESTAURANT_RESTOCK_QUANTITY)
end

function Economy.serveRestaurantMeal(state)
    if not state.restaurantPurchased then
        return false, "Open the Market Table before serving meals."
    end
    if state.stage == "Loading" or state.stage == "OwnerOffline" then
        return false, "Wait until the restaurant owner profile is ready."
    end
    if state.restaurantStock < 1 then
        return false, "The meal warmer is empty. Prep another restaurant batch."
    end
    if state.restaurantSales >= 1000000000 then
        return false, "The restaurant sales counter has reached its supported limit."
    end
    state.restaurantStock -= 1
    state.cash += Economy.RESTAURANT_MEAL_PRICE
    state.restaurantSales += 1
    return true, string.format("Garden Bowl served! +$%d.", Economy.RESTAURANT_MEAL_PRICE)
end

function Economy.buyElectronicsStore(state)
    if
        state.stage ~= "Complete"
        or not state.restaurantPurchased
        or state.electronicsStorePurchased
    then
        return false, "Pixel & Plug opens after the Market Table restaurant, between shifts."
    end
    if state.cash < Economy.ELECTRONICS_STORE_COST then
        return false,
            string.format("You need $%d to open Pixel & Plug.", Economy.ELECTRONICS_STORE_COST)
    end
    state.cash -= Economy.ELECTRONICS_STORE_COST
    state.electronicsStorePurchased = true
    state.electronicsStock = 0
    return true, "Pixel & Plug is open! Stock the display to start selling headphones."
end

function Economy.restockElectronics(state)
    if not state.electronicsStorePurchased or state.stage ~= "Complete" then
        return false, "Stock electronics between supermarket shifts."
    end
    if
        state.electronicsStock + Economy.ELECTRONICS_RESTOCK_QUANTITY
        > Economy.ELECTRONICS_SHELF_CAPACITY
    then
        return false, "The electronics display is full."
    end
    if state.cash < Economy.ELECTRONICS_RESTOCK_COST then
        return false,
            string.format("You need $%d for two headphones.", Economy.ELECTRONICS_RESTOCK_COST)
    end
    state.cash -= Economy.ELECTRONICS_RESTOCK_COST
    state.electronicsStock += Economy.ELECTRONICS_RESTOCK_QUANTITY
    return true, string.format("Stocked %d headphones.", Economy.ELECTRONICS_RESTOCK_QUANTITY)
end

function Economy.sellElectronics(state)
    if not state.electronicsStorePurchased then
        return false, "Open Pixel & Plug before selling electronics."
    end
    if state.stage == "Loading" or state.stage == "OwnerOffline" then
        return false, "Wait until the store owner profile is ready."
    end
    if state.electronicsStock < 1 then
        return false, "The headphone display is empty. Restock it between shifts."
    end
    if state.electronicsSales >= 1000000000 then
        return false, "The electronics sales counter has reached its supported limit."
    end
    state.electronicsStock -= 1
    state.cash += Economy.ELECTRONICS_ITEM_PRICE
    state.electronicsSales += 1
    return true, string.format("Headphones sold! +$%d.", Economy.ELECTRONICS_ITEM_PRICE)
end

function Economy.buyGardenStore(state)
    if
        state.stage ~= "Complete"
        or not state.electronicsStorePurchased
        or state.gardenStorePurchased
    then
        return false, "Little Sprout Garden opens after Pixel & Plug, between shifts."
    end
    if state.cash < Economy.GARDEN_STORE_COST then
        return false,
            string.format("You need $%d to open Little Sprout Garden.", Economy.GARDEN_STORE_COST)
    end
    state.cash -= Economy.GARDEN_STORE_COST
    state.gardenStorePurchased = true
    state.gardenStock = 0
    return true, "Little Sprout Garden is open! Stock the plant stand to start selling."
end

function Economy.restockGarden(state)
    if not state.gardenStorePurchased or state.stage ~= "Complete" then
        return false, "Restock the garden stand between supermarket shifts."
    end
    if state.gardenStock + Economy.GARDEN_RESTOCK_QUANTITY > Economy.GARDEN_SHELF_CAPACITY then
        return false, "The garden stand is full."
    end
    if state.cash < Economy.GARDEN_RESTOCK_COST then
        return false,
            string.format("You need $%d for three potted herbs.", Economy.GARDEN_RESTOCK_COST)
    end
    state.cash -= Economy.GARDEN_RESTOCK_COST
    state.gardenStock += Economy.GARDEN_RESTOCK_QUANTITY
    return true, string.format("Stocked %d potted herbs.", Economy.GARDEN_RESTOCK_QUANTITY)
end

function Economy.sellGardenItem(state)
    if not state.gardenStorePurchased then
        return false, "Open Little Sprout Garden before selling plants."
    end
    if state.stage == "Loading" or state.stage == "OwnerOffline" then
        return false, "Wait until the store owner profile is ready."
    end
    if state.gardenStock < 1 then
        return false, "The garden stand is empty. Restock it between shifts."
    end
    if state.gardenSales >= 1000000000 then
        return false, "The garden sales counter has reached its supported limit."
    end
    state.gardenStock -= 1
    state.cash += Economy.GARDEN_ITEM_PRICE
    state.gardenSales += 1
    return true, string.format("Potted herb sold! +$%d.", Economy.GARDEN_ITEM_PRICE)
end

function Economy.buyFloristStore(state)
    if
        state.stage ~= "Complete"
        or not state.gardenStorePurchased
        or state.floristStorePurchased
    then
        return false, "Maple Corner Florist opens after Little Sprout, between shifts."
    end
    if state.cash < Economy.FLORIST_STORE_COST then
        return false,
            string.format("You need $%d to open Maple Corner Florist.", Economy.FLORIST_STORE_COST)
    end
    state.cash -= Economy.FLORIST_STORE_COST
    state.floristStorePurchased = true
    state.floristStock = 0
    return true, "Maple Corner Florist is open! Stock bouquets to start selling."
end

function Economy.restockFlorist(state)
    if not state.floristStorePurchased or state.stage ~= "Complete" then
        return false, "Restock Maple Corner Florist between supermarket shifts."
    end
    if state.floristStock + Economy.FLORIST_RESTOCK_QUANTITY > Economy.FLORIST_SHELF_CAPACITY then
        return false, "The florist display is full."
    end
    if state.cash < Economy.FLORIST_RESTOCK_COST then
        return false, string.format("You need $%d for four bouquets.", Economy.FLORIST_RESTOCK_COST)
    end
    state.cash -= Economy.FLORIST_RESTOCK_COST
    state.floristStock += Economy.FLORIST_RESTOCK_QUANTITY
    return true, string.format("Stocked %d bouquets.", Economy.FLORIST_RESTOCK_QUANTITY)
end

function Economy.sellFloristBouquet(state)
    if not state.floristStorePurchased then
        return false, "Open Maple Corner Florist before selling bouquets."
    end
    if state.stage == "Loading" or state.stage == "OwnerOffline" then
        return false, "Wait until the store owner profile is ready."
    end
    if state.floristStock < 1 then
        return false, "The bouquet display is empty. Restock it between shifts."
    end
    if state.floristSales >= 1000000000 then
        return false, "The florist sales counter has reached its supported limit."
    end
    state.floristStock -= 1
    state.cash += Economy.FLORIST_BOUQUET_PRICE
    state.floristSales += 1
    return true, string.format("Bouquet sold! +$%d.", Economy.FLORIST_BOUQUET_PRICE)
end

function Economy.buyBookshop(state)
    if state.stage ~= "Complete" or not state.floristStorePurchased or state.bookshopPurchased then
        return false, "Riverside Bookshop opens after Maple Corner, between shifts."
    end
    if state.cash < Economy.BOOKSHOP_COST then
        return false,
            string.format("You need $%d to open Riverside Bookshop.", Economy.BOOKSHOP_COST)
    end
    state.cash -= Economy.BOOKSHOP_COST
    state.bookshopPurchased = true
    state.bookshopStock = 0
    return true, "Riverside Bookshop opened! Stock paperbacks at the counter to start selling."
end

function Economy.restockBookshop(state)
    if not state.bookshopPurchased or state.stage ~= "Complete" then
        return false, "Restock Riverside Bookshop between supermarket shifts."
    end
    if
        state.bookshopStock + Economy.BOOKSHOP_RESTOCK_QUANTITY > Economy.BOOKSHOP_SHELF_CAPACITY
    then
        return false, "The bookshop display is full."
    end
    if state.cash < Economy.BOOKSHOP_RESTOCK_COST then
        return false,
            string.format("You need $%d for three paperbacks.", Economy.BOOKSHOP_RESTOCK_COST)
    end
    state.cash -= Economy.BOOKSHOP_RESTOCK_COST
    state.bookshopStock += Economy.BOOKSHOP_RESTOCK_QUANTITY
    return true, string.format("Stocked %d paperbacks.", Economy.BOOKSHOP_RESTOCK_QUANTITY)
end

function Economy.sellBookshopPaperback(state)
    if not state.bookshopPurchased then
        return false, "Open Riverside Bookshop before selling books."
    end
    if state.stage == "Loading" or state.stage == "OwnerOffline" then
        return false, "Wait until the bookshop owner profile is ready."
    end
    if state.bookshopStock < 1 then
        return false, "The bookshop display is empty. Restock between shifts."
    end
    if state.bookshopSales >= 1000000000 then
        return false, "The bookshop sales counter has reached its supported limit."
    end
    state.bookshopStock -= 1
    state.cash += Economy.BOOKSHOP_BOOK_PRICE
    state.bookshopSales += 1
    return true, string.format("Paperback sold! +$%d.", Economy.BOOKSHOP_BOOK_PRICE)
end

function Economy.buyPlazaStyle(state, styleId)
    if state.stage ~= "Complete" or not state.gardenStorePurchased or state.plazaStylePurchased then
        return false, "A plaza refresh is available after Little Sprout, between shifts."
    end
    if styleId ~= "coastal" and styleId ~= "urban" and styleId ~= "harvest" then
        return false, "Choose a valid plaza style preview first."
    end
    if state.cash < Economy.PLAZA_STYLE_COST then
        return false, string.format("You need $%d to refresh the plaza.", Economy.PLAZA_STYLE_COST)
    end
    state.cash -= Economy.PLAZA_STYLE_COST
    state.plazaStylePurchased = true
    state.plazaStyleId = styleId
    return true, string.format("%s plaza style installed!", string.upper(styleId))
end

function Economy.buyDeliveryFleet(state)
    if
        state.stage ~= "Complete"
        or not state.warehousePurchased
        or not state.deliveryWorkerHired
        or state.deliveryFleetPurchased
    then
        return false, "The delivery fleet requires a warehouse and hired delivery worker."
    end
    if state.cash < Economy.DELIVERY_FLEET_COST then
        return false,
            string.format("You need $%d to add the delivery fleet.", Economy.DELIVERY_FLEET_COST)
    end
    state.cash -= Economy.DELIVERY_FLEET_COST
    state.deliveryFleetPurchased = true
    return true, "Delivery fleet added! The worker can pack up to three orders each shift."
end

function Economy.getBackstockCapacity(state)
    return state.distributionCenterPurchased and Economy.DISTRIBUTION_CENTER_BACKSTOCK_CAPACITY
        or Economy.BACKSTOCK_CAPACITY
end

function Economy.buyDistributionCenter(state)
    if
        state.stage ~= "Complete"
        or not state.deliveryFleetPurchased
        or state.distributionCenterPurchased
    then
        return false, "The regional distribution center requires an owned delivery fleet."
    end
    if state.cash < Economy.DISTRIBUTION_CENTER_COST then
        return false,
            string.format(
                "You need $%d to build the distribution center.",
                Economy.DISTRIBUTION_CENTER_COST
            )
    end
    state.cash -= Economy.DISTRIBUTION_CENTER_COST
    state.distributionCenterPurchased = true
    return true, "Regional distribution center opened! Warehouse capacity doubled."
end

function Economy.getDeliveryCost(state, product)
    local discount = state.supplierPartnershipPurchased and Economy.SUPPLIER_PARTNERSHIP_DISCOUNT
        or 0
    return math.max(1, math.floor(product.deliveryCost * (1 - discount)))
end

function Economy.buySupplierPartnership(state)
    if
        state.stage ~= "Complete"
        or not state.distributionCenterPurchased
        or state.supplierPartnershipPurchased
    then
        return false, "The regional supplier partnership requires a distribution center."
    end
    if state.cash < Economy.SUPPLIER_PARTNERSHIP_COST then
        return false,
            string.format(
                "You need $%d to join the regional supplier partnership.",
                Economy.SUPPLIER_PARTNERSHIP_COST
            )
    end
    state.cash -= Economy.SUPPLIER_PARTNERSHIP_COST
    state.supplierPartnershipPurchased = true
    return true, "Regional supplier partnership signed! Inbound deliveries now cost 20% less."
end

function Economy.getNextOnlineOrder(state)
    local sequence = (state.onlineOrdersFulfilled or 0) % #Economy.ONLINE_ORDER_PRODUCTS + 1
    local items = {}
    local total = 0
    local backstockByProduct = {
        citrusPop = state.backstock,
        berryBites = state.berryBackstock,
        goldenApples = state.goldenAppleBackstock,
        sunriseCereal = state.cerealBackstock,
    }
    local ready = state.warehousePurchased == true
    for _, productId in ipairs(Economy.ONLINE_ORDER_PRODUCTS[sequence]) do
        local product = Economy.PRODUCTS[productId]
        local quantity = 1
        local unitPrice = Economy.getProductPrice(state, productId)
        table.insert(items, {
            productId = productId,
            displayName = product.displayName,
            quantity = quantity,
            unitPrice = unitPrice,
            available = backstockByProduct[productId] or 0,
        })
        total += quantity * unitPrice
        if (backstockByProduct[productId] or 0) < quantity then
            ready = false
        end
    end
    return {
        number = (state.onlineOrdersFulfilled or 0) + 1,
        items = items,
        total = total,
        ready = ready,
    }
end

function Economy.fulfillOnlineOrder(state)
    if not state.warehousePurchased then
        return false, "Build the warehouse before preparing online orders."
    end
    if state.stage ~= "Complete" then
        return false, "Prepare online orders between shifts."
    end
    if (state.onlineOrdersFulfilled or 0) >= 1000000000 then
        return false, "The online order history has reached its supported limit."
    end
    local order = Economy.getNextOnlineOrder(state)
    if not order.ready then
        return false, "The order needs more backroom stock. Replenish the missing products first."
    end
    for _, item in ipairs(order.items) do
        if item.productId == "citrusPop" then
            state.backstock -= item.quantity
        elseif item.productId == "berryBites" then
            state.berryBackstock -= item.quantity
        elseif item.productId == "goldenApples" then
            state.goldenAppleBackstock -= item.quantity
        elseif item.productId == "sunriseCereal" then
            state.cerealBackstock -= item.quantity
        end
    end
    state.cash += order.total
    state.onlineOrdersFulfilled = order.number
    return true,
        string.format("Online order #%d packed for delivery. +$%d.", order.number, order.total)
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

function Economy.getShiftOperatingCosts(state)
    local costs = 0
    if state.upgradePurchased then
        costs += Economy.STORE_UTILITIES_PER_SHIFT
    end
    if state.warehousePurchased then
        costs += Economy.WAREHOUSE_UPKEEP_PER_SHIFT
    end
    if state.floorExpansionPurchased then
        costs += Economy.REAR_WING_UPKEEP_PER_SHIFT
    end
    if state.bakeryPurchased then
        costs += Economy.DEPARTMENT_UPKEEP_PER_SHIFT
    end
    if state.freezerPurchased then
        costs += Economy.DEPARTMENT_UPKEEP_PER_SHIFT
    end
    if state.selfCheckoutPurchased then
        costs += Economy.SELF_CHECKOUT_UPKEEP_PER_SHIFT
    end
    local aisleCount = 0
    for _ in pairs(state.retailLayout and state.retailLayout.aisles or {}) do
        aisleCount += 1
    end
    costs += math.min(aisleCount, RetailLayoutService.MAX_CONSTRUCTED_AISLES)
    return costs
end

function Economy.cycleProductPrice(state, productId)
    local product = Economy.PRODUCTS[productId]
    if not product then
        return false, "That product is not in the store catalog."
    end
    if state.stage == "Loading" or state.stage == "OwnerOffline" then
        return false, "Wait until the store is ready before changing prices."
    end
    if productId == "cinnamonTwists" and not state.bakeryPurchased then
        return false, "Build the bakery before changing Cinnamon Twists prices."
    end
    if productId == "frozenMeals" and not state.freezerPurchased then
        return false, "Build the freezer section before changing Freezer Meals prices."
    end
    local lowPrice = math.max(1, math.floor(product.salePrice * 0.8))
    local highPrice = math.ceil(product.salePrice * 1.25)
    local options = product.priceOptions or { lowPrice, product.salePrice, highPrice }
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

function Economy.stockCinnamonTwists(state)
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
        return false, "Wait until store operations are underway before restocking Cinnamon Twists."
    end
    if not state.bakeryPurchased then
        return false, "Build the bakery before restocking Cinnamon Twists."
    end
    if state.cinnamonTwistBackstock < Economy.CINNAMON_TWISTS_STOCK_PER_RESTOCK then
        return false, "The backroom is out of Cinnamon Twists. Order a bakery delivery."
    end
    if
        state.cinnamonTwistStock + Economy.CINNAMON_TWISTS_STOCK_PER_RESTOCK
        > Economy.CINNAMON_TWISTS_SHELF_CAPACITY
    then
        return false, "The bakery display is full."
    end
    state.cinnamonTwistBackstock -= Economy.CINNAMON_TWISTS_STOCK_PER_RESTOCK
    state.cinnamonTwistStock += Economy.CINNAMON_TWISTS_STOCK_PER_RESTOCK
    return true, "Fresh Cinnamon Twists stocked in the bakery."
end

function Economy.stockFrozenMeals(state)
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
        return false, "Wait until store operations are underway before stocking Freezer Meals."
    end
    if not state.freezerPurchased then
        return false, "Build the freezer section before stocking Freezer Meals."
    end
    if state.frozenMealBackstock < Economy.FROZEN_MEALS_STOCK_PER_RESTOCK then
        return false, "The backroom is out of Freezer Meals. Order a freezer delivery."
    end
    if
        state.frozenMealStock + Economy.FROZEN_MEALS_STOCK_PER_RESTOCK
        > Economy.FROZEN_MEALS_SHELF_CAPACITY
    then
        return false, "The freezer display is full."
    end
    state.frozenMealBackstock -= Economy.FROZEN_MEALS_STOCK_PER_RESTOCK
    state.frozenMealStock += Economy.FROZEN_MEALS_STOCK_PER_RESTOCK
    return true, "Freezer Meals stocked in the freezer section."
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
    if productId == "cinnamonTwists" and not state.bakeryPurchased then
        return false, "Build the bakery before ordering Cinnamon Twists."
    end
    if productId == "frozenMeals" and not state.freezerPurchased then
        return false, "Build the freezer section before ordering Freezer Meals."
    end
    if state.shipmentQuantity > 0 or state.shipmentReadyAt > 0 then
        return false, "A delivery is already on the way."
    end
    local currentBackstock = productId == "citrusPop" and state.backstock
        or (
            productId == "berryBites" and state.berryBackstock
            or (
                productId == "goldenApples" and state.goldenAppleBackstock
                or (
                    productId == "cinnamonTwists" and state.cinnamonTwistBackstock
                    or (
                        productId == "frozenMeals" and state.frozenMealBackstock
                        or state.cerealBackstock
                    )
                )
            )
        )
    if currentBackstock + product.deliveryQuantity > Economy.getBackstockCapacity(state) then
        return false, "There is not enough backroom space for another delivery."
    end
    local deliveryCost = Economy.getDeliveryCost(state, product)
    if state.cash < deliveryCost then
        return false, string.format("You need $%d to order %s.", deliveryCost, product.displayName)
    end
    if type(now) ~= "number" or now ~= now or now % 1 ~= 0 or now < 1 then
        return false, "The delivery time could not be confirmed. Try again."
    end
    state.cash -= deliveryCost
    state.shipmentQuantity = product.deliveryQuantity
    state.shipmentReadyAt = now + 15
    state.shipmentProductId = productId
    return true,
        string.format(
            "%s delivery ordered for $%d. It will arrive shortly.",
            product.displayName,
            deliveryCost
        )
end

function Economy.receiveDelivery(state, now)
    if state.shipmentQuantity <= 0 or state.shipmentReadyAt <= 0 then
        return false, "There is no delivery waiting at the loading dock."
    end
    if type(now) ~= "number" or now ~= now or now % 1 ~= 0 or now < state.shipmentReadyAt then
        return false, "The delivery is still on its way."
    end
    local productId = state.shipmentProductId == "frozenMeals" and "frozenMeals"
        or (
            state.shipmentProductId == "cinnamonTwists" and "cinnamonTwists"
            or (
                state.shipmentProductId == "goldenApples" and "goldenApples"
                or (
                    state.shipmentProductId == "sunriseCereal" and "sunriseCereal"
                    or (state.shipmentProductId == "berryBites" and "berryBites" or "citrusPop")
                )
            )
        )
    local currentBackstock = productId == "citrusPop" and state.backstock
        or (
            productId == "berryBites" and state.berryBackstock
            or (
                productId == "goldenApples" and state.goldenAppleBackstock
                or (
                    productId == "cinnamonTwists" and state.cinnamonTwistBackstock
                    or (
                        productId == "frozenMeals" and state.frozenMealBackstock
                        or state.cerealBackstock
                    )
                )
            )
        )
    if currentBackstock + state.shipmentQuantity > Economy.getBackstockCapacity(state) then
        return false, "The backroom is full. Clear space before receiving this delivery."
    end
    local quantity = state.shipmentQuantity
    if productId == "citrusPop" then
        state.backstock += quantity
    elseif productId == "berryBites" then
        state.berryBackstock += quantity
    elseif productId == "goldenApples" then
        state.goldenAppleBackstock += quantity
    elseif productId == "cinnamonTwists" then
        state.cinnamonTwistBackstock += quantity
    elseif productId == "frozenMeals" then
        state.frozenMealBackstock += quantity
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

-- The reproducible weighted draw is derived from the saved completed-shift count
-- and next sale number. The server resolves each preference against live stock.
function Economy.getNextCheckoutBasket(state)
    local customerNumber = state.sales + 1
    local shiftNumber = math.max(0, math.floor(state.completedShifts or 0))
    local weightedIntents = {
        { name = "Everyday", weight = 40, products = { "citrusPop" } },
        { name = "Value shopper", weight = 25, products = { "berryBites", "berryBites" } },
        { name = "Family shop", weight = 20, products = { "goldenApples", "sunriseCereal" } },
        { name = "Treat stop", weight = 15, products = { "citrusPop", "berryBites" } },
    }
    if state.bakeryPurchased then
        weightedIntents = {
            { name = "Everyday", weight = 35, products = { "citrusPop" } },
            { name = "Value shopper", weight = 20, products = { "berryBites", "berryBites" } },
            {
                name = "Family shop",
                weight = 18,
                products = { "goldenApples", "sunriseCereal", "cinnamonTwists" },
            },
            {
                name = "Treat stop",
                weight = 15,
                products = { "citrusPop", "berryBites", "cinnamonTwists" },
            },
            {
                name = "Bakery stop",
                weight = 12,
                products = { "cinnamonTwists", "cinnamonTwists" },
            },
        }
    end
    if (state.customerSatisfaction or 75) >= 80 then
        if state.bakeryPurchased then
            weightedIntents = {
                { name = "Everyday", weight = 30, products = { "citrusPop" } },
                { name = "Value shopper", weight = 17, products = { "berryBites", "berryBites" } },
                {
                    name = "Family shop",
                    weight = 17,
                    products = { "goldenApples", "sunriseCereal", "cinnamonTwists" },
                },
                {
                    name = "Treat stop",
                    weight = 14,
                    products = { "citrusPop", "berryBites", "cinnamonTwists" },
                },
                {
                    name = "Bakery stop",
                    weight = 12,
                    products = { "cinnamonTwists", "cinnamonTwists" },
                },
                {
                    name = "Neighborhood regular",
                    weight = 10,
                    products = { "citrusPop", "berryBites" },
                },
            }
        else
            weightedIntents = {
                { name = "Everyday", weight = 35, products = { "citrusPop" } },
                { name = "Value shopper", weight = 22, products = { "berryBites", "berryBites" } },
                {
                    name = "Family shop",
                    weight = 18,
                    products = { "goldenApples", "sunriseCereal" },
                },
                {
                    name = "Treat stop",
                    weight = 15,
                    products = { "citrusPop", "berryBites" },
                },
                {
                    name = "Neighborhood regular",
                    weight = 10,
                    products = { "citrusPop", "berryBites" },
                },
            }
        end
    end
    local draw = (
        (customerNumber * 73 + shiftNumber * 191 + customerNumber * shiftNumber * 17) % 100
    ) + 1
    local intent = weightedIntents[1]
    for _, candidate in ipairs(weightedIntents) do
        draw -= candidate.weight
        if draw <= 0 then
            intent = candidate
            break
        end
    end
    local preferredProducts = {}
    for _, productId in ipairs(intent.products) do
        table.insert(preferredProducts, productId)
    end
    if
        state.freezerPurchased
        and (customerNumber + shiftNumber * Economy.CUSTOMERS_PER_SHIFT) % 4 == 0
    then
        table.insert(preferredProducts, "frozenMeals")
        intent = { name = intent.name .. " + Freezer pick", products = preferredProducts }
    end
    local available = {
        citrusPop = math.max(0, math.floor(state.stock or 0)),
        berryBites = math.max(0, math.floor(state.berryStock or 0)),
        goldenApples = math.max(0, math.floor(state.goldenAppleStock or 0)),
        sunriseCereal = math.max(0, math.floor(state.cerealStock or 0)),
        cinnamonTwists = math.max(0, math.floor(state.cinnamonTwistStock or 0)),
        frozenMeals = math.max(0, math.floor(state.frozenMealStock or 0)),
    }
    local items = {}
    local counts = {}
    local directCounts = {}
    local substitutionCounts = {}
    local fulfilledCount = 0
    local unfulfilledCount = 0
    local missingProducts = {}

    -- Reserve exact matches first so an early fallback cannot consume another requested SKU.
    for _, productId in ipairs(preferredProducts) do
        if available[productId] > 0 then
            available[productId] -= 1
            counts[productId] = (counts[productId] or 0) + 1
            directCounts[productId] = (directCounts[productId] or 0) + 1
            fulfilledCount += 1
        else
            table.insert(missingProducts, productId)
        end
    end
    for _, productId in ipairs(missingProducts) do
        local substituteFound = false
        for _, substituteId in ipairs(PRODUCT_SUBSTITUTES[productId] or {}) do
            if available[substituteId] > 0 then
                available[substituteId] -= 1
                counts[substituteId] = (counts[substituteId] or 0) + 1
                substitutionCounts[substituteId] = substitutionCounts[substituteId] or {}
                substitutionCounts[substituteId][productId] = (
                    substitutionCounts[substituteId][productId] or 0
                ) + 1
                fulfilledCount += 1
                substituteFound = true
                break
            end
        end
        if not substituteFound then
            unfulfilledCount += 1
        end
    end

    -- If no preferred or related product is available, keep checkout usable with one
    -- explicitly labeled fallback item rather than presenting it as the requested product.
    if fulfilledCount == 0 then
        local fallbackId = state.stock > 0 and "citrusPop"
            or (state.berryStock > 0 and "berryBites" or nil)
            or (state.goldenAppleStock > 0 and "goldenApples" or nil)
            or (state.cerealStock > 0 and "sunriseCereal" or nil)
            or (state.cinnamonTwistStock > 0 and "cinnamonTwists" or nil)
            or (state.frozenMealStock > 0 and "frozenMeals" or nil)
        if fallbackId then
            counts[fallbackId] = 1
            substitutionCounts[fallbackId] = substitutionCounts[fallbackId] or {}
            local requestedId = preferredProducts[1]
            substitutionCounts[fallbackId][requestedId] = (
                substitutionCounts[fallbackId][requestedId] or 0
            ) + 1
            fulfilledCount = 1
            unfulfilledCount = math.max(0, unfulfilledCount - 1)
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

    -- Price-tier quantity changes must not leave labels or fulfillment credit for
    -- substitute units that are no longer in the final basket.
    for productId, substitutions in pairs(substitutionCounts) do
        local remainingQuantity =
            math.max(0, (counts[productId] or 0) - (directCounts[productId] or 0))
        local requestedIds = {}
        for requestedId in pairs(substitutions) do
            table.insert(requestedIds, requestedId)
        end
        table.sort(requestedIds)
        for _, requestedId in ipairs(requestedIds) do
            local keptQuantity = math.min(substitutions[requestedId], remainingQuantity)
            substitutions[requestedId] = keptQuantity
            remainingQuantity -= keptQuantity
            if keptQuantity == 0 then
                substitutions[requestedId] = nil
            end
        end
        if next(substitutions) == nil then
            substitutionCounts[productId] = nil
        end
    end

    for productId, quantity in pairs(counts) do
        local substituteLabels = {}
        for requestedId, substituteQuantity in pairs(substitutionCounts[productId] or {}) do
            table.insert(
                substituteLabels,
                string.format(
                    "%dx %s",
                    substituteQuantity,
                    Economy.PRODUCTS[requestedId].displayName
                )
            )
        end
        table.sort(substituteLabels)
        table.insert(items, {
            productId = productId,
            quantity = quantity,
            displayName = Economy.PRODUCTS[productId].displayName,
            unitPrice = Economy.getProductPrice(state, productId),
            substitutionFor = #substituteLabels > 0 and table.concat(substituteLabels, ", ") or nil,
        })
    end
    table.sort(items, function(left, right)
        return left.productId < right.productId
    end)

    local total = 0
    local labels = {}
    for _, item in ipairs(items) do
        total += item.quantity * item.unitPrice
        table.insert(
            labels,
            string.format(
                "%s x%d%s",
                item.displayName,
                item.quantity,
                item.substitutionFor and " (sub for " .. item.substitutionFor .. ")" or ""
            )
        )
    end
    local preferredProductIds = {}
    local preferredCounts = {}
    for _, productId in ipairs(preferredProducts) do
        table.insert(preferredProductIds, productId)
        preferredCounts[productId] = (preferredCounts[productId] or 0) + 1
    end
    local substitutionCount = 0
    local substitutedByRequested = {}
    local substitutedByActual = {}
    for _, substitutions in pairs(substitutionCounts) do
        for requestedId, quantity in pairs(substitutions) do
            substitutionCount += quantity
            substitutedByRequested[requestedId] = (substitutedByRequested[requestedId] or 0)
                + quantity
        end
    end
    for actualProductId, substitutions in pairs(substitutionCounts) do
        for _, quantity in pairs(substitutions) do
            substitutedByActual[actualProductId] = (substitutedByActual[actualProductId] or 0)
                + quantity
        end
    end
    unfulfilledCount = 0
    local preferenceSatisfied = next(substitutionCounts) == nil
    for productId, quantity in pairs(preferredCounts) do
        local directFulfilled = math.min(
            quantity,
            directCounts[productId] or 0,
            math.max(0, (counts[productId] or 0) - (substitutedByActual[productId] or 0))
        )
        local requestedFulfilled = directFulfilled + (substitutedByRequested[productId] or 0)
        if requestedFulfilled < quantity then
            unfulfilledCount += quantity - requestedFulfilled
            preferenceSatisfied = false
        end
    end
    local satisfactionDelta = preferenceSatisfied and 3
        or math.max(-10, 3 - substitutionCount * 2 - unfulfilledCount * 4)
    for _, item in ipairs(items) do
        if item.unitPrice > Economy.PRODUCTS[item.productId].salePrice then
            satisfactionDelta -= 2
        end
    end
    return {
        items = items,
        total = total,
        displayName = #labels > 0 and table.concat(labels, " + ") or "No shelf stock",
        preferredProductIds = preferredProductIds,
        preferenceName = intent.name,
        preferenceSatisfied = preferenceSatisfied,
        satisfactionDelta = satisfactionDelta,
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
        cinnamonTwists = state.cinnamonTwistStock,
        frozenMeals = state.frozenMealStock,
    }
    local backstockByProduct = {
        citrusPop = state.backstock,
        berryBites = state.berryBackstock,
        goldenApples = state.goldenAppleBackstock,
        sunriseCereal = state.cerealBackstock,
        cinnamonTwists = state.cinnamonTwistBackstock,
        frozenMeals = state.frozenMealBackstock,
    }
    local restockByProduct = {
        citrusPop = Economy.CITRUS_POP_STOCK_PER_RESTOCK,
        berryBites = Economy.BERRY_BITES_STOCK_PER_RESTOCK,
        goldenApples = Economy.GOLDEN_APPLES_STOCK_PER_RESTOCK,
        sunriseCereal = Economy.SUNRISE_CEREAL_STOCK_PER_RESTOCK,
        cinnamonTwists = Economy.CINNAMON_TWISTS_STOCK_PER_RESTOCK,
        frozenMeals = Economy.FROZEN_MEALS_STOCK_PER_RESTOCK,
    }
    local stockActionByProduct = {
        citrusPop = Economy.stockProduct,
        berryBites = Economy.stockBerryBites,
        goldenApples = Economy.stockGoldenApples,
        sunriseCereal = Economy.stockSunriseCereal,
        cinnamonTwists = Economy.stockCinnamonTwists,
        frozenMeals = Economy.stockFrozenMeals,
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

function Economy.sellProduct(state, now, waitSeconds)
    waitSeconds = waitSeconds or 0
    if
        type(waitSeconds) ~= "number"
        or waitSeconds ~= waitSeconds
        or waitSeconds % 1 ~= 0
        or waitSeconds < 0
        or waitSeconds > 86400
    then
        return false, "The customer's checkout wait could not be confirmed. Try again."
    end
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
            state.sales + 1 == (state.chaosPlan.powerOutageAt or -1)
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
        elseif item.productId == "sunriseCereal" then
            state.cerealStock -= item.quantity
        elseif item.productId == "cinnamonTwists" then
            state.cinnamonTwistStock -= item.quantity
        else
            state.frozenMealStock -= item.quantity
        end
    end
    state.sales += 1
    state.cash += basket.total
    local previousSatisfaction = math.min(math.max(state.customerSatisfaction or 75, 0), 100)
    local patiencePenalty = math.min(4, math.floor(waitSeconds / 20))
    local satisfactionDelta = basket.satisfactionDelta - patiencePenalty
    state.customerSatisfaction =
        math.min(math.max(previousSatisfaction + satisfactionDelta, 0), 100)
    local satisfactionFeedback = string.format(
        " Customer satisfaction %s%d%s.",
        satisfactionDelta > 0 and "+" or "",
        satisfactionDelta,
        patiencePenalty > 0 and string.format(" (patience -%d)", patiencePenalty) or ""
    )
    if state.sales == state.chaosPlan.spillAt then
        state.stage = "Spill"
        return true,
            string.format(
                "Basket complete! +$%d for %s. A customer dropped groceries—clean up the spill!",
                basket.total,
                basket.displayName
            ) .. satisfactionFeedback
    end
    if state.sales == state.chaosPlan.powerOutageAt then
        state.powerOutageUntil = now + Economy.CHAOS_EVENTS.PowerOutage.duration
        state.stage = "PowerOutage"
        return true,
            string.format(
                "Basket complete! +$%d for %s. The power is out—restore it at the breaker!",
                basket.total,
                basket.displayName
            ) .. satisfactionFeedback
    end
    if
        state.sales == Economy.CHAOS_EVENTS.CustomerRush.triggerSales
        and state.customerRushUntil == 0
        and state.stock
                + state.berryStock
                + state.goldenAppleStock
                + state.cerealStock
                + state.cinnamonTwistStock
                + state.frozenMealStock
            >= Economy.CUSTOMER_RUSH_EXTRA_CUSTOMERS
    then
        state.customerRushUntil = now + Economy.CHAOS_EVENTS.CustomerRush.duration
        state.stage = "CustomerRush"
        return true,
            string.format(
                "Basket complete! +$%d for %s. Customer rush! Serve %d more shoppers within %d seconds.",
                basket.total,
                basket.displayName,
                Economy.CUSTOMER_RUSH_EXTRA_CUSTOMERS,
                Economy.CUSTOMER_RUSH_DURATION
            ) .. satisfactionFeedback
    end
    if state.customerRushUntil > 0 and state.sales >= Economy.MAX_CUSTOMERS_PER_SHIFT then
        state.cash += Economy.CUSTOMER_RUSH_REWARD
        state.customerRushUntil = 0
        state.stage = "CloseShift"
        return true,
            string.format(
                "Rush cleared! +$%d bonus. All customers served; close out your shift.",
                Economy.CUSTOMER_RUSH_REWARD
            ) .. satisfactionFeedback
    end
    if state.customerRushUntil == 0 and state.sales >= Economy.CUSTOMERS_PER_SHIFT then
        state.stage = "CloseShift"
        return true,
            string.format(
                "Basket complete! +$%d for %s. All customers served. Close out your shift.",
                basket.total,
                basket.displayName
            ) .. satisfactionFeedback
    end
    return true,
        string.format(
            "Basket complete! +$%d for %s. %d customers remain in the queue.",
            basket.total,
            basket.displayName,
            Economy.getCustomerTarget(state) - state.sales
        ) .. satisfactionFeedback
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
    state.completedShifts = (state.completedShifts or 0) + 1
    state.cash += Economy.SHIFT_REWARD
    local payroll = Economy.getShiftPayroll(state)
    state.cash -= payroll
    local operatingCosts = Economy.getShiftOperatingCosts(state)
    local operatingCostsPaid = math.min(math.max(0, state.cash), operatingCosts)
    state.cash -= operatingCostsPaid
    local netReward = Economy.SHIFT_REWARD - payroll - operatingCostsPaid
    local closeMessage
    if payroll > 0 or operatingCosts > 0 then
        closeMessage = string.format(
            "Shift complete! +$%d bonus, -$%d payroll, -$%d/$%d operating costs (net %s$%d).",
            Economy.SHIFT_REWARD,
            payroll,
            operatingCostsPaid,
            operatingCosts,
            netReward >= 0 and "+" or "-",
            math.abs(netReward)
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
    state.cinnamonTwistStock = 0
    state.powerOutageUntil = 0
    state.sales = 0
    state.chaosPlan = makeChaosPlan(state.playerSeed, state.completedShifts)
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

function Economy.buyMarketStyle(state, styleId)
    if state.stage ~= "Complete" or state.marketStylePurchased then
        return false, "The storefront style package is not available right now."
    end
    local style = Economy.MARKET_STYLE_PRESETS[styleId]
    if not style then
        return false, "Choose a valid storefront style preview first."
    end
    if state.cash < style.cost then
        return false, string.format("You need $%d to refresh the storefront.", style.cost)
    end
    state.cash -= style.cost
    state.marketStylePurchased = true
    state.marketStyleId = styleId
    return true, style.name .. " style installed! Your storefront has a fresh new look."
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

function Economy.buyFloorExpansion(state)
    if
        state.stage ~= "Complete"
        or not state.aisleExpansionPurchased
        or state.floorExpansionPurchased
    then
        return false, "The rear department expansion is not available right now."
    end
    if state.cash < Economy.FLOOR_EXPANSION_COST then
        return false,
            string.format(
                "You need $%d to build the rear department wing.",
                Economy.FLOOR_EXPANSION_COST
            )
    end
    state.cash -= Economy.FLOOR_EXPANSION_COST
    state.floorExpansionPurchased = true
    return true, "Rear department wing built! The main floor now has room to grow."
end

function Economy.buyBakeryDepartment(state)
    if
        state.stage ~= "Complete"
        or not state.floorExpansionPurchased
        or not state.warehousePurchased
        or state.bakeryPurchased
    then
        return false,
            "The bakery is not available right now. Build the rear wing and warehouse first."
    end
    if state.cash < Economy.BAKERY_DEPARTMENT_COST then
        return false,
            string.format(
                "You need $%d to build the bakery department.",
                Economy.BAKERY_DEPARTMENT_COST
            )
    end
    local compatibleLayout, layoutError = RetailLayoutService.normalize(
        state.retailLayout,
        state.floorExpansionPurchased,
        true,
        state.freezerPurchased,
        state.upgradePurchased,
        state.aisleExpansionPurchased
    )
    if not compatibleLayout then
        return false,
            "Move the rear shelf out of the bakery build zone first. " .. tostring(layoutError)
    end
    state.cash -= Economy.BAKERY_DEPARTMENT_COST
    state.bakeryPurchased = true
    state.cinnamonTwistBackstock = math.max(state.cinnamonTwistBackstock or 0, 6)
    return true, "Bakery built! Fresh Cinnamon Twists are ready for stocking."
end

function Economy.buyFreezerDepartment(state)
    if
        state.stage ~= "Complete"
        or not state.floorExpansionPurchased
        or not state.warehousePurchased
        or not state.bakeryPurchased
        or state.freezerPurchased
    then
        return false, "Build the rear wing, warehouse and bakery before adding freezers."
    end
    if state.cash < Economy.FREEZER_DEPARTMENT_COST then
        return false,
            string.format(
                "You need $%d to build the freezer section.",
                Economy.FREEZER_DEPARTMENT_COST
            )
    end
    local compatibleLayout, layoutError = RetailLayoutService.normalize(
        state.retailLayout,
        state.floorExpansionPurchased,
        state.bakeryPurchased,
        true,
        state.upgradePurchased,
        state.aisleExpansionPurchased
    )
    if not compatibleLayout then
        return false,
            "Move the rear shelf out of the freezer build zone first. " .. tostring(layoutError)
    end
    state.cash -= Economy.FREEZER_DEPARTMENT_COST
    state.freezerPurchased = true
    state.frozenMealBackstock = math.max(state.frozenMealBackstock or 0, 6)
    return true, "Freezer section built! Freezer Meals are ready for stocking."
end

function Economy.buildRetailAisle(state, aisleId, x, z, rotation, productId)
    if state.stage ~= "Complete" or not state.upgradePurchased then
        return false, "Build the first shelf bay before adding more grocery aisles."
    end
    if not RetailLayoutService.isConstructedAisleId(aisleId) then
        return false, "That grocery aisle selection is invalid."
    end
    if not RetailLayoutService.isProductId(productId) then
        return false, "Choose a department for the new grocery aisle."
    end
    if
        (productId == "cinnamonTwists" and not state.bakeryPurchased)
        or (productId == "frozenMeals" and not state.freezerPurchased)
    then
        return false, "Build that product department before adding its aisle."
    end
    local count = 0
    for _ in pairs(state.retailLayout.aisles) do
        count += 1
    end
    if count >= RetailLayoutService.MAX_CONSTRUCTED_AISLES then
        return false, "The store has reached its constructed aisle limit."
    end
    if state.cash < Economy.RETAIL_AISLE_COST then
        return false,
            string.format("You need $%d to build a grocery aisle.", Economy.RETAIL_AISLE_COST)
    end
    local valid, reason = RetailLayoutService.canPlaceConstructedAisle(
        state.retailLayout,
        aisleId,
        x,
        z,
        rotation,
        state.floorExpansionPurchased,
        state.bakeryPurchased,
        state.freezerPurchased,
        state.upgradePurchased,
        state.aisleExpansionPurchased
    )
    if not valid then
        return false, reason
    end
    state.cash -= Economy.RETAIL_AISLE_COST
    state.retailLayout.aisles[aisleId] = {
        x = x,
        z = z,
        rotation = rotation,
        productId = productId,
    }
    return true,
        string.format(
            "%s aisle built for $%d.",
            Economy.PRODUCTS[productId].displayName,
            Economy.RETAIL_AISLE_COST
        )
end

function Economy.moveRetailAisle(state, aisleId, x, z, rotation)
    if state.stage ~= "Complete" or not state.upgradePurchased then
        return false, "Edit grocery aisles between shifts after building the first shelf bay."
    end
    if not RetailLayoutService.isConstructedAisleId(aisleId) then
        return false, "Select a saved grocery aisle first."
    end
    local aisle = state.retailLayout.aisles[aisleId]
    if not aisle then
        return false, "Select a saved grocery aisle first."
    end
    local valid, reason = RetailLayoutService.canPlaceConstructedAisle(
        state.retailLayout,
        aisleId,
        x,
        z,
        rotation,
        state.floorExpansionPurchased,
        state.bakeryPurchased,
        state.freezerPurchased,
        state.upgradePurchased,
        state.aisleExpansionPurchased,
        aisleId
    )
    if not valid then
        return false, reason
    end
    aisle.x = x
    aisle.z = z
    aisle.rotation = rotation
    return true, "Grocery aisle moved."
end

function Economy.buySelfCheckout(state)
    if
        state.stage ~= "Complete"
        or not state.floorExpansionPurchased
        or not state.warehousePurchased
        or state.selfCheckoutPurchased
    then
        return false, "Self-checkout is available after building the rear wing and warehouse."
    end
    if state.cash < Economy.SELF_CHECKOUT_COST then
        return false,
            string.format("You need $%d to install self-checkout.", Economy.SELF_CHECKOUT_COST)
    end
    state.cash -= Economy.SELF_CHECKOUT_COST
    state.selfCheckoutPurchased = true
    return true, "Self-checkout installed! Shoppers can now use the second checkout lane."
end

return Economy
