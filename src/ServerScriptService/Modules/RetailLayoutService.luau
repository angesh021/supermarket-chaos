-- Pure validation for movable customer-facing department shelves.
local RetailLayoutService = {}

RetailLayoutService.VERSION = 1
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

local function canPlace(shelves, productId, x, z, rotation, excludedProductId)
    if not RetailLayoutService.isProductId(productId) then
        return false, "Choose one of the four installed product departments."
    end
    if not validGrid(x, -12, 12) or not validGrid(z, -9, -1) then
        return false, "Choose a snapped position inside the marked retail floor zone."
    end
    if rotation ~= 0 and rotation ~= 90 then
        return false, "Shelf rotation must be 0 or 90 degrees."
    end
    local halfX, halfZ = halfFootprint(productId, rotation)
    if x - halfX < -20.5 or x + halfX > 20.5 or z - halfZ < -18.5 or z + halfZ > 16.5 then
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

function RetailLayoutService.default()
    local shelves = {}
    for productId, position in pairs(DEFAULT_SHELVES) do
        shelves[productId] = {
            x = position.x,
            z = position.z,
            rotation = position.rotation,
        }
    end
    return { version = RetailLayoutService.VERSION, shelves = shelves }
end

function RetailLayoutService.normalize(value)
    if value == nil then
        return RetailLayoutService.default()
    end
    if
        type(value) ~= "table"
        or value.version ~= RetailLayoutService.VERSION
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
        local valid, reason =
            canPlace(normalized.shelves, productId, shelf.x, shelf.z, shelf.rotation, productId)
        if not valid then
            return nil, reason
        end
    end
    return normalized
end

function RetailLayoutService.canPlace(shelves, productId, x, z, rotation)
    return canPlace(shelves, productId, x, z, rotation, productId)
end

return RetailLayoutService
