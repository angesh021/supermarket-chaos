-- Pure validation for compact, server-owned warehouse layout records.
local LayoutService = {}

LayoutService.VERSION = 1
LayoutService.MAX_SHELVES = 6
LayoutService.SHELF_COST = 50
LayoutService.SHELF_REFUND = 25

local function finiteNumber(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function isGridCoordinate(value, minimum, maximum)
    return finiteNumber(value)
        and value % 1 == 0
        and value >= minimum
        and value <= maximum
        and (value - minimum) % 2 == 0
end

local function footprint(rotation)
    if rotation == 0 then
        return 3, 1.1
    end
    return 1.1, 3
end

local function validId(id)
    if type(id) ~= "string" or #id ~= 36 then
        return false
    end
    for index = 1, 36 do
        local character = string.sub(id, index, index)
        if index == 9 or index == 14 or index == 19 or index == 24 then
            if character ~= "-" then
                return false
            end
        elseif not string.match(character, "^[%x]$") then
            return false
        end
    end
    return true
end

local function validPlacement(items, x, z, rotation, excludedId)
    if not isGridCoordinate(x, 53, 65) or not isGridCoordinate(z, -6, 2) then
        return false, "Choose a shelf position inside the marked warehouse build zone."
    end
    if rotation ~= 0 and rotation ~= 90 then
        return false, "Shelf rotation must be 0 or 90 degrees."
    end
    local halfX, halfZ = footprint(rotation)
    if x - halfX < 49.95 or x + halfX > 68.05 or z - halfZ < -8.2 or z + halfZ > 4.2 then
        return false, "The rotated shelf footprint must stay inside the warehouse floor."
    end
    if math.abs(x - 59) < halfX + 2.5 + 0.2 and math.abs(z - 4.2) < halfZ + 0.15 + 0.2 then
        return false, "Keep shelves clear of the warehouse layout board and entrance."
    end
    for _, item in ipairs(items) do
        if item.id ~= excludedId then
            local otherHalfX, otherHalfZ = footprint(item.rotation)
            if
                math.abs(x - item.x) < halfX + otherHalfX + 0.2
                and math.abs(z - item.z) < halfZ + otherHalfZ + 0.2
            then
                return false, "That shelf would overlap another fixture."
            end
        end
    end
    return true
end

function LayoutService.normalize(value, hasWarehouse)
    if value == nil then
        return { version = LayoutService.VERSION, items = {} }
    end
    if
        type(value) ~= "table"
        or value.version ~= LayoutService.VERSION
        or type(value.items) ~= "table"
    then
        return nil, "Stored warehouse layout is malformed."
    end
    local count = #value.items
    local keyCount = 0
    for key in pairs(value.items) do
        keyCount += 1
        if type(key) ~= "number" or key % 1 ~= 0 or key < 1 or key > count then
            return nil, "Stored warehouse layout has invalid item indexes."
        end
    end
    if keyCount ~= count or count > LayoutService.MAX_SHELVES then
        return nil, "Stored warehouse layout exceeds its item limit."
    end
    if count > 0 and not hasWarehouse then
        return nil, "Stored warehouse fixtures exist without warehouse ownership."
    end

    local normalized = { version = LayoutService.VERSION, items = {} }
    local ids = {}
    for index, rawItem in ipairs(value.items) do
        if
            type(rawItem) ~= "table"
            or not validId(rawItem.id)
            or rawItem.kind ~= "Shelf"
            or ids[rawItem.id]
        then
            return nil, "Stored warehouse fixture is malformed."
        end
        local item = {
            id = rawItem.id,
            kind = "Shelf",
            x = rawItem.x,
            z = rawItem.z,
            rotation = rawItem.rotation,
        }
        local ok, reason = validPlacement(normalized.items, item.x, item.z, item.rotation)
        if not ok then
            return nil, reason
        end
        normalized.items[index] = item
        ids[item.id] = true
    end
    return normalized
end

function LayoutService.canPlace(items, x, z, rotation, excludedId)
    return validPlacement(items, x, z, rotation, excludedId)
end

function LayoutService.find(items, id)
    if not validId(id) then
        return nil
    end
    for index, item in ipairs(items) do
        if item.id == id then
            return index, item
        end
    end
    return nil
end

return LayoutService
