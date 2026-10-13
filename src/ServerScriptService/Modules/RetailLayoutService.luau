-- Pure validation for movable customer-facing department shelves.
local RetailLayoutService = {}

RetailLayoutService.VERSION = 6
RetailLayoutService.BASE_CONSTRUCTED_AISLES = 4
RetailLayoutService.MAX_CONSTRUCTED_AISLES = 6
RetailLayoutService.CORE_PRODUCT_IDS = {
    "citrusPop",
    "berryBites",
    "goldenApples",
    "sunriseCereal",
}
RetailLayoutService.EXPANSION_PRODUCT_IDS = { "cinnamonTwists", "frozenMeals" }
RetailLayoutService.PRODUCT_IDS = {
    "citrusPop",
    "berryBites",
    "goldenApples",
    "sunriseCereal",
    "cinnamonTwists",
    "frozenMeals",
}
RetailLayoutService.FIXTURE_IDS = { "shelfBay", "householdAisle" }

local DEFAULT_SHELVES = {
    citrusPop = { x = -10, z = -1, rotation = 0 },
    berryBites = { x = 10, z = -1, rotation = 0 },
    goldenApples = { x = -8, z = -9, rotation = 0 },
    sunriseCereal = { x = 0, z = -9, rotation = 0 },
}
local DEFAULT_CHECKOUT = { x = 14, z = 8, rotation = 0 }
local DEFAULT_EXPANSION_DEPARTMENTS = {
    cinnamonTwists = { x = 16, z = -29, rotation = 0 },
    frozenMeals = { x = 6, z = -29, rotation = 0 },
}
local DEFAULT_FIXTURES = {
    shelfBay = { x = -16, z = -8, rotation = 0 },
    householdAisle = { x = 16, z = -8, rotation = 0 },
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

function RetailLayoutService.isExpansionProductId(value)
    for _, productId in ipairs(RetailLayoutService.EXPANSION_PRODUCT_IDS) do
        if productId == value then
            return true
        end
    end
    return false
end

function RetailLayoutService.isCoreProductId(value)
    for _, productId in ipairs(RetailLayoutService.CORE_PRODUCT_IDS) do
        if productId == value then
            return true
        end
    end
    return false
end

function RetailLayoutService.isFixtureId(value)
    for _, fixtureId in ipairs(RetailLayoutService.FIXTURE_IDS) do
        if fixtureId == value then
            return true
        end
    end
    return false
end

function RetailLayoutService.isConstructedAisleId(value)
    return type(value) == "string"
        and #value == 36
        and string.match(
                value,
                "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"
            )
            ~= nil
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

local function retailFixtureHalfFootprint(rotation)
    return rotation == 0 and 4 or 1.2, rotation == 0 and 1.2 or 4
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
    if not RetailLayoutService.isCoreProductId(productId) then
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

local function canPlaceCheckout(
    shelves,
    x,
    z,
    rotation,
    fixtures,
    shelfBayPurchased,
    householdAislePurchased
)
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
    for fixtureId, placement in pairs(fixtures or {}) do
        local owned = fixtureId == "shelfBay" and shelfBayPurchased == true
            or fixtureId == "householdAisle" and householdAislePurchased == true
        if owned then
            local fixtureHalfX, fixtureHalfZ = retailFixtureHalfFootprint(placement.rotation)
            if
                minX < placement.x + fixtureHalfX + 0.25
                and maxX > placement.x - fixtureHalfX - 0.25
                and minZ < placement.z + fixtureHalfZ + 0.25
                and maxZ > placement.z - fixtureHalfZ - 0.25
            then
                return false, "Keep checkout and its queue clear of purchased fixtures."
            end
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
        departments = {
            cinnamonTwists = {
                x = DEFAULT_EXPANSION_DEPARTMENTS.cinnamonTwists.x,
                z = DEFAULT_EXPANSION_DEPARTMENTS.cinnamonTwists.z,
                rotation = DEFAULT_EXPANSION_DEPARTMENTS.cinnamonTwists.rotation,
            },
            frozenMeals = {
                x = DEFAULT_EXPANSION_DEPARTMENTS.frozenMeals.x,
                z = DEFAULT_EXPANSION_DEPARTMENTS.frozenMeals.z,
                rotation = DEFAULT_EXPANSION_DEPARTMENTS.frozenMeals.rotation,
            },
        },
        fixtures = {
            shelfBay = {
                x = DEFAULT_FIXTURES.shelfBay.x,
                z = DEFAULT_FIXTURES.shelfBay.z,
                rotation = DEFAULT_FIXTURES.shelfBay.rotation,
            },
            householdAisle = {
                x = DEFAULT_FIXTURES.householdAisle.x,
                z = DEFAULT_FIXTURES.householdAisle.z,
                rotation = DEFAULT_FIXTURES.householdAisle.rotation,
            },
        },
        aisles = {},
    }
end

function RetailLayoutService.normalize(
    value,
    expansionPurchased,
    bakeryPurchased,
    freezerPurchased,
    shelfBayPurchased,
    householdAislePurchased,
    retailPlotPurchased
)
    if value == nil then
        return RetailLayoutService.default()
    end
    if
        type(value) ~= "table"
        or (value.version ~= 1 and value.version ~= 2 and value.version ~= 3 and value.version ~= 4 and value.version ~= 5 and value.version ~= RetailLayoutService.VERSION)
        or type(value.shelves) ~= "table"
    then
        return nil, "Stored retail layout is malformed."
    end
    local keyCount = 0
    for productId in pairs(value.shelves) do
        keyCount += 1
        if not RetailLayoutService.isCoreProductId(productId) then
            return nil, "Stored retail layout contains an unknown product department."
        end
    end
    if keyCount ~= #RetailLayoutService.CORE_PRODUCT_IDS then
        return nil, "Stored retail layout is missing a product department."
    end

    local normalized = RetailLayoutService.default()
    if value.departments ~= nil and type(value.departments) ~= "table" then
        return nil, "Stored expansion departments are malformed."
    end
    local storedDepartments = type(value.departments) == "table" and value.departments or {}
    local departmentCount = 0
    for productId in pairs(storedDepartments) do
        departmentCount += 1
        if not RetailLayoutService.isExpansionProductId(productId) then
            return nil, "Stored layout contains an unknown expansion department."
        end
    end
    if departmentCount > #RetailLayoutService.EXPANSION_PRODUCT_IDS then
        return nil, "Stored layout contains too many expansion departments."
    end
    for _, productId in ipairs(RetailLayoutService.EXPANSION_PRODUCT_IDS) do
        local source = storedDepartments[productId] or DEFAULT_EXPANSION_DEPARTMENTS[productId]
        if
            type(source) ~= "table"
            or not finiteNumber(source.x)
            or not finiteNumber(source.z)
            or (source.rotation ~= 0 and source.rotation ~= 90)
        then
            return nil, "Stored expansion department position is malformed."
        end
        for key in pairs(source) do
            if key ~= "x" and key ~= "z" and key ~= "rotation" then
                return nil, "Stored expansion department contains an unsupported field."
            end
        end
        normalized.departments[productId] = {
            x = source.x,
            z = source.z,
            rotation = source.rotation,
        }
    end
    if value.fixtures ~= nil and type(value.fixtures) ~= "table" then
        return nil, "Stored retail fixtures are malformed."
    end
    local storedFixtures = type(value.fixtures) == "table" and value.fixtures or {}
    local fixtureCount = 0
    for fixtureId in pairs(storedFixtures) do
        fixtureCount += 1
        if not RetailLayoutService.isFixtureId(fixtureId) then
            return nil, "Stored retail layout contains an unknown movable fixture."
        end
    end
    if fixtureCount > #RetailLayoutService.FIXTURE_IDS then
        return nil, "Stored retail layout contains too many movable fixtures."
    end
    for _, fixtureId in ipairs(RetailLayoutService.FIXTURE_IDS) do
        local source = storedFixtures[fixtureId] or DEFAULT_FIXTURES[fixtureId]
        if
            type(source) ~= "table"
            or not finiteNumber(source.x)
            or not finiteNumber(source.z)
            or (source.rotation ~= 0 and source.rotation ~= 90)
        then
            return nil, "Stored movable fixture position is malformed."
        end
        for key in pairs(source) do
            if key ~= "x" and key ~= "z" and key ~= "rotation" then
                return nil, "Stored movable fixture contains an unsupported field."
            end
        end
        normalized.fixtures[fixtureId] = {
            x = source.x,
            z = source.z,
            rotation = source.rotation,
        }
    end
    if value.aisles ~= nil and type(value.aisles) ~= "table" then
        return nil, "Stored constructed aisles are malformed."
    end
    local storedAisles = type(value.aisles) == "table" and value.aisles or {}
    local aisleCount = 0
    for aisleId, placement in pairs(storedAisles) do
        aisleCount += 1
        if not RetailLayoutService.isConstructedAisleId(aisleId) or type(placement) ~= "table" then
            return nil, "Stored layout contains an invalid constructed aisle."
        end
        if
            not finiteNumber(placement.x)
            or not finiteNumber(placement.z)
            or (placement.rotation ~= 0 and placement.rotation ~= 90)
        then
            return nil, "Stored constructed aisle position is malformed."
        end
        local productId = placement.productId
        if value.version < RetailLayoutService.VERSION and productId == nil then
            productId = "citrusPop"
        end
        if not RetailLayoutService.isProductId(productId) then
            return nil, "Stored constructed aisle department is invalid."
        end
        if
            (productId == "cinnamonTwists" and bakeryPurchased ~= true)
            or (productId == "frozenMeals" and freezerPurchased ~= true)
        then
            return nil, "Stored constructed aisle department is not owned."
        end
        for key in pairs(placement) do
            if key ~= "x" and key ~= "z" and key ~= "rotation" and key ~= "productId" then
                return nil, "Stored constructed aisle contains an unsupported field."
            end
        end
        normalized.aisles[aisleId] = {
            x = placement.x,
            z = placement.z,
            rotation = placement.rotation,
            productId = productId,
        }
    end
    if aisleCount > RetailLayoutService.MAX_CONSTRUCTED_AISLES then
        return nil, "Stored retail layout contains too many constructed aisles."
    end
    if aisleCount > RetailLayoutService.BASE_CONSTRUCTED_AISLES and retailPlotPurchased ~= true then
        return nil, "Stored retail layout contains aisles without the purchased expansion plot."
    end
    for _, productId in ipairs(RetailLayoutService.CORE_PRODUCT_IDS) do
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
    for _, productId in ipairs(RetailLayoutService.CORE_PRODUCT_IDS) do
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
    local checkoutValid, checkoutReason = canPlaceCheckout(
        normalized.shelves,
        checkout.x,
        checkout.z,
        checkout.rotation,
        normalized.fixtures,
        shelfBayPurchased,
        householdAislePurchased
    )
    if not checkoutValid then
        -- Keep older/default profiles loadable if a former shelf placement occupies the new envelope.
        if value.version == 1 then
            normalized.checkout = RetailLayoutService.default().checkout
        else
            return nil, checkoutReason
        end
    end
    for _, productId in ipairs(RetailLayoutService.CORE_PRODUCT_IDS) do
        local shelf = normalized.shelves[productId]
        local shelfValid, shelfReason = RetailLayoutService.canPlace(
            normalized.shelves,
            productId,
            shelf.x,
            shelf.z,
            shelf.rotation,
            normalized.checkout,
            expansionPurchased,
            bakeryPurchased,
            freezerPurchased,
            normalized.departments,
            normalized.fixtures,
            shelfBayPurchased,
            householdAislePurchased,
            normalized.aisles
        )
        if not shelfValid then
            return nil, shelfReason
        end
    end
    for productId, purchased in pairs({
        cinnamonTwists = bakeryPurchased == true,
        frozenMeals = freezerPurchased == true,
    }) do
        if purchased then
            local valid, reason = RetailLayoutService.canPlaceDepartment(
                normalized,
                productId,
                normalized.departments[productId].x,
                normalized.departments[productId].z,
                normalized.departments[productId].rotation,
                expansionPurchased,
                bakeryPurchased,
                freezerPurchased,
                productId,
                shelfBayPurchased,
                householdAislePurchased
            )
            if not valid then
                return nil, reason
            end
        end
    end
    for _, fixtureId in ipairs(RetailLayoutService.FIXTURE_IDS) do
        local purchased = fixtureId == "shelfBay" and shelfBayPurchased == true
            or fixtureId == "householdAisle" and householdAislePurchased == true
        if purchased then
            local placement = normalized.fixtures[fixtureId]
            local valid, reason = RetailLayoutService.canPlaceFixture(
                normalized,
                fixtureId,
                placement.x,
                placement.z,
                placement.rotation,
                bakeryPurchased,
                freezerPurchased,
                shelfBayPurchased,
                householdAislePurchased,
                fixtureId
            )
            if not valid and value.version < RetailLayoutService.VERSION then
                local originalX, originalZ = placement.x, placement.z
                local candidates = {}
                for x = -18, 18, 2 do
                    for z = -16, -2, 2 do
                        table.insert(candidates, {
                            x = x,
                            z = z,
                            distance = math.abs(x - originalX) + math.abs(z - originalZ),
                        })
                    end
                end
                table.sort(candidates, function(left, right)
                    if left.distance == right.distance then
                        if left.x == right.x then
                            return left.z < right.z
                        end
                        return left.x < right.x
                    end
                    return left.distance < right.distance
                end)
                for _, candidate in ipairs(candidates) do
                    local candidateValid = RetailLayoutService.canPlaceFixture(
                        normalized,
                        fixtureId,
                        candidate.x,
                        candidate.z,
                        placement.rotation,
                        bakeryPurchased,
                        freezerPurchased,
                        shelfBayPurchased,
                        householdAislePurchased,
                        fixtureId
                    )
                    if candidateValid then
                        placement.x = candidate.x
                        placement.z = candidate.z
                        valid = true
                        break
                    end
                end
            end
            if not valid then
                return nil, reason
            end
        end
    end
    for aisleId, placement in pairs(normalized.aisles) do
        local valid, reason = RetailLayoutService.canPlaceConstructedAisle(
            normalized,
            aisleId,
            placement.x,
            placement.z,
            placement.rotation,
            expansionPurchased,
            bakeryPurchased,
            freezerPurchased,
            shelfBayPurchased,
            householdAislePurchased,
            aisleId,
            retailPlotPurchased
        )
        if not valid then
            return nil, reason
        end
    end
    return normalized
end

local function departmentFootprint(productId, rotation)
    local width, depth =
        productId == "cinnamonTwists" and 8 or 8.4, productId == "cinnamonTwists" and 8.6 or 7.6
    if rotation == 90 then
        width, depth = depth, width
    end
    return width / 2, depth / 2
end

local function overlapsConstructedAisle(layout, x, z, halfX, halfZ, excludedAisleId)
    for aisleId, placement in pairs(layout.aisles or {}) do
        if aisleId ~= excludedAisleId then
            local aisleHalfX, aisleHalfZ =
                placement.rotation == 0 and 4 or 1.2, placement.rotation == 0 and 1.2 or 4
            if
                math.abs(x - placement.x) < halfX + aisleHalfX + 0.25
                and math.abs(z - placement.z) < halfZ + aisleHalfZ + 0.25
            then
                return true
            end
        end
    end
    return false
end

function RetailLayoutService.canPlaceDepartment(
    layout,
    productId,
    x,
    z,
    rotation,
    expansionPurchased,
    bakeryPurchased,
    freezerPurchased,
    excludedProductId,
    shelfBayPurchased,
    householdAislePurchased
)
    if not RetailLayoutService.isExpansionProductId(productId) then
        return false, "Choose a built bakery or freezer department."
    end
    if not expansionPurchased then
        return false, "Build the rear floor expansion first."
    end
    if productId == "cinnamonTwists" and not bakeryPurchased then
        return false, "Build the bakery before moving its department."
    end
    if productId == "frozenMeals" and not freezerPurchased then
        return false, "Build the freezer before moving its department."
    end
    if
        not finiteNumber(x)
        or not finiteNumber(z)
        or x % 1 ~= 0
        or z % 1 ~= 0
        or x < -16
        or x > 16
        or (x + 16) % 2 ~= 0
        or z < -33
        or z > -21
        or (z + 33) % 2 ~= 0
        or (rotation ~= 0 and rotation ~= 90)
    then
        return false, "Choose a snapped position and 0 or 90 degree rotation inside the rear floor."
    end
    local halfX, halfZ = departmentFootprint(productId, rotation)
    if x - halfX < -20.5 or x + halfX > 20.5 or z - halfZ < -39.5 or z + halfZ > -18.5 then
        return false, "Keep the department fixture inside the expanded floor."
    end
    if overlapsConstructedAisle(layout, x, z, halfX, halfZ) then
        return false, "Keep the department fixture clear of constructed grocery aisles."
    end
    local fixtureLayout = layout.departments
    local checkoutMinX, checkoutMaxX, checkoutMinZ, checkoutMaxZ =
        checkoutEnvelope(layout.checkout.x, layout.checkout.z, layout.checkout.rotation)
    if
        x - halfX < checkoutMaxX + 0.25
        and x + halfX > checkoutMinX - 0.25
        and z - halfZ < checkoutMaxZ + 0.25
        and z + halfZ > checkoutMinZ - 0.25
    then
        return false, "Keep expansion departments clear of checkout and its queue."
    end
    for _, coreProductId in ipairs(RetailLayoutService.CORE_PRODUCT_IDS) do
        local shelf = layout.shelves[coreProductId]
        local otherHalfX, otherHalfZ = halfFootprint(coreProductId, shelf.rotation)
        if
            math.abs(x - shelf.x) < halfX + otherHalfX + 0.25
            and math.abs(z - shelf.z) < halfZ + otherHalfZ + 0.25
        then
            return false, "Keep expansion departments clear of other product shelves."
        end
    end
    for fixtureId, placement in pairs(layout.fixtures or {}) do
        local fixtureOwned = fixtureId == "shelfBay" and shelfBayPurchased == true
            or fixtureId == "householdAisle" and householdAislePurchased == true
        if fixtureOwned then
            local fixtureHalfX, fixtureHalfZ = retailFixtureHalfFootprint(placement.rotation)
            if
                math.abs(x - placement.x) < halfX + fixtureHalfX + 0.25
                and math.abs(z - placement.z) < halfZ + fixtureHalfZ + 0.25
            then
                return false, "Keep expansion departments clear of the purchased shelf fixtures."
            end
        end
    end
    for otherProductId, other in pairs(fixtureLayout) do
        local otherOwned = otherProductId == "cinnamonTwists" and bakeryPurchased
            or otherProductId == "frozenMeals" and freezerPurchased
        if otherOwned and otherProductId ~= excludedProductId then
            local otherX, otherZ = departmentFootprint(otherProductId, other.rotation)
            if
                math.abs(x - other.x) < halfX + otherX + 0.25
                and math.abs(z - other.z) < halfZ + otherZ + 0.25
            then
                return false, "Keep the department fixtures from overlapping one another."
            end
        end
    end
    return true
end

function RetailLayoutService.canPlaceFixture(
    layout,
    fixtureId,
    x,
    z,
    rotation,
    bakeryPurchased,
    freezerPurchased,
    shelfBayPurchased,
    householdAislePurchased,
    excludedFixtureId
)
    if not RetailLayoutService.isFixtureId(fixtureId) then
        return false, "Choose a purchased shelf bay or household aisle."
    end
    local owned = fixtureId == "shelfBay" and shelfBayPurchased == true
        or fixtureId == "householdAisle" and householdAislePurchased == true
    if not owned then
        return false, "Build this fixture before moving it."
    end
    if
        not finiteNumber(x)
        or not finiteNumber(z)
        or x % 1 ~= 0
        or z % 1 ~= 0
        or x < -18
        or x > 18
        or x % 2 ~= 0
        or z < -16
        or z > -2
        or (z + 16) % 2 ~= 0
        or (rotation ~= 0 and rotation ~= 90)
    then
        return false, "Choose a snapped position and 0 or 90 degree rotation on the main floor."
    end
    local halfX, halfZ = retailFixtureHalfFootprint(rotation)
    if x - halfX < -20.5 or x + halfX > 20.5 or z - halfZ < -18.5 or z + halfZ > 16.5 then
        return false, "Keep the fixture inside the main store floor."
    end
    if overlapsConstructedAisle(layout, x, z, halfX, halfZ) then
        return false, "Keep purchased fixtures clear of constructed grocery aisles."
    end
    local minX, maxX, minZ, maxZ =
        checkoutEnvelope(layout.checkout.x, layout.checkout.z, layout.checkout.rotation)
    if
        x - halfX < maxX + 0.25
        and x + halfX > minX - 0.25
        and z - halfZ < maxZ + 0.25
        and z + halfZ > minZ - 0.25
    then
        return false, "Keep the fixture clear of checkout and its customer queue."
    end
    for _, productId in ipairs(RetailLayoutService.CORE_PRODUCT_IDS) do
        local shelf = layout.shelves[productId]
        local shelfHalfX, shelfHalfZ = halfFootprint(productId, shelf.rotation)
        if
            math.abs(x - shelf.x) < halfX + shelfHalfX + 0.25
            and math.abs(z - shelf.z) < halfZ + shelfHalfZ + 0.25
        then
            return false, "Keep fixtures clear of product department shelves."
        end
    end
    for productId, placement in pairs(layout.departments or {}) do
        local departmentOwned = productId == "cinnamonTwists" and bakeryPurchased == true
            or productId == "frozenMeals" and freezerPurchased == true
        if departmentOwned then
            local departmentHalfX, departmentHalfZ =
                departmentFootprint(productId, placement.rotation)
            if
                math.abs(x - placement.x) < halfX + departmentHalfX + 0.25
                and math.abs(z - placement.z) < halfZ + departmentHalfZ + 0.25
            then
                return false, "Keep fixtures clear of the bakery and freezer departments."
            end
        end
    end
    for otherFixtureId, placement in pairs(layout.fixtures or {}) do
        local otherOwned = otherFixtureId == "shelfBay" and shelfBayPurchased == true
            or otherFixtureId == "householdAisle" and householdAislePurchased == true
        if otherOwned and otherFixtureId ~= excludedFixtureId then
            local otherHalfX, otherHalfZ = retailFixtureHalfFootprint(placement.rotation)
            if
                math.abs(x - placement.x) < halfX + otherHalfX + 0.25
                and math.abs(z - placement.z) < halfZ + otherHalfZ + 0.25
            then
                return false, "Keep purchased fixtures from overlapping."
            end
        end
    end
    return true
end

function RetailLayoutService.canPlaceConstructedAisle(
    layout,
    aisleId,
    x,
    z,
    rotation,
    expansionPurchased,
    bakeryPurchased,
    freezerPurchased,
    shelfBayPurchased,
    householdAislePurchased,
    excludedAisleId,
    retailPlotPurchased
)
    if not RetailLayoutService.isConstructedAisleId(aisleId) then
        return false, "That constructed aisle ID is invalid."
    end
    if
        not finiteNumber(x)
        or not finiteNumber(z)
        or x % 2 ~= 0
        or z % 2 ~= 0
        or x < -14
        or x > 14
        or (rotation ~= 0 and rotation ~= 90)
    then
        return false, "Choose a snapped position and 0 or 90 degree rotation inside the store."
    end
    local retailPlot = z <= -42
    local rearWing = z <= -20 and not retailPlot
    if retailPlot then
        if not retailPlotPurchased or z < -60 then
            return false, "Purchase the retail expansion plot before placing an aisle there."
        end
    elseif rearWing then
        if not expansionPurchased or z < -34 then
            return false, "Build the rear wing before placing an aisle in that zone."
        end
    elseif z < -16 or z > 14 then
        return false, "Choose a snapped position inside the marked retail floor."
    end
    local halfX, halfZ = rotation == 0 and 4 or 1.2, rotation == 0 and 1.2 or 4
    local minimumFloorZ = retailPlot and -63.5 or (rearWing and -39.5 or -18.5)
    local maximumFloorZ = retailPlot and -41.5 or (rearWing and -18.5 or 16.5)
    if
        x - halfX < -20.5
        or x + halfX > 20.5
        or z - halfZ < minimumFloorZ
        or z + halfZ > maximumFloorZ
    then
        return false, "Keep the constructed aisle inside the store floor."
    end

    local function overlapsAt(otherX, otherZ, otherHalfX, otherHalfZ, gap)
        local clearance = gap or 0.25
        return math.abs(x - otherX) < halfX + otherHalfX + clearance
            and math.abs(z - otherZ) < halfZ + otherHalfZ + clearance
    end

    local checkoutMinX, checkoutMaxX, checkoutMinZ, checkoutMaxZ =
        checkoutEnvelope(layout.checkout.x, layout.checkout.z, layout.checkout.rotation)
    if
        x - halfX < checkoutMaxX + 0.25
        and x + halfX > checkoutMinX - 0.25
        and z - halfZ < checkoutMaxZ + 0.25
        and z + halfZ > checkoutMinZ - 0.25
    then
        return false, "Keep the constructed aisle clear of checkout and its queue."
    end
    for _, productId in ipairs(RetailLayoutService.CORE_PRODUCT_IDS) do
        local shelf = layout.shelves[productId]
        local shelfHalfX, shelfHalfZ = halfFootprint(productId, shelf.rotation)
        if overlapsAt(shelf.x, shelf.z, shelfHalfX, shelfHalfZ) then
            return false, "Keep the constructed aisle clear of product shelves."
        end
    end
    for productId, placement in pairs(layout.departments or {}) do
        local owned = productId == "cinnamonTwists" and bakeryPurchased == true
            or productId == "frozenMeals" and freezerPurchased == true
        if owned then
            local departmentHalfX, departmentHalfZ =
                departmentFootprint(productId, placement.rotation)
            if overlapsAt(placement.x, placement.z, departmentHalfX, departmentHalfZ) then
                return false, "Keep the constructed aisle clear of bakery and freezer departments."
            end
        end
    end
    for fixtureId, placement in pairs(layout.fixtures or {}) do
        local owned = fixtureId == "shelfBay" and shelfBayPurchased == true
            or fixtureId == "householdAisle" and householdAislePurchased == true
        if owned then
            local fixtureHalfX, fixtureHalfZ = retailFixtureHalfFootprint(placement.rotation)
            if overlapsAt(placement.x, placement.z, fixtureHalfX, fixtureHalfZ) then
                return false, "Keep the constructed aisle clear of purchased shelf fixtures."
            end
        end
    end
    for otherId, placement in pairs(layout.aisles or {}) do
        if otherId ~= excludedAisleId then
            local otherHalfX, otherHalfZ =
                placement.rotation == 0 and 4 or 1.2, placement.rotation == 0 and 1.2 or 4
            if overlapsAt(placement.x, placement.z, otherHalfX, otherHalfZ) then
                return false, "Keep constructed aisles from overlapping one another."
            end
        end
    end
    if not rearWing then
        -- Keep the produce island, display chiller and layout/upgrade boards accessible.
        if overlapsAt(-13, 8, 3.5, 1.5, 0.25) then
            return false, "Keep the aisle clear of the fresh-produce island."
        end
        if overlapsAt(9, -14.5, 3.8, 2, 0.25) then
            return false, "Keep the aisle clear of the refrigerated display."
        end
        if overlapsAt(-17.5, 12.5, 3, 3, 0.25) or overlapsAt(17.5, 12.5, 3, 3, 0.25) then
            return false, "Keep the aisle clear of the store upgrade boards."
        end
    end
    return true
end

function RetailLayoutService.canPlace(
    shelves,
    productId,
    x,
    z,
    rotation,
    checkout,
    expansionPurchased,
    bakeryPurchased,
    freezerPurchased,
    departments,
    fixtures,
    shelfBayPurchased,
    householdAislePurchased,
    aisles
)
    local valid, reason =
        canPlace(shelves, productId, x, z, rotation, productId, expansionPurchased)
    if not valid then
        return false, reason
    end
    for departmentId, placement in pairs(departments or {}) do
        local departmentOwned = departmentId == "cinnamonTwists" and bakeryPurchased == true
            or departmentId == "frozenMeals" and freezerPurchased == true
        if departmentOwned then
            local halfX, halfZ = departmentFootprint(departmentId, placement.rotation)
            local shelfHalfX, shelfHalfZ = halfFootprint(productId, rotation)
            if
                math.abs(x - placement.x) < halfX + shelfHalfX + 0.25
                and math.abs(z - placement.z) < halfZ + shelfHalfZ + 0.25
            then
                return false, "Keep product shelves clear of the built expansion departments."
            end
        end
    end
    for fixtureId, placement in pairs(fixtures or {}) do
        local fixtureOwned = fixtureId == "shelfBay" and shelfBayPurchased == true
            or fixtureId == "householdAisle" and householdAislePurchased == true
        if fixtureOwned then
            local halfX, halfZ = retailFixtureHalfFootprint(placement.rotation)
            local shelfHalfX, shelfHalfZ = halfFootprint(productId, rotation)
            if
                math.abs(x - placement.x) < halfX + shelfHalfX + 0.25
                and math.abs(z - placement.z) < halfZ + shelfHalfZ + 0.25
            then
                return false, "Keep product shelves clear of purchased fixtures."
            end
        end
    end
    local shelfHalfX, shelfHalfZ = halfFootprint(productId, rotation)
    if overlapsConstructedAisle({ aisles = aisles or {} }, x, z, shelfHalfX, shelfHalfZ) then
        return false, "Keep product shelves clear of constructed grocery aisles."
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

function RetailLayoutService.canPlaceCheckout(
    shelves,
    x,
    z,
    rotation,
    fixtures,
    shelfBayPurchased,
    householdAislePurchased,
    aisles
)
    local valid, reason = canPlaceCheckout(
        shelves,
        x,
        z,
        rotation,
        fixtures,
        shelfBayPurchased,
        householdAislePurchased
    )
    if not valid then
        return false, reason
    end
    local minX, maxX, minZ, maxZ = checkoutEnvelope(x, z, rotation)
    for _, placement in pairs(aisles or {}) do
        local halfX, halfZ =
            placement.rotation == 0 and 4 or 1.2, placement.rotation == 0 and 1.2 or 4
        if
            minX < placement.x + halfX + 0.25
            and maxX > placement.x - halfX - 0.25
            and minZ < placement.z + halfZ + 0.25
            and maxZ > placement.z - halfZ - 0.25
        then
            return false, "Keep checkout and its queue clear of constructed grocery aisles."
        end
    end
    return true
end

return RetailLayoutService
