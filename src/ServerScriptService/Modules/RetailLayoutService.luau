-- Pure validation for movable customer-facing department shelves.
local RetailLayoutService = {}

RetailLayoutService.VERSION = 2
RetailLayoutService.PRODUCT_IDS = {
    "citrusPop",
    "berryBites",
    "goldenApples",
    "sunriseCereal",
}

local DEFAULT_SHELVES = {
    citrusPop = { x = -10, z = -1, rotation = 0 },
    berryBites = { x = 10, z = -1, rotation = 0 },
    goldenApples = { x = -8, z = -9, rotation = 0 },
    sunriseCereal = { x = 0, z = -9, rotation = 0 },
}
local DEFAULT_CHECKOUT = { x = 14, z = 8, rotation = 0 }

local function finiteNumber(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

function RetailLayoutService.isProductId(value)
    for _, productId in ipairs(RetailLayoutService.PRODUCT_IDS) do
        if productId == value then
            return true
        end
    end
    return false
end

local function validGrid(value, minimum, maximum)
    return finiteNumber(value)
        and value % 1 == 0
        and value >= minimum
        and value <= maximum
        and (value - minimum) % 2 == 0
end

local function halfFootprint(productId, rotation)
    local width = productId == "goldenApples" and 4 or 6
    if rotation == 0 then
        return width / 2, 1.1
    end
    return 1.1, width / 2
end

local function overlaps(x, z, productId, rotation, otherX, otherZ, otherProductId, otherRotation)
    local halfX, halfZ = halfFootprint(productId, rotation)
    local otherHalfX, otherHalfZ = halfFootprint(otherProductId, otherRotation)
    return math.abs(x - otherX) < halfX + otherHalfX + 0.2
        and math.abs(z - otherZ) < halfZ + otherHalfZ + 0.2
end

local function validRetailZone(x, z, expansionPurchased)
    if validGrid(x, -12, 12) and validGrid(z, -9, -1) then
        return true
    end
    return expansionPurchased == true and validGrid(x, -12, 12) and validGrid(z, -33, -21)
end

local function canPlace(shelves, productId, x, z, rotation, excludedProductId, expansionPurchased)
    if not RetailLayoutService.isProductId(productId) then
        return false, "Choose one of the four installed product departments."
    end
    if not validRetailZone(x, z, expansionPurchased) then
        return false, "Choose a snapped position inside the marked retail floor zone."
    end
    if rotation ~= 0 and rotation ~= 90 then
        return false, "Shelf rotation must be 0 or 90 degrees."
    end
    local halfX, halfZ = halfFootprint(productId, rotation)
    local minimumFloorZ = expansionPurchased == true and z < -17 and -39.5 or -18.5
    if x - halfX < -20.5 or x + halfX > 20.5 or z - halfZ < minimumFloorZ or z + halfZ > 16.5 then
        return false, "The rotated shelf must stay inside the store floor."
    end

    -- Fixed expansion bays occupy these reserved positions regardless of purchase state.
    for _, expansionX in ipairs({ -16, 16 }) do
        if overlaps(x, z, productId, rotation, expansionX, -8, "citrusPop", 0) then
            return false, "Keep the original and household expansion bays clear."
        end
    end
    for otherProductId, other in pairs(shelves) do
        if otherProductId ~= excludedProductId and otherProductId ~= productId then
            if
                overlaps(
                    x,
                    z,
                    productId,
                    rotation,
                    other.x,
                    other.z,
                    otherProductId,
                    other.rotation
                )
            then
                return false, "That department shelf would overlap another product shelf."
            end
        end
    end
    return true
end

local function checkoutEnvelope(x, z, rotation)
    -- Covers the register and the five customer queue slots in the same rotated fixture.
    local points = {
        { -4, -1.75 },
        { 4, -1.75 },
        { -4, 7.5 },
        { 4, 7.5 },
        { 3.5, -4 },
        { 3.5, 0 },
        { 3.5, 4 },
        { 3.5, 7 },
        { 0, 7 },
    }
    local minX, maxX, minZ, maxZ
    for _, point in ipairs(points) do
        local offsetX, offsetZ = point[1], point[2]
        if rotation == 90 then
            offsetX, offsetZ = -offsetZ, offsetX
        end
        local pointX, pointZ = x + offsetX, z + offsetZ
        minX = minX and math.min(minX, pointX) or pointX
        maxX = maxX and math.max(maxX, pointX) or pointX
        minZ = minZ and math.min(minZ, pointZ) or pointZ
        maxZ = maxZ and math.max(maxZ, pointZ) or pointZ
    end
    -- Register bounds are wider than the queue point cloud.
    local registerHalfX, registerHalfZ = rotation == 0 and 4 or 1.75, rotation == 0 and 1.75 or 4
    minX = math.min(minX, x - registerHalfX)
    maxX = math.max(maxX, x + registerHalfX)
    minZ = math.min(minZ, z - registerHalfZ)
    maxZ = math.max(maxZ, z + registerHalfZ)
    return minX, maxX, minZ, maxZ
end

local function canPlaceCheckout(shelves, x, z, rotation)
    if not validGrid(x, -14, 14) or not validGrid(z, 6, 12) then
        return false, "Choose a snapped checkout position inside the marked front-floor zone."
    end
    if rotation ~= 0 and rotation ~= 90 then
        return false, "Checkout rotation must be 0 or 90 degrees."
    end
    local minX, maxX, minZ, maxZ = checkoutEnvelope(x, z, rotation)
    if minX < -20.5 or maxX > 20.5 or minZ < -18.5 or maxZ > 16.5 then
        return false, "The checkout and customer queue must stay inside the store floor."
    end
    for productId, shelf in pairs(shelves) do
        local halfX, halfZ = halfFootprint(productId, shelf.rotation)
        if
            minX < shelf.x + halfX + 0.25
            and maxX > shelf.x - halfX - 0.25
            and minZ < shelf.z + halfZ + 0.25
            and maxZ > shelf.z - halfZ - 0.25
        then
            return false, "Keep the checkout lane and queue clear of department shelves."
        end
    end
    -- The produce island occupies the front-left of the store. The layout station is at the far left.
    if minX < -7.2 and maxX > -18.8 and minZ < 10 and maxZ > 6.4 then
        return false, "Keep the checkout lane clear of the fresh produce island."
    end
    if minX < -16.4 and maxX > -20.5 and minZ < 12.2 and maxZ > 8.8 then
        return false, "Keep the checkout lane clear of the retail layout station."
    end
    return true
end

function RetailLayoutService.default()
    local shelves = {}
    for productId, position in pairs(DEFAULT_SHELVES) do
        shelves[productId] = {
            x = position.x,
            z = position.z,
            rotation = position.rotation,
        }
    end
    return {
        version = RetailLayoutService.VERSION,
        shelves = shelves,
        checkout = {
            x = DEFAULT_CHECKOUT.x,
            z = DEFAULT_CHECKOUT.z,
            rotation = DEFAULT_CHECKOUT.rotation,
        },
    }
end

function RetailLayoutService.normalize(value, expansionPurchased)
    if value == nil then
        return RetailLayoutService.default()
    end
    if
        type(value) ~= "table"
        or (value.version ~= 1 and value.version ~= RetailLayoutService.VERSION)
        or type(value.shelves) ~= "table"
    then
        return nil, "Stored retail layout is malformed."
    end
    local keyCount = 0
    for productId in pairs(value.shelves) do
        keyCount += 1
        if not RetailLayoutService.isProductId(productId) then
            return nil, "Stored retail layout contains an unknown product department."
        end
    end
    if keyCount ~= #RetailLayoutService.PRODUCT_IDS then
        return nil, "Stored retail layout is missing a product department."
    end

    local normalized = RetailLayoutService.default()
    for _, productId in ipairs(RetailLayoutService.PRODUCT_IDS) do
        local source = value.shelves[productId]
        if type(source) ~= "table" then
            return nil, "Stored retail shelf is malformed."
        end
        local shelf = { x = source.x, z = source.z, rotation = source.rotation }
        if
            not finiteNumber(shelf.x)
            or not finiteNumber(shelf.z)
            or (shelf.rotation ~= 0 and shelf.rotation ~= 90)
        then
            return nil, "Stored retail shelf coordinates or rotation are invalid."
        end
        normalized.shelves[productId] = shelf
    end
    for _, productId in ipairs(RetailLayoutService.PRODUCT_IDS) do
        local shelf = normalized.shelves[productId]
        local valid, reason = canPlace(
            normalized.shelves,
            productId,
            shelf.x,
            shelf.z,
            shelf.rotation,
            productId,
            expansionPurchased
        )
        if not valid then
            return nil, reason
        end
    end
    local checkout = value.checkout or DEFAULT_CHECKOUT
    if
        type(checkout) ~= "table"
        or not finiteNumber(checkout.x)
        or not finiteNumber(checkout.z)
        or (checkout.rotation ~= 0 and checkout.rotation ~= 90)
    then
        return nil, "Stored checkout position or rotation is invalid."
    end
    normalized.checkout = { x = checkout.x, z = checkout.z, rotation = checkout.rotation }
    local checkoutValid, checkoutReason =
        canPlaceCheckout(normalized.shelves, checkout.x, checkout.z, checkout.rotation)
    if not checkoutValid then
        -- Keep older/default profiles loadable if a former shelf placement occupies the new envelope.
        if value.version == 1 then
            normalized.checkout = RetailLayoutService.default().checkout
        else
            return nil, checkoutReason
        end
    end
    for _, productId in ipairs(RetailLayoutService.PRODUCT_IDS) do
        local shelf = normalized.shelves[productId]
        local shelfValid, shelfReason = RetailLayoutService.canPlace(
            normalized.shelves,
            productId,
            shelf.x,
            shelf.z,
            shelf.rotation,
            normalized.checkout,
            expansionPurchased
        )
        if not shelfValid then
            return nil, shelfReason
        end
    end
    return normalized
end

function RetailLayoutService.canPlace(
    shelves,
    productId,
    x,
    z,
    rotation,
    checkout,
    expansionPurchased
)
    local valid, reason =
        canPlace(shelves, productId, x, z, rotation, productId, expansionPurchased)
    if not valid then
        return false, reason
    end
    if type(checkout) == "table" then
        local minX, maxX, minZ, maxZ = checkoutEnvelope(checkout.x, checkout.z, checkout.rotation)
        local halfX, halfZ = halfFootprint(productId, rotation)
        if
            x - halfX < maxX + 0.25
            and x + halfX > minX - 0.25
            and z - halfZ < maxZ + 0.25
            and z + halfZ > minZ - 0.25
        then
            return false, "Keep department shelves clear of the checkout lane and customer queue."
        end
    end
    return true
end

function RetailLayoutService.canPlaceCheckout(shelves, x, z, rotation)
    return canPlaceCheckout(shelves, x, z, rotation)
end

return RetailLayoutService
