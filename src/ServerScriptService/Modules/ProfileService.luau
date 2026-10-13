-- Per-player save profiles with a server-side lease. All callers are server code.
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local ProfileService = {}

local SCHEMA_VERSION = 5
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
            sales = 0,
            cartRecovered = false,
            shiftClosed = false,
        },
        ownedUpgrades = {
            shelfBay = false,
            warehouse = false,
        },
        hiredEmployees = {
            cashier = false,
            stocker = false,
        },
        warehouseInventory = {
            citrusPop = 12,
            shipmentReadyAt = 0,
        },
        completedShifts = 0,
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
    if value.ownedUpgrades ~= nil and type(value.ownedUpgrades) ~= "table" then
        return nil, "Stored upgrade data is malformed."
    end
    if type(value.ownedUpgrades) == "table" then
        if
            (
                value.ownedUpgrades.shelfBay ~= nil
                and type(value.ownedUpgrades.shelfBay) ~= "boolean"
            )
            or (
                value.ownedUpgrades.warehouse ~= nil
                and type(value.ownedUpgrades.warehouse) ~= "boolean"
            )
        then
            return nil, "Stored upgrade flag is malformed."
        end
        profile.ownedUpgrades.shelfBay = value.ownedUpgrades.shelfBay == true
        profile.ownedUpgrades.warehouse = value.ownedUpgrades.warehouse == true
    end
    if value.hiredEmployees ~= nil and type(value.hiredEmployees) ~= "table" then
        return nil, "Stored employee data is malformed."
    end
    if type(value.hiredEmployees) == "table" then
        if
            (
                value.hiredEmployees.cashier ~= nil
                and type(value.hiredEmployees.cashier) ~= "boolean"
            )
            or (
                value.hiredEmployees.stocker ~= nil
                and type(value.hiredEmployees.stocker) ~= "boolean"
            )
        then
            return nil, "Stored employee flag is malformed."
        end
        profile.hiredEmployees.cashier = value.hiredEmployees.cashier == true
        profile.hiredEmployees.stocker = value.hiredEmployees.stocker == true
    end
    if value.warehouseInventory ~= nil and type(value.warehouseInventory) ~= "table" then
        return nil, "Stored warehouse inventory is malformed."
    end
    if type(value.warehouseInventory) == "table" then
        local inventory = value.warehouseInventory
        if
            (inventory.citrusPop ~= nil and not validCounter(inventory.citrusPop))
            or (inventory.shipmentReadyAt ~= nil and not validTimestamp(inventory.shipmentReadyAt))
            or (inventory.shipmentQuantity ~= nil and not validCounter(inventory.shipmentQuantity))
        then
            return nil, "Stored warehouse inventory contains an invalid counter."
        end
        local citrusPop = nonNegativeInteger(inventory.citrusPop, 12)
        local shipmentQuantity = nonNegativeInteger(inventory.shipmentQuantity, 0)
        local shipmentReadyAt = nonNegativeInteger(inventory.shipmentReadyAt, 0)
        if
            citrusPop > 500
            or shipmentQuantity > 60
            or (shipmentQuantity == 0) ~= (shipmentReadyAt == 0)
        then
            return nil, "Stored warehouse shipment is outside the supported limits."
        end
        if shipmentQuantity > 0 and profile.ownedUpgrades.warehouse ~= true then
            return nil, "Stored shipment exists without an owned warehouse."
        end
        profile.warehouseInventory.citrusPop = citrusPop
        profile.warehouseInventory.shipmentReadyAt = shipmentReadyAt
        profile.warehouseInventory.shipmentQuantity = shipmentQuantity
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
                and stage ~= "CloseShift"
                and stage ~= "Upgrade"
                and stage ~= "Complete"
            then
                return nil, "Stored shift stage is invalid."
            end
            profile.shift.stage = stage
        end
        if not validCounter(value.shift.stock) or not validCounter(value.shift.sales) then
            return nil, "Stored shift counters are invalid."
        end
        if
            (value.shift.cartRecovered ~= nil and type(value.shift.cartRecovered) ~= "boolean")
            or (value.shift.shiftClosed ~= nil and type(value.shift.shiftClosed) ~= "boolean")
        then
            return nil, "Stored shift flags are malformed."
        end
        profile.shift.stock = nonNegativeInteger(value.shift.stock, 0)
        profile.shift.sales = nonNegativeInteger(value.shift.sales, 0)
        profile.shift.cartRecovered = value.shift.cartRecovered == true
        profile.shift.shiftClosed = value.shift.shiftClosed == true
    end
    return profile
end

local function copyProfile(profile)
    return {
        schemaVersion = SCHEMA_VERSION,
        balance = profile.balance,
        shift = {
            stage = profile.shift.stage,
            stock = profile.shift.stock,
            sales = profile.shift.sales,
            cartRecovered = profile.shift.cartRecovered,
            shiftClosed = profile.shift.shiftClosed,
        },
        ownedUpgrades = {
            shelfBay = profile.ownedUpgrades.shelfBay,
            warehouse = profile.ownedUpgrades.warehouse,
        },
        hiredEmployees = {
            cashier = profile.hiredEmployees.cashier,
            stocker = profile.hiredEmployees.stocker,
        },
        warehouseInventory = {
            citrusPop = profile.warehouseInventory.citrusPop,
            shipmentReadyAt = profile.warehouseInventory.shipmentReadyAt,
            shipmentQuantity = profile.warehouseInventory.shipmentQuantity or 0,
        },
        completedShifts = profile.completedShifts,
        lifetimeSales = profile.lifetimeSales,
    }
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
    profile.shift.sales = state.sales
    profile.shift.cartRecovered = state.cartRecovered
    profile.shift.shiftClosed = state.shiftClosed
    profile.ownedUpgrades.shelfBay = state.upgradePurchased
    profile.ownedUpgrades.warehouse = state.warehousePurchased
    profile.hiredEmployees.cashier = state.cashierHired
    profile.hiredEmployees.stocker = state.stockerHired
    profile.warehouseInventory.citrusPop = state.backstock
    profile.warehouseInventory.shipmentReadyAt = state.shipmentReadyAt
    profile.warehouseInventory.shipmentQuantity = state.shipmentQuantity
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
