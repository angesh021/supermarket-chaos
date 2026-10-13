-- Per-player save profiles with a server-side lease. All callers are server code.
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local ProfileService = {}
local LayoutService = require(script.Parent.LayoutService)
local RetailLayoutService = require(script.Parent.RetailLayoutService)

local SCHEMA_VERSION = 22
local SESSION_LEASE_SECONDS = 180
local MAX_RETRIES = 3
local STORE_NAME = "SupermarketChaos_PlayerProfiles_v1"
local DEVELOPMENT_UNIVERSE_ID = 10770581249
local sessionId = HttpService:GenerateGUID(false)
local profiles = {}
local store
local storeReady = false
local storeError = "Persistence is enabled only in the configured development universe."
if game.GameId == DEVELOPMENT_UNIVERSE_ID then
    storeReady, storeError = pcall(function()
        store = DataStoreService:GetDataStore(STORE_NAME)
    end)
else
    storeError = string.format(
        "Universe %s is not the configured development universe; using session-only profiles.",
        tostring(game.GameId)
    )
end

local function defaultProfile()
    return {
        schemaVersion = SCHEMA_VERSION,
        balance = 0,
        shift = {
            stage = "Cart",
            stock = 0,
            berryStock = 0,
            goldenAppleStock = 0,
            cerealStock = 0,
            sales = 0,
            powerOutageUntil = 0,
            customerRushUntil = 0,
            cartRecovered = false,
            shiftClosed = false,
        },
        ownedUpgrades = {
            shelfBay = false,
            warehouse = false,
            marketStyle = false,
            aisleExpansion = false,
            floorExpansion = false,
        },
        hiredEmployees = {
            cashier = false,
            stocker = false,
            cleaner = false,
            deliveryWorker = false,
            customerAssistant = false,
        },
        employeeAutomation = {
            cashier = true,
            stocker = true,
            cleaner = true,
            deliveryWorker = true,
        },
        warehouseInventory = {
            citrusPop = 12,
            berryBites = 0,
            goldenApples = 0,
            sunriseCereal = 0,
            shipmentReadyAt = 0,
            shipmentProductId = "",
        },
        warehouseLayout = { version = LayoutService.VERSION, items = {} },
        retailLayout = RetailLayoutService.default(),
        productPrices = {
            citrusPop = 25,
            berryBites = 18,
            goldenApples = 12,
            sunriseCereal = 16,
        },
        completedShifts = 0,
        customerSatisfaction = 75,
        lifetimeSales = 0,
    }
end

local function nonNegativeInteger(value, fallback)
    if type(value) ~= "number" or value ~= value then
        return fallback
    end
    return math.min(math.max(math.floor(value), 0), 1000000000)
end

local function validCounter(value)
    return value == nil
        or (type(value) == "number" and value == value and value >= 0 and value <= 1000000000)
end

local function validTimestamp(value)
    return value == nil
        or (
            type(value) == "number"
            and value == value
            and value >= 0
            and value <= 4102444800
            and value % 1 == 0
        )
end

local function validSchemaVersion(value)
    return type(value) == "number"
        and value == value
        and value >= 1
        and value <= 1000000
        and value % 1 == 0
end

local function normalizeProfile(value)
    local profile = defaultProfile()
    if value == nil then
        return profile
    end
    if type(value) ~= "table" then
        return nil, "Stored profile is malformed."
    end
    if value.schemaVersion ~= nil and not validSchemaVersion(value.schemaVersion) then
        return nil, "Stored profile version is malformed."
    end
    if type(value.schemaVersion) == "number" and value.schemaVersion > SCHEMA_VERSION then
        return nil, "This profile was saved by a newer game version."
    end
    if
        not validCounter(value.balance)
        or not validCounter(value.completedShifts)
        or not validCounter(value.lifetimeSales)
    then
        return nil, "Stored profile contains an invalid counter."
    end

    profile.balance = nonNegativeInteger(value.balance, 0)
    profile.completedShifts = nonNegativeInteger(value.completedShifts, 0)
    profile.lifetimeSales = nonNegativeInteger(value.lifetimeSales, 0)
    if
        value.customerSatisfaction ~= nil
        and (
            type(value.customerSatisfaction) ~= "number"
            or value.customerSatisfaction ~= value.customerSatisfaction
            or value.customerSatisfaction % 1 ~= 0
            or value.customerSatisfaction < 0
            or value.customerSatisfaction > 100
        )
    then
        return nil, "Stored customer satisfaction is outside the supported range."
    end
    profile.customerSatisfaction = value.customerSatisfaction or 75
    if value.productPrices ~= nil and type(value.productPrices) ~= "table" then
        return nil, "Stored product prices are malformed."
    end
    if type(value.productPrices) == "table" then
        local priceOptions = {
            citrusPop = { [20] = true, [25] = true, [32] = true },
            berryBites = { [14] = true, [18] = true, [23] = true },
            goldenApples = { [9] = true, [12] = true, [15] = true },
            sunriseCereal = { [12] = true, [16] = true, [20] = true },
        }
        for productId, price in pairs(value.productPrices) do
            if
                not priceOptions[productId]
                or type(price) ~= "number"
                or price ~= price
                or priceOptions[productId][price] ~= true
            then
                return nil, "Stored product price is outside the supported options."
            end
            profile.productPrices[productId] = price
        end
    end
    if value.ownedUpgrades ~= nil and type(value.ownedUpgrades) ~= "table" then
        return nil, "Stored upgrade data is malformed."
    end
    if type(value.ownedUpgrades) == "table" then
        if
            (
                value.ownedUpgrades.shelfBay ~= nil
                and type(value.ownedUpgrades.shelfBay) ~= "boolean"
            )
            or (value.ownedUpgrades.warehouse ~= nil and type(value.ownedUpgrades.warehouse) ~= "boolean")
            or (value.ownedUpgrades.aisleExpansion ~= nil and type(
                value.ownedUpgrades.aisleExpansion
            ) ~= "boolean")
            or (value.ownedUpgrades.floorExpansion ~= nil and type(
                value.ownedUpgrades.floorExpansion
            ) ~= "boolean")
            or (
                value.ownedUpgrades.marketStyle ~= nil
                and type(value.ownedUpgrades.marketStyle) ~= "boolean"
            )
        then
            return nil, "Stored upgrade flag is malformed."
        end
        profile.ownedUpgrades.shelfBay = value.ownedUpgrades.shelfBay == true
        profile.ownedUpgrades.warehouse = value.ownedUpgrades.warehouse == true
        profile.ownedUpgrades.marketStyle = value.ownedUpgrades.marketStyle == true
        profile.ownedUpgrades.aisleExpansion = value.ownedUpgrades.aisleExpansion == true
        profile.ownedUpgrades.floorExpansion = value.ownedUpgrades.floorExpansion == true
    end
    if profile.ownedUpgrades.aisleExpansion and not profile.ownedUpgrades.shelfBay then
        return nil, "Stored aisle expansion exists without the first shelf bay."
    end
    if profile.ownedUpgrades.floorExpansion and not profile.ownedUpgrades.aisleExpansion then
        return nil, "Stored floor expansion exists without the household aisle expansion."
    end
    local normalizedLayout, layoutError =
        LayoutService.normalize(value.warehouseLayout, profile.ownedUpgrades.warehouse)
    if not normalizedLayout then
        return nil, layoutError
    end
    profile.warehouseLayout = normalizedLayout
    local normalizedRetailLayout, retailLayoutError =
        RetailLayoutService.normalize(value.retailLayout, profile.ownedUpgrades.floorExpansion)
    if not normalizedRetailLayout then
        return nil, retailLayoutError
    end
    profile.retailLayout = normalizedRetailLayout
    if value.hiredEmployees ~= nil and type(value.hiredEmployees) ~= "table" then
        return nil, "Stored employee data is malformed."
    end
    if type(value.hiredEmployees) == "table" then
        if
            (
                value.hiredEmployees.cashier ~= nil
                and type(value.hiredEmployees.cashier) ~= "boolean"
            )
            or (value.hiredEmployees.stocker ~= nil and type(value.hiredEmployees.stocker) ~= "boolean")
            or (value.hiredEmployees.cleaner ~= nil and type(value.hiredEmployees.cleaner) ~= "boolean")
            or (value.hiredEmployees.deliveryWorker ~= nil and type(
                value.hiredEmployees.deliveryWorker
            ) ~= "boolean")
            or (
                value.hiredEmployees.customerAssistant ~= nil
                and type(value.hiredEmployees.customerAssistant) ~= "boolean"
            )
        then
            return nil, "Stored employee flag is malformed."
        end
        profile.hiredEmployees.cashier = value.hiredEmployees.cashier == true
        profile.hiredEmployees.stocker = value.hiredEmployees.stocker == true
        profile.hiredEmployees.cleaner = value.hiredEmployees.cleaner == true
        profile.hiredEmployees.deliveryWorker = value.hiredEmployees.deliveryWorker == true
        profile.hiredEmployees.customerAssistant = value.hiredEmployees.customerAssistant == true
    end
    if profile.hiredEmployees.deliveryWorker and not profile.ownedUpgrades.warehouse then
        return nil, "Stored delivery worker does not have warehouse ownership."
    end
    if value.employeeAutomation ~= nil and type(value.employeeAutomation) ~= "table" then
        return nil, "Stored employee automation settings are malformed."
    end
    if type(value.employeeAutomation) == "table" then
        if
            (
                value.employeeAutomation.cashier ~= nil
                and type(value.employeeAutomation.cashier) ~= "boolean"
            )
            or (value.employeeAutomation.stocker ~= nil and type(value.employeeAutomation.stocker) ~= "boolean")
            or (value.employeeAutomation.cleaner ~= nil and type(value.employeeAutomation.cleaner) ~= "boolean")
            or (
                value.employeeAutomation.deliveryWorker ~= nil
                and type(value.employeeAutomation.deliveryWorker) ~= "boolean"
            )
        then
            return nil, "Stored employee automation setting is invalid."
        end
        profile.employeeAutomation.cashier = value.employeeAutomation.cashier ~= false
        profile.employeeAutomation.stocker = value.employeeAutomation.stocker ~= false
        profile.employeeAutomation.cleaner = value.employeeAutomation.cleaner ~= false
        profile.employeeAutomation.deliveryWorker = value.employeeAutomation.deliveryWorker ~= false
    end
    if value.warehouseInventory ~= nil and type(value.warehouseInventory) ~= "table" then
        return nil, "Stored warehouse inventory is malformed."
    end
    if type(value.warehouseInventory) == "table" then
        local inventory = value.warehouseInventory
        if
            (inventory.citrusPop ~= nil and not validCounter(inventory.citrusPop))
            or (inventory.berryBites ~= nil and not validCounter(inventory.berryBites))
            or (inventory.goldenApples ~= nil and not validCounter(inventory.goldenApples))
            or (inventory.sunriseCereal ~= nil and not validCounter(inventory.sunriseCereal))
            or (inventory.shipmentReadyAt ~= nil and not validTimestamp(inventory.shipmentReadyAt))
            or (inventory.shipmentQuantity ~= nil and not validCounter(inventory.shipmentQuantity))
            or (
                inventory.shipmentProductId ~= nil
                and inventory.shipmentProductId ~= ""
                and inventory.shipmentProductId ~= "citrusPop"
                and inventory.shipmentProductId ~= "berryBites"
                and inventory.shipmentProductId ~= "goldenApples"
                and inventory.shipmentProductId ~= "sunriseCereal"
            )
        then
            return nil, "Stored warehouse inventory contains an invalid counter."
        end
        local citrusPop = nonNegativeInteger(inventory.citrusPop, 12)
        local berryBites =
            nonNegativeInteger(inventory.berryBites, profile.ownedUpgrades.warehouse and 12 or 0)
        local goldenApples =
            nonNegativeInteger(inventory.goldenApples, profile.ownedUpgrades.warehouse and 6 or 0)
        local sunriseCereal =
            nonNegativeInteger(inventory.sunriseCereal, profile.ownedUpgrades.warehouse and 6 or 0)
        local shipmentQuantity = nonNegativeInteger(inventory.shipmentQuantity, 0)
        local shipmentReadyAt = nonNegativeInteger(inventory.shipmentReadyAt, 0)
        if
            citrusPop > 500
            or berryBites > 500
            or goldenApples > 500
            or sunriseCereal > 500
            or (berryBites > 0 and profile.ownedUpgrades.warehouse ~= true)
            or (goldenApples > 0 and profile.ownedUpgrades.warehouse ~= true)
            or (sunriseCereal > 0 and profile.ownedUpgrades.warehouse ~= true)
            or shipmentQuantity > 60
            or (shipmentQuantity == 0) ~= (shipmentReadyAt == 0)
        then
            return nil, "Stored warehouse shipment is outside the supported limits."
        end
        if shipmentQuantity > 0 and profile.ownedUpgrades.warehouse ~= true then
            return nil, "Stored shipment exists without an owned warehouse."
        end
        profile.warehouseInventory.citrusPop = citrusPop
        profile.warehouseInventory.berryBites = berryBites
        profile.warehouseInventory.goldenApples = goldenApples
        profile.warehouseInventory.sunriseCereal = sunriseCereal
        profile.warehouseInventory.shipmentReadyAt = shipmentReadyAt
        profile.warehouseInventory.shipmentQuantity = shipmentQuantity
        profile.warehouseInventory.shipmentProductId = shipmentQuantity > 0
                and (inventory.shipmentProductId == "sunriseCereal" and "sunriseCereal" or (inventory.shipmentProductId == "goldenApples" and "goldenApples" or (inventory.shipmentProductId == "berryBites" and "berryBites" or "citrusPop")))
            or ""
    elseif profile.ownedUpgrades.warehouse then
        profile.warehouseInventory.berryBites = 12
        profile.warehouseInventory.goldenApples = 6
        profile.warehouseInventory.sunriseCereal = 6
    end
    if value.shift ~= nil and type(value.shift) ~= "table" then
        return nil, "Stored shift data is malformed."
    end
    if type(value.shift) == "table" then
        local stage = value.shift.stage
        if stage ~= nil then
            if
                stage ~= "Cart"
                and stage ~= "Stock"
                and stage ~= "Checkout"
                and stage ~= "Spill"
                and stage ~= "PowerOutage"
                and stage ~= "CustomerRush"
                and stage ~= "CloseShift"
                and stage ~= "Upgrade"
                and stage ~= "Complete"
            then
                return nil, "Stored shift stage is invalid."
            end
            profile.shift.stage = stage
        end
        if
            not validCounter(value.shift.stock)
            or not validCounter(value.shift.berryStock)
            or not validCounter(value.shift.goldenAppleStock)
            or not validCounter(value.shift.cerealStock)
            or not validCounter(value.shift.sales)
            or not validTimestamp(value.shift.powerOutageUntil)
            or not validTimestamp(value.shift.customerRushUntil)
        then
            return nil, "Stored shift counters are invalid."
        end
        if nonNegativeInteger(value.shift.berryStock, 0) > 24 then
            return nil, "Stored Berry Bites shelf stock is outside the supported limit."
        end
        if nonNegativeInteger(value.shift.stock, 0) > 24 then
            return nil, "Stored Citrus Pop shelf stock is outside the supported limit."
        end
        if nonNegativeInteger(value.shift.goldenAppleStock, 0) > 24 then
            return nil, "Stored Golden Apples shelf stock is outside the supported limit."
        end
        if nonNegativeInteger(value.shift.cerealStock, 0) > 24 then
            return nil, "Stored Sunrise Cereal shelf stock is outside the supported limit."
        end
        if
            nonNegativeInteger(value.shift.cerealStock, 0) > 0
            and profile.ownedUpgrades.warehouse ~= true
        then
            return nil, "Stored Sunrise Cereal shelf stock exists without an owned warehouse."
        end
        if
            nonNegativeInteger(value.shift.goldenAppleStock, 0) > 0
            and profile.ownedUpgrades.warehouse ~= true
        then
            return nil, "Stored Golden Apples shelf stock exists without an owned warehouse."
        end
        if nonNegativeInteger(value.shift.sales, 0) > 5 then
            return nil, "Stored shift sales are outside the supported limit."
        end
        local savedSales = nonNegativeInteger(value.shift.sales, 0)
        if
            (profile.shift.stage == "PowerOutage" and (savedSales < 1 or savedSales > 2))
            or (profile.shift.stage == "CustomerRush" and (savedSales < 3 or savedSales > 4))
        then
            return nil, "Stored chaos event does not match the saved shift progress."
        end
        if
            (value.shift.cartRecovered ~= nil and type(value.shift.cartRecovered) ~= "boolean")
            or (value.shift.shiftClosed ~= nil and type(value.shift.shiftClosed) ~= "boolean")
        then
            return nil, "Stored shift flags are malformed."
        end
        profile.shift.stock = nonNegativeInteger(value.shift.stock, 0)
        profile.shift.berryStock = nonNegativeInteger(value.shift.berryStock, 0)
        profile.shift.goldenAppleStock = nonNegativeInteger(value.shift.goldenAppleStock, 0)
        profile.shift.cerealStock = nonNegativeInteger(value.shift.cerealStock, 0)
        profile.shift.sales = nonNegativeInteger(value.shift.sales, 0)
        profile.shift.powerOutageUntil = nonNegativeInteger(value.shift.powerOutageUntil, 0)
        profile.shift.customerRushUntil = nonNegativeInteger(value.shift.customerRushUntil, 0)
        if
            (profile.shift.stage == "PowerOutage" and profile.shift.powerOutageUntil == 0)
            or (profile.shift.stage ~= "PowerOutage" and profile.shift.powerOutageUntil ~= 0)
            or (profile.shift.stage == "CustomerRush" and profile.shift.customerRushUntil == 0)
            or (profile.shift.stage ~= "CustomerRush" and profile.shift.customerRushUntil ~= 0)
        then
            return nil, "Stored power outage state is inconsistent."
        end
        profile.shift.cartRecovered = value.shift.cartRecovered == true
        profile.shift.shiftClosed = value.shift.shiftClosed == true
    end
    return profile
end

local function copyProfile(profile)
    local copy = {
        schemaVersion = SCHEMA_VERSION,
        balance = profile.balance,
        shift = {
            stage = profile.shift.stage,
            stock = profile.shift.stock,
            berryStock = profile.shift.berryStock,
            goldenAppleStock = profile.shift.goldenAppleStock,
            cerealStock = profile.shift.cerealStock,
            sales = profile.shift.sales,
            powerOutageUntil = profile.shift.powerOutageUntil,
            customerRushUntil = profile.shift.customerRushUntil,
            cartRecovered = profile.shift.cartRecovered,
            shiftClosed = profile.shift.shiftClosed,
        },
        ownedUpgrades = {
            shelfBay = profile.ownedUpgrades.shelfBay,
            warehouse = profile.ownedUpgrades.warehouse,
            marketStyle = profile.ownedUpgrades.marketStyle,
            aisleExpansion = profile.ownedUpgrades.aisleExpansion,
            floorExpansion = profile.ownedUpgrades.floorExpansion,
        },
        hiredEmployees = {
            cashier = profile.hiredEmployees.cashier,
            stocker = profile.hiredEmployees.stocker,
            cleaner = profile.hiredEmployees.cleaner,
            deliveryWorker = profile.hiredEmployees.deliveryWorker,
            customerAssistant = profile.hiredEmployees.customerAssistant,
        },
        employeeAutomation = {
            cashier = profile.employeeAutomation.cashier,
            stocker = profile.employeeAutomation.stocker,
            cleaner = profile.employeeAutomation.cleaner,
            deliveryWorker = profile.employeeAutomation.deliveryWorker,
        },
        warehouseInventory = {
            citrusPop = profile.warehouseInventory.citrusPop,
            berryBites = profile.warehouseInventory.berryBites,
            goldenApples = profile.warehouseInventory.goldenApples,
            sunriseCereal = profile.warehouseInventory.sunriseCereal,
            shipmentReadyAt = profile.warehouseInventory.shipmentReadyAt,
            shipmentQuantity = profile.warehouseInventory.shipmentQuantity or 0,
            shipmentProductId = profile.warehouseInventory.shipmentProductId or "",
        },
        warehouseLayout = {
            version = profile.warehouseLayout.version,
            items = {},
        },
        retailLayout = RetailLayoutService.default(),
        productPrices = {
            citrusPop = profile.productPrices.citrusPop,
            berryBites = profile.productPrices.berryBites,
            goldenApples = profile.productPrices.goldenApples,
            sunriseCereal = profile.productPrices.sunriseCereal,
        },
        completedShifts = profile.completedShifts,
        customerSatisfaction = profile.customerSatisfaction,
        lifetimeSales = profile.lifetimeSales,
    }
    for index, item in ipairs(profile.warehouseLayout.items) do
        copy.warehouseLayout.items[index] = {
            id = item.id,
            kind = item.kind,
            x = item.x,
            z = item.z,
            rotation = item.rotation,
        }
    end
    for productId, shelf in pairs(profile.retailLayout.shelves) do
        copy.retailLayout.shelves[productId] = {
            x = shelf.x,
            z = shelf.z,
            rotation = shelf.rotation,
        }
    end
    copy.retailLayout.checkout = {
        x = profile.retailLayout.checkout.x,
        z = profile.retailLayout.checkout.z,
        rotation = profile.retailLayout.checkout.rotation,
    }
    return copy
end

local function keyFor(player)
    return "Player_" .. tostring(player.UserId)
end

local function saveEntry(entry, releasing)
    while entry.saveInProgress do
        task.wait()
    end
    if not entry.persistent or entry.lockLost then
        return false
    end
    entry.saveInProgress = true
    local key = entry.key
    local lastError = "Unknown DataStore error"
    for attempt = 1, MAX_RETRIES do
        local ok, result = pcall(function()
            return store:UpdateAsync(key, function(current)
                if type(current) ~= "table" or type(current.session) ~= "table" then
                    return nil
                end
                if current.session.id ~= sessionId then
                    return nil
                end
                local updated = {
                    schemaVersion = SCHEMA_VERSION,
                    profile = copyProfile(entry.profile),
                }
                if not releasing then
                    updated.session = {
                        id = sessionId,
                        expiresAt = os.time() + SESSION_LEASE_SECONDS,
                    }
                end
                return updated
            end)
        end)
        if ok and type(result) == "table" then
            entry.saveStatus = "saved"
            entry.saveInProgress = false
            if releasing then
                entry.persistent = false
            end
            return true
        end
        if ok and result == nil then
            entry.lockLost = true
            entry.saveStatus = "lock lost"
            entry.saveInProgress = false
            return false
        end
        lastError = tostring(result)
        if attempt < MAX_RETRIES then
            task.wait(0.4 * (2 ^ (attempt - 1)) + math.random() * 0.25)
        end
    end
    entry.saveStatus = "save pending"
    entry.saveInProgress = false
    warn(string.format("Profile save failed for user %s: %s", entry.userId, lastError))
    return false
end

function ProfileService.load(player)
    local key = keyFor(player)
    if not storeReady then
        warn("DataStore unavailable; using session-only profile: " .. tostring(storeError))
        local profile = defaultProfile()
        profiles[player.UserId] = {
            userId = player.UserId,
            key = key,
            profile = profile,
            persistent = false,
            saveStatus = "session only",
            saveInProgress = false,
        }
        return profile, "session only"
    end

    local lastError
    for attempt = 1, MAX_RETRIES do
        local loadedProfile
        local ok, result = pcall(function()
            return store:UpdateAsync(key, function(current)
                local now = os.time()
                if
                    type(current) == "table"
                    and type(current.session) == "table"
                    and current.session.id ~= sessionId
                    and type(current.session.expiresAt) == "number"
                    and current.session.expiresAt > now
                then
                    return nil
                end

                local rawProfile
                if current ~= nil then
                    if type(current) ~= "table" or type(current.profile) ~= "table" then
                        error("Stored profile envelope is malformed.")
                    end
                    if
                        current.schemaVersion ~= nil
                        and not validSchemaVersion(current.schemaVersion)
                    then
                        error("Stored profile envelope version is malformed.")
                    end
                    if
                        type(current.schemaVersion) == "number"
                        and current.schemaVersion > SCHEMA_VERSION
                    then
                        error("This profile was saved by a newer game version.")
                    end
                    rawProfile = current.profile
                end

                local normalized, reason = normalizeProfile(rawProfile)
                if not normalized then
                    error(reason)
                end
                loadedProfile = normalized
                return {
                    schemaVersion = SCHEMA_VERSION,
                    profile = copyProfile(normalized),
                    session = {
                        id = sessionId,
                        expiresAt = now + SESSION_LEASE_SECONDS,
                    },
                }
            end)
        end)

        if ok and type(result) == "table" and loadedProfile then
            profiles[player.UserId] = {
                userId = player.UserId,
                key = key,
                profile = loadedProfile,
                persistent = true,
                lockLost = false,
                saveStatus = "saved",
                saveInProgress = false,
            }
            return loadedProfile, "saved"
        end
        if ok and result == nil then
            lastError = "Profile is active in another server. Rejoin after that session ends."
            break
        end
        lastError = tostring(result)
        if attempt < MAX_RETRIES then
            task.wait(0.4 * (2 ^ (attempt - 1)) + math.random() * 0.25)
        end
    end

    if string.find(lastError or "", "newer game version", 1, true) then
        return nil, lastError
    end
    if string.find(lastError or "", "active in another server", 1, true) then
        return nil, lastError
    end

    warn(
        string.format(
            "Profile load failed for user %s; using session-only profile: %s",
            player.UserId,
            lastError
        )
    )
    local profile = defaultProfile()
    profiles[player.UserId] = {
        userId = player.UserId,
        key = key,
        profile = profile,
        persistent = false,
        saveStatus = "session only",
        saveInProgress = false,
    }
    return profile, "session only"
end

function ProfileService.get(player)
    local entry = profiles[player.UserId]
    return entry and entry.profile or nil
end

function ProfileService.saveProgress(player, state, eventName)
    local entry = profiles[player.UserId]
    if not entry then
        return false
    end
    local profile = entry.profile
    profile.balance = state.cash
    profile.shift.stage = state.stage
    profile.shift.stock = state.stock
    profile.shift.berryStock = state.berryStock
    profile.shift.goldenAppleStock = state.goldenAppleStock
    profile.shift.cerealStock = state.cerealStock
    profile.shift.sales = state.sales
    profile.shift.powerOutageUntil = state.powerOutageUntil
    profile.shift.customerRushUntil = state.customerRushUntil
    profile.shift.cartRecovered = state.cartRecovered
    profile.shift.shiftClosed = state.shiftClosed
    profile.ownedUpgrades.shelfBay = state.upgradePurchased
    profile.ownedUpgrades.warehouse = state.warehousePurchased
    profile.ownedUpgrades.marketStyle = state.marketStylePurchased
    profile.ownedUpgrades.aisleExpansion = state.aisleExpansionPurchased
    profile.ownedUpgrades.floorExpansion = state.floorExpansionPurchased
    profile.warehouseLayout = state.warehouseLayout
    profile.retailLayout =
        RetailLayoutService.normalize(state.retailLayout, state.floorExpansionPurchased)
    profile.customerSatisfaction = math.min(math.max(state.customerSatisfaction or 75, 0), 100)
    profile.hiredEmployees.cashier = state.cashierHired
    profile.hiredEmployees.stocker = state.stockerHired
    profile.hiredEmployees.cleaner = state.cleanerHired
    profile.hiredEmployees.deliveryWorker = state.deliveryWorkerHired
    profile.hiredEmployees.customerAssistant = state.customerAssistantHired
    profile.employeeAutomation.cashier = state.cashierAutomationEnabled
    profile.employeeAutomation.stocker = state.stockerAutomationEnabled
    profile.employeeAutomation.cleaner = state.cleanerAutomationEnabled
    profile.employeeAutomation.deliveryWorker = state.deliveryWorkerAutomationEnabled
    profile.warehouseInventory.citrusPop = state.backstock
    profile.warehouseInventory.berryBites = state.berryBackstock
    profile.warehouseInventory.goldenApples = state.goldenAppleBackstock
    profile.warehouseInventory.sunriseCereal = state.cerealBackstock
    profile.warehouseInventory.shipmentReadyAt = state.shipmentReadyAt
    profile.warehouseInventory.shipmentQuantity = state.shipmentQuantity
    profile.warehouseInventory.shipmentProductId = state.shipmentProductId
    profile.productPrices = {
        citrusPop = state.productPrices.citrusPop,
        berryBites = state.productPrices.berryBites,
        goldenApples = state.productPrices.goldenApples,
        sunriseCereal = state.productPrices.sunriseCereal,
    }
    if eventName == "sale" then
        profile.lifetimeSales += 1
    elseif eventName == "shiftClosed" then
        profile.completedShifts += 1
    end
    if entry.persistent then
        return saveEntry(entry, false)
    end
    return false
end

function ProfileService.getSaveStatus(player)
    local entry = profiles[player.UserId]
    return entry and entry.saveStatus or "loading"
end

function ProfileService.release(player)
    local entry = profiles[player.UserId]
    if not entry then
        return
    end
    if entry.persistent then
        saveEntry(entry, true)
    end
    profiles[player.UserId] = nil
end

function ProfileService.releaseAll()
    for _, entry in pairs(profiles) do
        if entry.persistent then
            saveEntry(entry, true)
        end
    end
    profiles = {}
end

function ProfileService.startAutosave(onStatusChanged)
    task.spawn(function()
        while true do
            task.wait(60)
            for _, entry in pairs(profiles) do
                if entry.persistent then
                    local previousStatus = entry.saveStatus
                    saveEntry(entry, false)
                    if previousStatus ~= entry.saveStatus and onStatusChanged then
                        onStatusChanged(entry.userId)
                    end
                end
            end
        end
    end)
end

return ProfileService
