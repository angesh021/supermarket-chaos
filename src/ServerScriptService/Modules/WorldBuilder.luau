local WorldBuilder = {}
WorldBuilder.UPTOWN_ORIGIN = CFrame.new(360, 0, 0)
local TweenService = game:GetService("TweenService")
local Economy = require(script.Parent.Economy)

local COLORS = {
    teal = Color3.fromRGB(22, 79, 82),
    deepTeal = Color3.fromRGB(17, 57, 61),
    cream = Color3.fromRGB(249, 239, 216),
    warmWhite = Color3.fromRGB(255, 250, 235),
    green = Color3.fromRGB(96, 157, 98),
    coral = Color3.fromRGB(226, 119, 104),
    gold = Color3.fromRGB(222, 177, 87),
    wood = Color3.fromRGB(139, 93, 61),
    gray = Color3.fromRGB(164, 172, 169),
    blue = Color3.fromRGB(153, 202, 216),
    road = Color3.fromRGB(55, 61, 63),
    ink = Color3.fromRGB(36, 48, 49),
    orange = Color3.fromRGB(239, 146, 73),
    paleGreen = Color3.fromRGB(190, 211, 151),
}

local function part(parent, name, size, cframe, color, material, transparency)
    local item = Instance.new("Part")
    item.Name = name
    item.Anchored = true
    item.Size = size
    item.CFrame = cframe
    item.Color = color
    item.Material = material or Enum.Material.SmoothPlastic
    item.TopSurface = Enum.SurfaceType.Smooth
    item.BottomSurface = Enum.SurfaceType.Smooth
    item.Transparency = transparency or 0
    item.Parent = parent
    return item
end

local function prompt(parent, action, object, key, distance)
    local item = Instance.new("ProximityPrompt")
    item.ActionText = action
    item.ObjectText = object
    item.KeyboardKeyCode = Enum.KeyCode.E
    item.GamepadKeyCode = Enum.KeyCode.ButtonX
    item.HoldDuration = 0
    item.MaxActivationDistance = distance or 9
    item.RequiresLineOfSight = false
    item.ClickablePrompt = true
    item:SetAttribute("ActionId", key)
    item.Parent = parent
    return item
end

local function label(parent, name, text, size, cframe, color, textColor)
    local board = part(parent, name, size, cframe, color, Enum.Material.SmoothPlastic)
    local surface = Instance.new("SurfaceGui")
    -- Signage is mounted with its readable face toward the store approach (+Z).
    surface.Face = Enum.NormalId.Back
    surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    surface.PixelsPerStud = 32
    surface.Parent = board
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = textColor or COLORS.warmWhite
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextScaled = true
    textLabel.Parent = surface
    return board
end

local function createShelf(parent, name, x, z, width, department, rotation)
    local shelf = Instance.new("Model")
    shelf.Name = name
    shelf.Parent = parent
    local origin = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(rotation or 0), 0)
    local function fixture(partName, size, offset, color, material)
        return part(shelf, partName, size, origin * CFrame.new(offset), color, material)
    end
    fixture(
        "Wooden Kick Plate",
        Vector3.new(width, 0.6, 2.2),
        Vector3.new(0, 1.2, 0),
        COLORS.wood,
        Enum.Material.WoodPlanks
    )
    fixture(
        "Retail Gondola Back",
        Vector3.new(width, 5.4, 0.35),
        Vector3.new(0, 4, 0),
        COLORS.cream,
        Enum.Material.Metal
    )
    for _, side in ipairs({ -1, 1 }) do
        fixture(
            "Gondola Upright",
            Vector3.new(0.18, 5.9, 0.25),
            Vector3.new(side * (width / 2 - 0.12), 4, 0.1),
            COLORS.gray,
            Enum.Material.Metal
        )
    end
    for level = 1, 3 do
        local shelfY = 1.9 + level * 1.3
        fixture(
            "Shelf",
            Vector3.new(width + 0.15, 0.22, 2.0),
            Vector3.new(0, shelfY, 0),
            COLORS.warmWhite,
            Enum.Material.Metal
        )
        fixture(
            "Shelf Edge Price Rail",
            Vector3.new(width, 0.16, 0.12),
            Vector3.new(0, shelfY + 0.12, -1.02),
            COLORS.blue,
            Enum.Material.SmoothPlastic
        )
    end
    for index = 1, 6 do
        local productColor = ({ COLORS.coral, COLORS.green, COLORS.orange, COLORS.blue })[((index - 1) % 4) + 1]
        local px = x - width / 2 + index * (width / 7)
        for level = 1, 3 do
            local packageY = 2.35 + level * 1.3
            local package = part(
                shelf,
                (department or "Grocery") .. " Product Pack",
                Vector3.new(0.62, 0.82, 0.58),
                CFrame.new(px, packageY, z - 0.54),
                productColor,
                Enum.Material.SmoothPlastic
            )
            package:SetAttribute("ProductDisplay", true)
            part(
                shelf,
                "Package Front Label",
                Vector3.new(0.38, 0.28, 0.025),
                CFrame.new(px, packageY, z - 0.237),
                COLORS.warmWhite,
                Enum.Material.SmoothPlastic
            ):SetAttribute("ProductDisplay", true)
        end
    end
    label(
        shelf,
        "Aisle Department Sign",
        string.upper(department or "GROCERIES"),
        Vector3.new(width, 1.15, 0.28),
        CFrame.new(x, 7.35, z - 1.18),
        COLORS.deepTeal,
        COLORS.warmWhite
    )
    local aisleHeader = part(
        shelf,
        "Suspended Aisle Wayfinding Sign",
        Vector3.new(width, 0.88, 0.22),
        CFrame.new(x, 9.05, z - 1.12),
        COLORS.deepTeal,
        Enum.Material.SmoothPlastic
    )
    aisleHeader:SetAttribute("MarketPaletteRole", "DepartmentSign")
    local aisleHeaderGui = Instance.new("SurfaceGui")
    aisleHeaderGui.Name = "AisleWayfindingGui"
    aisleHeaderGui.Face = Enum.NormalId.Back
    aisleHeaderGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    aisleHeaderGui.PixelsPerStud = 40
    aisleHeaderGui.Parent = aisleHeader
    local aisleHeaderText = Instance.new("TextLabel")
    aisleHeaderText.Size = UDim2.fromScale(1, 1)
    aisleHeaderText.BackgroundTransparency = 1
    aisleHeaderText.Text = string.upper(department or "GROCERIES")
    aisleHeaderText.TextColor3 = COLORS.warmWhite
    aisleHeaderText.Font = Enum.Font.GothamBold
    aisleHeaderText.TextScaled = true
    aisleHeaderText.Parent = aisleHeaderGui
    for _, side in ipairs({ -1, 1 }) do
        part(
            shelf,
            "Aisle Wayfinding Sign Support",
            Vector3.new(0.12, 0.9, 0.12),
            CFrame.new(x + side * (width / 2 - 0.2), 8.55, z - 1.12),
            COLORS.gray,
            Enum.Material.Metal
        )
    end
    shelf.PrimaryPart = shelf:FindFirstChild("Wooden Kick Plate")
    shelf:PivotTo(origin * CFrame.new(0, 1.2, 0))
    return shelf
end

local function createRefrigeratedCase(parent, x, z)
    local case = Instance.new("Model")
    case.Name = "Glass-Door Refrigerated Drinks Case"
    case.Parent = parent
    part(
        case,
        "Refrigerator Base",
        Vector3.new(7, 2.1, 3.3),
        CFrame.new(x, 1.55, z),
        COLORS.deepTeal,
        Enum.Material.Metal
    )
    part(
        case,
        "Refrigerator Canopy",
        Vector3.new(7.2, 0.45, 3.5),
        CFrame.new(x, 5.3, z),
        COLORS.teal,
        Enum.Material.Metal
    )
    for level = 1, 3 do
        part(
            case,
            "Refrigerated Shelf",
            Vector3.new(6.4, 0.12, 2.45),
            CFrame.new(x, 1.75 + level * 0.85, z - 0.25),
            COLORS.gray,
            Enum.Material.Metal
        )
        for index = 1, 6 do
            local bottleX = x - 2.8 + (index - 1) * 1.12
            local bottle = part(
                case,
                "Chilled Drink Bottle",
                Vector3.new(0.52, 0.62, 0.5),
                CFrame.new(bottleX, 2.05 + level * 0.85, z - 0.7),
                ({ COLORS.orange, COLORS.green, COLORS.coral, COLORS.blue })[((index + level - 2) % 4) + 1],
                Enum.Material.SmoothPlastic
            )
            part(
                case,
                "Bottle Cap",
                Vector3.new(0.28, 0.12, 0.28),
                CFrame.new(bottleX, 2.42 + level * 0.85, z - 0.7),
                COLORS.warmWhite,
                Enum.Material.SmoothPlastic
            ).Shape =
                Enum.PartType.Cylinder
            bottle:SetAttribute("ProductDisplay", true)
        end
    end
    local glass = part(
        case,
        "Refrigerator Glass Doors",
        Vector3.new(6.65, 2.45, 0.12),
        CFrame.new(x, 3.84, z + 1.62),
        COLORS.blue,
        Enum.Material.Glass,
        0.58
    )
    glass.CanCollide = false
    for _, offset in ipairs({ -3.35, 0, 3.35 }) do
        part(
            case,
            "Refrigerator Door Frame",
            Vector3.new(0.12, 2.5, 0.18),
            CFrame.new(x + offset, 3.84, z + 1.68),
            COLORS.gray,
            Enum.Material.Metal
        )
    end
    for _, side in ipairs({ -1, 1 }) do
        local sideGlass = part(
            case,
            "Refrigerator Side Glass",
            Vector3.new(0.12, 2.4, 2.8),
            CFrame.new(x + side * 3.45, 3.82, z),
            COLORS.blue,
            Enum.Material.Glass,
            0.62
        )
        sideGlass.CanCollide = false
    end
    label(
        case,
        "Cold Drinks Header",
        "COLD DRINKS",
        Vector3.new(7, 1.1, 0.3),
        CFrame.new(x, 6.2, z + 1.55),
        COLORS.deepTeal,
        COLORS.warmWhite
    )
    return case
end

local function createTree(parent, x, z)
    part(
        parent,
        "Tree Trunk",
        Vector3.new(1, 5, 1),
        CFrame.new(x, 2.5, z),
        COLORS.wood,
        Enum.Material.Wood
    )
    local crown = part(
        parent,
        "Tree Crown",
        Vector3.new(5.8, 5.8, 5.8),
        CFrame.new(x, 6.5, z),
        COLORS.green,
        Enum.Material.Grass
    )
    crown.Shape = Enum.PartType.Ball
end

local function createStreetlight(parent, x, z)
    part(
        parent,
        "Commercial Avenue Lamp Post",
        Vector3.new(0.35, 11, 0.35),
        CFrame.new(x, 5.5, z),
        COLORS.ink,
        Enum.Material.Metal
    )
    part(
        parent,
        "Commercial Avenue Lamp Arm",
        Vector3.new(2.4, 0.25, 0.25),
        CFrame.new(x + 1, 10.8, z),
        COLORS.ink,
        Enum.Material.Metal
    )
    local lamp = part(
        parent,
        "Commercial Avenue LED Lantern",
        Vector3.new(1.4, 0.3, 0.8),
        CFrame.new(x + 2, 10.65, z),
        COLORS.warmWhite,
        Enum.Material.Neon
    )
    lamp.CanCollide = false
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 231, 177)
    light.Brightness = 1.2
    light.Range = 22
    light.Shadows = false
    light.Parent = lamp
end

local function createNeighborhoodStorefront(parent, name, center, accent, signText)
    local building = Instance.new("Model")
    building.Name = name
    building.Parent = parent
    part(
        building,
        "Shop Foundation",
        Vector3.new(20, 0.4, 15),
        CFrame.new(center + Vector3.new(0, 0.2, 0)),
        COLORS.gray,
        Enum.Material.Concrete
    )
    part(
        building,
        "Shop Rear Wall",
        Vector3.new(20, 7, 0.55),
        CFrame.new(center + Vector3.new(0, 3.7, -7.2)),
        COLORS.cream,
        Enum.Material.Brick
    )
    for _, side in ipairs({ -1, 1 }) do
        part(
            building,
            "Shop Side Wall",
            Vector3.new(0.55, 7, 15),
            CFrame.new(center + Vector3.new(side * 9.7, 3.7, 0)),
            COLORS.cream,
            Enum.Material.Brick
        )
    end
    for _, xOffset in ipairs({ -9.7, 9.7 }) do
        part(
            building,
            "Shop Front Pier",
            Vector3.new(0.55, 7, 0.55),
            CFrame.new(center + Vector3.new(xOffset, 3.7, 7.2)),
            COLORS.cream,
            Enum.Material.Brick
        )
    end
    part(
        building,
        "Shop Front Header",
        Vector3.new(19.4, 1.5, 0.55),
        CFrame.new(center + Vector3.new(0, 6.45, 7.2)),
        accent,
        Enum.Material.SmoothPlastic
    )
    for _, xOffset in ipairs({ -6.4, 6.4 }) do
        local window = part(
            building,
            "Shop Display Window",
            Vector3.new(5.3, 4.4, 0.16),
            CFrame.new(center + Vector3.new(xOffset, 3.35, 7.2)),
            COLORS.blue,
            Enum.Material.Glass,
            0.35
        )
        window.CanCollide = false
    end
    local door = part(
        building,
        "Shop Glass Entry Door",
        Vector3.new(2.7, 5.3, 0.16),
        CFrame.new(center + Vector3.new(0, 2.85, 7.2)),
        COLORS.blue,
        Enum.Material.Glass,
        0.4
    )
    door.CanCollide = false
    part(
        building,
        "Shop Roof",
        Vector3.new(21, 0.55, 16),
        CFrame.new(center + Vector3.new(0, 7.45, 0)),
        accent,
        Enum.Material.Metal
    )
    label(
        building,
        "Neighborhood Shop Sign",
        signText,
        Vector3.new(14, 1.2, 0.3),
        CFrame.new(center + Vector3.new(0, 8.6, 7.45)),
        accent,
        COLORS.warmWhite
    )
    for _, xOffset in ipairs({ -6, 0, 6 }) do
        local planter = part(
            building,
            "Shopfront Planter",
            Vector3.new(2.6, 0.7, 1.4),
            CFrame.new(center + Vector3.new(xOffset, 0.55, 9.3)),
            COLORS.wood,
            Enum.Material.WoodPlanks
        )
        planter.CanCollide = false
        local shrub = part(
            building,
            "Shopfront Shrub",
            Vector3.new(1.7, 1.1, 1.1),
            CFrame.new(center + Vector3.new(xOffset, 1.35, 9.3)),
            COLORS.green,
            Enum.Material.Grass
        )
        shrub.Shape = Enum.PartType.Ball
        shrub.CanCollide = false
    end
    building.PrimaryPart = building:FindFirstChild("Shop Foundation")
    return building
end

local function createLowPolyPerson(
    parent,
    name,
    position,
    shirtColor,
    pantsColor,
    hairColor,
    isShopper
)
    local person = Instance.new("Model")
    person.Name = name
    person.Parent = parent
    local skinColor = Color3.fromRGB(238, 192, 158)
    local function bodyPart(partName, size, offset, color, material)
        local body = part(
            person,
            partName,
            size,
            CFrame.new(position + offset),
            color,
            material or Enum.Material.SmoothPlastic
        )
        body.CanCollide = false
        return body
    end
    bodyPart("Pants", Vector3.new(1.05, 0.45, 0.72), Vector3.new(0, 1.15, 0), pantsColor)
    for _, side in ipairs({ -1, 1 }) do
        bodyPart(
            "Trouser Leg",
            Vector3.new(0.48, 1.05, 0.58),
            Vector3.new(side * 0.3, 0.62, 0),
            pantsColor
        )
        bodyPart(
            "Sneaker",
            Vector3.new(0.58, 0.28, 0.78),
            Vector3.new(side * 0.3, 0.16, 0.08),
            COLORS.warmWhite
        )
        bodyPart(
            "Sleeve and Arm",
            Vector3.new(0.43, 1.42, 0.54),
            Vector3.new(side * 0.9, 2.0, 0),
            shirtColor
        )
        bodyPart(
            "Hand",
            Vector3.new(0.42, 0.38, 0.42),
            Vector3.new(side * 0.9, 1.12, 0.02),
            skinColor
        )
    end
    bodyPart("Uniform Shirt", Vector3.new(1.38, 1.58, 0.78), Vector3.new(0, 2.02, 0), shirtColor)
    bodyPart("Collar", Vector3.new(0.45, 0.18, 0.08), Vector3.new(0, 2.77, 0.42), COLORS.warmWhite)
    bodyPart("Head", Vector3.new(1.12, 1.12, 1.02), Vector3.new(0, 3.45, 0), skinColor)
    bodyPart("Hair", Vector3.new(1.18, 0.34, 1.08), Vector3.new(0, 4.05, -0.02), hairColor)
    for _, side in ipairs({ -1, 1 }) do
        bodyPart(
            "Eye",
            Vector3.new(0.11, 0.12, 0.05),
            Vector3.new(side * 0.22, 3.5, 0.53),
            COLORS.ink
        )
    end
    bodyPart("Smile", Vector3.new(0.24, 0.055, 0.05), Vector3.new(0, 3.22, 0.53), COLORS.coral)
    if isShopper then
        local basketColor = Color3.fromRGB(196, 73, 59)
        local basketOffset = Vector3.new(0, 1.02, 0.53)
        local function basketPart(partName, size, offset, color, material)
            return bodyPart(
                partName,
                size,
                basketOffset + offset,
                color or basketColor,
                material or Enum.Material.SmoothPlastic
            )
        end
        basketPart("Customer Hand Basket Base", Vector3.new(0.92, 0.12, 0.66), Vector3.zero)
        for _, side in ipairs({ -1, 1 }) do
            basketPart(
                "Customer Hand Basket Side",
                Vector3.new(0.1, 0.44, 0.66),
                Vector3.new(side * 0.41, 0.26, 0)
            )
        end
        for _, side in ipairs({ -1, 1 }) do
            basketPart(
                "Customer Hand Basket End",
                Vector3.new(0.82, 0.44, 0.1),
                Vector3.new(0, 0.26, side * 0.28)
            )
        end
        basketPart(
            "Customer Hand Basket Handle",
            Vector3.new(0.1, 0.54, 0.1),
            Vector3.new(0, 0.48, -0.04),
            COLORS.gray,
            Enum.Material.Metal
        )
        for index, itemColor in ipairs({ COLORS.green, COLORS.gold, COLORS.blue }) do
            local item = basketPart(
                "Customer Basket Grocery",
                Vector3.new(0.22, 0.22, 0.24),
                Vector3.new(-0.24 + (index - 1) * 0.24, 0.24, 0.12),
                itemColor
            )
            item:SetAttribute("ProductDisplay", true)
        end
    end
    return person
end

function WorldBuilder.build(locationId, origin)
    locationId = locationId or "neighborhood"
    if
        type(locationId) ~= "string"
        or #locationId > 32
        or string.match(locationId, "^[%w_%-]+$") == nil
    then
        error("WorldBuilder requires a server-approved location ID.")
    end
    origin = origin or CFrame.new()
    if typeof(origin) ~= "CFrame" then
        error("WorldBuilder origin must be a CFrame.")
    end
    local customerAssistantHired = false
    local worldName = locationId == "neighborhood" and "SupermarketChaosWorld"
        or "SupermarketChaosWorld_" .. locationId
    local previous = workspace:FindFirstChild(worldName)
    if previous then
        previous:Destroy()
    end

    local world = Instance.new("Model")
    world.Name = worldName
    world:SetAttribute("LocationId", locationId)
    world.Parent = workspace
    local exterior = Instance.new("Folder")
    exterior.Name = "Exterior"
    exterior.Parent = world
    local interior = Instance.new("Folder")
    interior.Name = "StoreInterior"
    interior.Parent = world

    -- A compact neighborhood block with a clear player approach to the entrance.
    part(
        exterior,
        "Neighborhood Ground",
        Vector3.new(250, 1, 250),
        CFrame.new(0, -0.6, -30),
        Color3.fromRGB(111, 145, 111),
        Enum.Material.Grass
    )
    part(
        exterior,
        "Street",
        Vector3.new(180, 0.2, 20),
        CFrame.new(0, 0.02, 43),
        COLORS.road,
        Enum.Material.Asphalt
    )
    part(
        exterior,
        "Sidewalk",
        Vector3.new(120, 0.35, 12),
        CFrame.new(0, 0.18, 29),
        COLORS.gray,
        Enum.Material.Concrete
    )
    for x = -46, 46, 8 do
        part(
            exterior,
            "Road Marking",
            Vector3.new(4, 0.03, 0.22),
            CFrame.new(x, 0.15, 43),
            COLORS.gold,
            Enum.Material.Neon
        )
    end
    for x = -42, 42, 14 do
        part(
            exterior,
            "Parking Stall Divider",
            Vector3.new(0.14, 0.035, 5.8),
            CFrame.new(x, 0.14, 39),
            COLORS.warmWhite,
            Enum.Material.SmoothPlastic
        )
    end
    for _, z in ipairs({ 36, 42 }) do
        part(
            exterior,
            "Parking Stall End Line",
            Vector3.new(84, 0.035, 0.14),
            CFrame.new(0, 0.14, z),
            COLORS.warmWhite,
            Enum.Material.SmoothPlastic
        )
    end
    part(
        exterior,
        "Commercial District Delivery Avenue",
        Vector3.new(20, 0.2, 190),
        CFrame.new(-99, 0.02, -48),
        COLORS.road,
        Enum.Material.Asphalt
    )
    part(
        exterior,
        "Commercial District Avenue Sidewalk",
        Vector3.new(8, 0.16, 190),
        CFrame.new(-84.5, 0.12, -48),
        COLORS.gray,
        Enum.Material.Concrete
    )
    part(
        exterior,
        "Delivery Avenue Center Stripe",
        Vector3.new(0.16, 0.03, 180),
        CFrame.new(-99, 0.14, -48),
        COLORS.gold,
        Enum.Material.Neon
    )
    for _, z in ipairs({ 30, -8, -46, -84, -122 }) do
        createStreetlight(exterior, -90, z)
    end
    for x = -88, -78, 2 do
        part(
            exterior,
            "Commercial Avenue Crosswalk Stripe",
            Vector3.new(0.85, 0.035, 5),
            CFrame.new(x, 0.16, 43),
            COLORS.warmWhite,
            Enum.Material.SmoothPlastic
        )
    end
    local floristShell = createNeighborhoodStorefront(
        exterior,
        "Maple Corner Florist Shell",
        Vector3.new(54, 0, -72),
        COLORS.green,
        "MAPLE CORNER\nFLOWERS & GIFTS"
    )
    local bookshopShell = createNeighborhoodStorefront(
        exterior,
        "Riverside Bookshop Shell",
        Vector3.new(79, 0, -72),
        COLORS.coral,
        "RIVERSIDE\nBOOKS & PAPER"
    )

    -- 44 x 36 storefront; entry opening remains visible from the parking approach.
    local storeFloor = part(
        interior,
        "Tile Floor",
        Vector3.new(44, 0.45, 36),
        CFrame.new(0, 0.24, -1),
        COLORS.cream,
        Enum.Material.CeramicTiles
    )
    storeFloor:SetAttribute("MarketPaletteRole", "Floor")
    local mainBackWall =
        part(interior, "Back Wall", Vector3.new(44, 12, 1), CFrame.new(0, 6, -19), COLORS.cream)
    mainBackWall:SetAttribute("MarketPaletteRole", "Wall")
    local leftWall =
        part(interior, "Left Wall", Vector3.new(1, 12, 36), CFrame.new(-22, 6, -1), COLORS.cream)
    local rightWall =
        part(interior, "Right Wall", Vector3.new(1, 12, 36), CFrame.new(22, 6, -1), COLORS.cream)
    local frontLeftPier = part(
        interior,
        "Front Left Pier",
        Vector3.new(1, 12, 1),
        CFrame.new(-22, 6, 17),
        COLORS.cream
    )
    local frontRightPier = part(
        interior,
        "Front Right Pier",
        Vector3.new(1, 12, 1),
        CFrame.new(22, 6, 17),
        COLORS.cream
    )
    for _, wall in ipairs({ leftWall, rightWall, frontLeftPier, frontRightPier }) do
        wall:SetAttribute("MarketPaletteRole", "Wall")
    end
    part(
        interior,
        "Front Left Window",
        Vector3.new(13, 8, 0.35),
        CFrame.new(-14.5, 5.4, 17),
        COLORS.blue,
        Enum.Material.Glass,
        0.38
    )
    part(
        interior,
        "Front Right Window",
        Vector3.new(13, 8, 0.35),
        CFrame.new(14.5, 5.4, 17),
        COLORS.blue,
        Enum.Material.Glass,
        0.38
    )
    local frontHeader =
        part(interior, "Front Header", Vector3.new(44, 3, 1), CFrame.new(0, 10.5, 17), COLORS.teal)
    local storefrontFascia = part(
        exterior,
        "Teal Fascia",
        Vector3.new(47, 3.2, 1.4),
        CFrame.new(0, 10.3, 17.5),
        COLORS.teal
    )
    local storefrontSign = label(
        exterior,
        "Store Sign",
        "SUPERMARKET CHAOS",
        Vector3.new(29, 2.1, 0.4),
        CFrame.new(0, 10.35, 16.72),
        COLORS.teal
    )
    label(
        exterior,
        "Storefront Promise Sign",
        "FRESH GROCERIES  •  LOCAL FAVORITES",
        Vector3.new(14, 0.75, 0.28),
        CFrame.new(0, 8.65, 17.65),
        COLORS.cream,
        COLORS.deepTeal
    )
    for _, windowX in ipairs({ -14.5, 14.5 }) do
        part(
            exterior,
            "Teal Window Sill",
            Vector3.new(13, 0.8, 0.55),
            CFrame.new(windowX, 0.85, 17.55),
            COLORS.deepTeal,
            Enum.Material.Brick
        )
    end
    local entryCanopy = part(
        exterior,
        "Entry Canopy",
        Vector3.new(21, 0.6, 6),
        CFrame.new(0, 9.3, 20.5),
        COLORS.coral
    )
    for _, x in ipairs({ -9.7, 9.7 }) do
        part(
            exterior,
            "Canopy Support",
            Vector3.new(0.45, 3.2, 0.45),
            CFrame.new(x, 7.65, 22.8),
            COLORS.deepTeal,
            Enum.Material.Metal
        )
    end
    local canopyValance = part(
        exterior,
        "Canopy Front Valance",
        Vector3.new(21, 0.7, 0.35),
        CFrame.new(0, 8.9, 23.35),
        COLORS.deepTeal,
        Enum.Material.SmoothPlastic
    )
    for _, x in ipairs({ -7.5, -4.5, -1.5, 1.5, 4.5, 7.5 }) do
        part(
            exterior,
            "Canopy Color Stripe",
            Vector3.new(1.5, 0.62, 0.18),
            CFrame.new(x, 8.9, 23.56),
            COLORS.coral,
            Enum.Material.SmoothPlastic
        )
    end
    -- Automatic sliding glass doors open for players and scripted customer traffic.
    local entranceDoors = {}
    local entranceDoorVersion = 0
    local entranceDoorTween = TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local function setEntranceDoors(open)
        entranceDoorVersion += 1
        local version = entranceDoorVersion
        for _, door in ipairs(entranceDoors) do
            local openX = door.side * 5.15
            local closedX = door.side * 2.85
            local offset = Vector3.new(open and (openX - closedX) or 0, 0, 0)
            for _, movingPart in ipairs(door.movingParts) do
                TweenService:Create(movingPart.part, entranceDoorTween, {
                    CFrame = movingPart.closedCFrame + offset,
                }):Play()
            end
        end
        if open then
            task.delay(2.25, function()
                if entranceDoorVersion == version and world.Parent then
                    setEntranceDoors(false)
                end
            end)
        end
    end
    for _, side in ipairs({ -1, 1 }) do
        local closedX = side * 2.85
        local doorPanel = part(
            exterior,
            "Automatic Entrance Glass Door",
            Vector3.new(5.7, 7.7, 0.16),
            CFrame.new(closedX, 4.4, 16.78),
            COLORS.blue,
            Enum.Material.Glass,
            0.58
        )
        doorPanel.CanCollide = false
        local handle = part(
            exterior,
            "Automatic Door Pull",
            Vector3.new(0.12, 1.3, 0.1),
            doorPanel.CFrame * CFrame.new(-side * 2.4, -0.05, -0.12),
            COLORS.gold,
            Enum.Material.Metal
        )
        table.insert(entranceDoors, {
            side = side,
            movingParts = {
                { part = doorPanel, closedCFrame = doorPanel.CFrame },
                { part = handle, closedCFrame = handle.CFrame },
            },
        })
    end
    part(
        exterior,
        "Automatic Door Track",
        Vector3.new(12, 0.22, 0.3),
        CFrame.new(0, 8.42, 16.8),
        COLORS.gray,
        Enum.Material.Metal
    )
    local doorSensor = part(
        exterior,
        "Automatic Door Motion Sensor",
        Vector3.new(11, 7, 8),
        CFrame.new(0, 4.1, 16.78),
        COLORS.blue,
        Enum.Material.SmoothPlastic,
        1
    )
    doorSensor.CanCollide = false
    doorSensor.CanQuery = false
    doorSensor.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorOfClass("Model")
        if character and character:FindFirstChildOfClass("Humanoid") then
            setEntranceDoors(true)
        end
    end)
    for _, windowX in ipairs({ -14.5, 14.5 }) do
        for _, mullionX in ipairs({ windowX - 4.25, windowX, windowX + 4.25 }) do
            part(
                exterior,
                "Window Mullion",
                Vector3.new(0.12, 7.8, 0.12),
                CFrame.new(mullionX, 5.4, 16.77),
                COLORS.gray,
                Enum.Material.Metal
            )
        end
        part(
            exterior,
            "Window Crossbar",
            Vector3.new(12.8, 0.12, 0.12),
            CFrame.new(windowX, 5.4, 16.77),
            COLORS.gray,
            Enum.Material.Metal
        )
    end
    part(
        interior,
        "Entrance Mat",
        Vector3.new(13, 0.05, 5),
        CFrame.new(0, 0.49, 13.6),
        COLORS.green,
        Enum.Material.Fabric
    )
    part(
        interior,
        "Checkout Zone",
        Vector3.new(3, 0.1, 20),
        CFrame.new(13, 0.54, 2),
        COLORS.gold,
        Enum.Material.SmoothPlastic,
        0.45
    )
    local neighborhoodMarketMural = label(
        interior,
        "Neighborhood Market Mural",
        "GOOD FOOD  •  GOOD NEIGHBORS",
        Vector3.new(23, 1.8, 0.35),
        CFrame.new(0, 8.45, -18.35),
        COLORS.deepTeal,
        COLORS.warmWhite
    )
    for _, beamZ in ipairs({ -15, -5, 5, 14 }) do
        part(
            interior,
            "Exposed Ceiling Crossbeam",
            Vector3.new(44, 0.22, 0.3),
            CFrame.new(0, 10.65, beamZ),
            COLORS.deepTeal,
            Enum.Material.Metal
        )
    end
    for _, wallX in ipairs({ -20.7, 20.7 }) do
        part(
            interior,
            "Exposed Ceiling Side Beam",
            Vector3.new(0.28, 0.22, 36),
            CFrame.new(wallX, 10.65, -1),
            COLORS.deepTeal,
            Enum.Material.Metal
        )
    end
    local mainBackWainscot = part(
        interior,
        "Back Wall Teal Wainscot",
        Vector3.new(43, 1.1, 0.22),
        CFrame.new(0, 0.95, -18.43),
        COLORS.teal,
        Enum.Material.SmoothPlastic
    )
    mainBackWainscot:SetAttribute("MarketPaletteRole", "WallAccent")

    -- Warm, high-visibility ceiling panels; point lights are sparse and non-shadow casting.
    for x = -14, 14, 7 do
        for z = -12, 6, 9 do
            local panel = part(
                interior,
                "Warm Ceiling Panel",
                Vector3.new(4.5, 0.18, 2),
                CFrame.new(x, 11.7, z),
                COLORS.warmWhite,
                Enum.Material.SmoothPlastic
            )
            if x == 0 and z == -3 then
                local light = Instance.new("PointLight")
                light.Color = Color3.fromRGB(255, 233, 190)
                light.Brightness = 0.65
                light.Range = 18
                light.Shadows = false
                light.Parent = panel
            end
        end
    end

    local retailDepartmentFolder = Instance.new("Folder")
    retailDepartmentFolder.Name = "Retail Department Shelves"
    retailDepartmentFolder.Parent = interior
    local retailConstructionFolder = Instance.new("Folder")
    retailConstructionFolder.Name = "Player Constructed Retail Aisles"
    retailConstructionFolder.Parent = interior
    local retailDepartmentShelves = {}
    local retailShelfPositions = {}
    local retailShelfPivotHeights = {}
    local constructedAisleBrowsePositions = {}
    local retailBuildFixtures = {}
    local retailFixturePivotHeights = {}
    local function tagRetailShelfPalette(model)
        for _, item in ipairs(model:GetDescendants()) do
            if item:IsA("BasePart") then
                if item.Name == "Retail Gondola Back" then
                    item:SetAttribute("MarketPaletteRole", "ShelfBody")
                elseif
                    item.Name == "Wooden Kick Plate"
                    or item.Name == "Gondola Upright"
                    or item.Name == "Shelf Edge Price Rail"
                then
                    item:SetAttribute("MarketPaletteRole", "ShelfAccent")
                elseif item.Name == "Aisle Department Sign" then
                    item:SetAttribute("MarketPaletteRole", "DepartmentSign")
                end
            end
        end
    end
    local bakeryPurchased = false
    local freezerPurchased = false
    local bakeryModel
    local freezerModel
    local cinnamonTwistStockPrompt
    local frozenMealStockPrompt
    local cinnamonTwistStockAvailable = false
    local frozenMealStockAvailable = false
    local bakerySign
    local freezerSign
    local stockedCinnamonTwists = {}
    local stockedFrozenMeals = {}
    local function createDepartmentShelf(productId, name, x, z, width, department)
        local model = createShelf(retailDepartmentFolder, name, x, z, width, department)
        model:SetAttribute("RetailProductId", productId)
        tagRetailShelfPalette(model)
        retailDepartmentShelves[productId] = model
        retailShelfPositions[productId] = { x = x, z = z, rotation = 0 }
        retailShelfPivotHeights[productId] = 1.2
        return model
    end
    local shelf = createDepartmentShelf("citrusPop", "Citrus Pop Shelf", -10, -1, 6, "CITRUS POP")
    local berryShelf =
        createDepartmentShelf("berryBites", "Berry Bites Shelf", 10, -1, 6, "BERRY BITES")
    local goldenAppleShelf = createDepartmentShelf(
        "goldenApples",
        "Golden Apples Produce Shelf",
        -8,
        -9,
        4,
        "GOLDEN APPLES"
    )
    local cerealShelf =
        createDepartmentShelf("sunriseCereal", "Sunrise Cereal Shelf", 0, -9, 6, "SUNRISE CEREAL")
    local priceTags = {}
    local pricePrompts = {}
    local initialPrices = {
        citrusPop = 25,
        berryBites = 18,
        goldenApples = 12,
        sunriseCereal = 16,
        cinnamonTwists = 18,
        frozenMeals = 22,
    }
    local function createPriceTag(productId, displayName, shelfModel, x, z)
        local tag = label(
            shelfModel,
            displayName .. " Shelf Price Tag",
            string.format("$%d", initialPrices[productId]),
            Vector3.new(1.45, 0.58, 0.12),
            CFrame.new(x, 1.95, z - 1.17),
            COLORS.gold,
            COLORS.ink
        )
        local changePrompt = pricePrompts[productId]
        if changePrompt then
            changePrompt.Parent = shelfModel.PrimaryPart
        else
            changePrompt =
                prompt(shelfModel.PrimaryPart, "Change Price", displayName, "ChangePrice", 9)
        end
        priceTags[productId] = tag
        pricePrompts[productId] = changePrompt
        changePrompt.ActionText = string.format("Change Price ($%d)", initialPrices[productId])
    end
    createPriceTag("citrusPop", "Citrus Pop", shelf, -10, -1)
    createPriceTag("berryBites", "Berry Bites", berryShelf, 10, -1)
    createPriceTag("goldenApples", "Golden Apples", goldenAppleShelf, -8, -9)
    createPriceTag("sunriseCereal", "Sunrise Cereal", cerealShelf, 0, -9)
    createRefrigeratedCase(interior, 9, -14.5)
    part(
        interior,
        "Produce Counter",
        Vector3.new(7, 2, 3),
        CFrame.new(-13, 1.45, 8),
        COLORS.wood,
        Enum.Material.WoodPlanks
    )
    label(
        interior,
        "Produce Department Sign",
        "FRESH PRODUCE",
        Vector3.new(7, 1.15, 0.3),
        CFrame.new(-13, 3.5, 6.35),
        COLORS.green,
        COLORS.warmWhite
    )
    for binIndex = 1, 3 do
        local binX = -15 + (binIndex - 1) * 2
        part(
            interior,
            "Produce Crate",
            Vector3.new(1.85, 0.45, 2.25),
            CFrame.new(binX, 2.65, 8),
            COLORS.wood,
            Enum.Material.WoodPlanks
        )
        for fruitIndex = 1, 4 do
            local fruit = part(
                interior,
                "Fresh Produce",
                Vector3.new(0.6, 0.58, 0.6),
                CFrame.new(binX - 0.58 + (fruitIndex - 1) * 0.38, 3.15, 7.85),
                ({ COLORS.coral, COLORS.paleGreen, COLORS.gold, COLORS.orange })[((binIndex + fruitIndex - 2) % 4) + 1],
                Enum.Material.SmoothPlastic
            )
            fruit.Shape = Enum.PartType.Ball
        end
    end

    -- Keep every checkout prop together so the lane can be repositioned as one fixture.
    local checkoutModel = Instance.new("Model")
    checkoutModel.Name = "Checkout Lane"
    checkoutModel.Parent = interior
    local function checkoutPart(...)
        local checkoutItem = part(interior, ...)
        checkoutItem.Parent = checkoutModel
        return checkoutItem
    end
    local counter = checkoutPart(
        "Checkout Counter",
        Vector3.new(8, 2.5, 3.5),
        CFrame.new(14, 1.7, 8),
        COLORS.deepTeal,
        Enum.Material.Metal
    )
    counter:SetAttribute("MarketPaletteRole", "Checkout")
    local checkoutFrontPanel = checkoutPart(
        "Checkout Counter Front Panel",
        Vector3.new(7.5, 1.55, 0.18),
        CFrame.new(14, 1.65, 9.78),
        COLORS.wood,
        Enum.Material.WoodPlanks
    )
    checkoutFrontPanel:SetAttribute("MarketPaletteRole", "CheckoutAccent")
    checkoutPart(
        "Checkout Conveyor Belt",
        Vector3.new(4.1, 0.18, 2.5),
        CFrame.new(13.2, 3.05, 8.05),
        COLORS.ink,
        Enum.Material.SmoothPlastic
    )
    checkoutPart(
        "Checkout Bagging Counter",
        Vector3.new(3.5, 0.22, 2.7),
        CFrame.new(16.7, 3.05, 8.05),
        COLORS.warmWhite,
        Enum.Material.Marble
    )
    checkoutPart(
        "Checkout Scanner",
        Vector3.new(0.9, 0.12, 0.8),
        CFrame.new(15.25, 3.2, 7.45),
        COLORS.coral,
        Enum.Material.Neon
    )
    checkoutPart(
        "Checkout Screen",
        Vector3.new(1.15, 0.85, 0.18),
        CFrame.new(12.2, 3.8, 6.65),
        COLORS.ink,
        Enum.Material.SmoothPlastic
    )
    local checkoutDisplay = checkoutPart(
        "Checkout Screen Display",
        Vector3.new(0.92, 0.56, 0.035),
        CFrame.new(12.2, 3.82, 6.755),
        COLORS.paleGreen,
        Enum.Material.Neon
    )
    local checkoutGui = Instance.new("SurfaceGui")
    checkoutGui.Name = "RegisterDisplayGui"
    checkoutGui.Face = Enum.NormalId.Back
    checkoutGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    checkoutGui.PixelsPerStud = 50
    checkoutGui.Parent = checkoutDisplay
    local checkoutText = Instance.new("TextLabel")
    checkoutText.Size = UDim2.fromScale(1, 1)
    checkoutText.BackgroundTransparency = 1
    checkoutText.Text = "READY  •  SCAN ITEMS"
    checkoutText.TextColor3 = COLORS.deepTeal
    checkoutText.Font = Enum.Font.GothamBold
    checkoutText.TextScaled = true
    checkoutText.Parent = checkoutGui
    local checkoutSign = label(
        interior,
        "Checkout Overhead Sign",
        "CHECKOUT  •  LANE 01",
        Vector3.new(7, 1.15, 0.3),
        CFrame.new(14, 6.25, 6.1),
        COLORS.deepTeal,
        COLORS.warmWhite
    )
    checkoutSign.Parent = checkoutModel
    local impulseRack = checkoutPart(
        "Checkout Candy Rack",
        Vector3.new(1.2, 2.1, 1.25),
        CFrame.new(19.2, 1.55, 4.5),
        COLORS.gray,
        Enum.Material.Metal
    )
    impulseRack.CanCollide = false
    for row = 1, 3 do
        for column = 1, 2 do
            checkoutPart(
                "Checkout Treat Pack",
                Vector3.new(0.42, 0.42, 0.4),
                CFrame.new(18.9 + column * 0.36, 1.0 + row * 0.42, 3.9),
                ({ COLORS.coral, COLORS.gold, COLORS.green })[row],
                Enum.Material.SmoothPlastic
            )
        end
    end
    local selfCheckoutModel = Instance.new("Model")
    selfCheckoutModel.Name = "Self Checkout Terminal"
    selfCheckoutModel.Parent = checkoutModel
    local function selfCheckoutPart(name, size, cframe, color, material, transparency)
        local item = part(selfCheckoutModel, name, size, cframe, color, material, transparency)
        item.CanCollide = false
        return item
    end
    selfCheckoutPart(
        "Self Checkout Terminal Base",
        Vector3.new(2.5, 0.4, 1.8),
        CFrame.new(10.8, 3.03, 7.95),
        COLORS.wood,
        Enum.Material.WoodPlanks,
        1
    )
    local selfCheckoutScanner = selfCheckoutPart(
        "Self Checkout Scanner",
        Vector3.new(0.65, 0.12, 0.62),
        CFrame.new(10.85, 3.3, 7.5),
        COLORS.green,
        Enum.Material.Neon,
        1
    )
    local selfCheckoutDisplay = selfCheckoutPart(
        "Self Checkout Screen",
        Vector3.new(0.95, 0.72, 0.14),
        CFrame.new(10.8, 3.75, 7.15),
        COLORS.ink,
        Enum.Material.SmoothPlastic,
        1
    )
    local selfCheckoutGui = Instance.new("SurfaceGui")
    selfCheckoutGui.Name = "SelfCheckoutDisplayGui"
    selfCheckoutGui.Face = Enum.NormalId.Back
    selfCheckoutGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    selfCheckoutGui.PixelsPerStud = 48
    selfCheckoutGui.Enabled = false
    selfCheckoutGui.Parent = selfCheckoutDisplay
    local selfCheckoutText = Instance.new("TextLabel")
    selfCheckoutText.Size = UDim2.fromScale(1, 1)
    selfCheckoutText.BackgroundTransparency = 1
    selfCheckoutText.Text = "SELF CHECKOUT\nREADY"
    selfCheckoutText.TextColor3 = COLORS.warmWhite
    selfCheckoutText.Font = Enum.Font.GothamBold
    selfCheckoutText.TextScaled = true
    selfCheckoutText.Parent = selfCheckoutGui
    local selfCheckoutSign = label(
        selfCheckoutModel,
        "Self Checkout Lane Sign",
        "SELF CHECKOUT  •  LANE 02",
        Vector3.new(4.2, 0.85, 0.24),
        CFrame.new(10.8, 5.35, 7.4),
        COLORS.green,
        COLORS.warmWhite
    )
    selfCheckoutSign.Transparency = 1
    local selfCheckoutSignGui = selfCheckoutSign:FindFirstChildOfClass("SurfaceGui")
    if selfCheckoutSignGui then
        selfCheckoutSignGui.Enabled = false
    end
    local selfCheckoutPrompt = prompt(
        selfCheckoutScanner,
        "Serve Customer",
        "Self-Checkout • Lane 02",
        "SelfCheckout",
        9
    )
    selfCheckoutPrompt.Enabled = false
    checkoutModel.PrimaryPart = counter
    checkoutModel:PivotTo(CFrame.new(14, 1.7, 8))
    local currentStage = "Loading"
    local uptownStorePurchased = locationId == "uptown"
    local uptownPurchaseUnlocked = false
    local uptownPad = part(
        exterior,
        "Uptown Market Travel Pad",
        Vector3.new(5.5, 0.45, 5.5),
        CFrame.new(58, 0.35, 52),
        COLORS.gold,
        Enum.Material.Neon
    )
    local uptownPurchasePrompt
    if locationId == "neighborhood" then
        uptownPurchasePrompt = prompt(
            uptownPad,
            "Open Uptown Market ($15,000)",
            "Regional Expansion",
            "BuildUptownStore",
            11
        )
    end
    local locationTravelPrompt = prompt(
        uptownPad,
        locationId == "uptown" and "Return to Neighborhood" or "Travel to Uptown Market",
        "Store Travel",
        "TravelStore",
        11
    )
    local function updateLocationPrompts()
        if uptownPurchasePrompt then
            uptownPurchasePrompt.Enabled = currentStage == "Complete"
                and uptownPurchaseUnlocked
                and not uptownStorePurchased
        end
        locationTravelPrompt.Enabled = locationId == "uptown" or uptownStorePurchased
        uptownPad.Color = uptownStorePurchased and COLORS.teal or COLORS.gold
    end
    local travelDestination = locationId == "uptown" and CFrame.new(58, 2.5, 44)
        or (WorldBuilder.UPTOWN_ORIGIN * CFrame.new(58, 2.5, 44))
    local aisleExpansionPurchased = false
    local floorExpansionPurchased = false
    local retailPlotState = { purchased = false, model = nil }
    local selfCheckoutPurchased = false
    local floorExpansionModel
    local customerModels = {}
    local customerColors = {
        { COLORS.blue, COLORS.deepTeal, COLORS.orange },
        { COLORS.coral, COLORS.gray, COLORS.deepTeal },
        { COLORS.green, COLORS.blue, COLORS.gold },
        { COLORS.orange, COLORS.deepTeal, COLORS.cream },
        { COLORS.paleGreen, COLORS.wood, COLORS.coral },
        { COLORS.blue, COLORS.wood, COLORS.green },
    }
    local customerPositions = {}
    local selfCheckoutQueuePositions = {}
    local queueOffsets = {
        Vector3.new(3.5, -1.25, -4),
        Vector3.new(3.5, -1.25, 0),
        Vector3.new(3.5, -1.25, 4),
        Vector3.new(3.5, -1.25, 7),
        Vector3.new(0, -1.25, 7),
        Vector3.new(3.5, -1.25, 11),
    }
    local selfCheckoutQueueOffsets = {
        Vector3.new(-3.5, -1.25, -4),
        Vector3.new(-3.5, -1.25, 0),
        Vector3.new(-3.5, -1.25, 4),
    }
    local cashierModel
    local function checkoutLocalPosition(offset)
        return checkoutModel:GetPivot():PointToWorldSpace(offset)
    end
    local function refreshCheckoutPositions(x, z, rotation, moveModels)
        checkoutModel:PivotTo(CFrame.new(x, 1.7, z) * CFrame.Angles(0, math.rad(rotation), 0))
        for index, offset in ipairs(queueOffsets) do
            customerPositions[index] = checkoutLocalPosition(offset)
        end
        for index, offset in ipairs(selfCheckoutQueueOffsets) do
            selfCheckoutQueuePositions[index] = checkoutLocalPosition(offset)
        end
        if moveModels then
            for index, entry in ipairs(customerModels) do
                local position = customerPositions[index]
                entry.homePosition = position
                entry.homePivot = entry.model:GetPivot()
                    + (position - entry.model:GetPivot().Position)
                entry.model:PivotTo(entry.homePivot)
            end
            if cashierModel then
                cashierModel:PivotTo(checkoutModel:GetPivot() * CFrame.new(-3.5, -1.25, 0))
            end
        end
    end
    refreshCheckoutPositions(14, 8, 0, false)
    for index, position in ipairs(customerPositions) do
        local colors = customerColors[index]
        local customer = createLowPolyPerson(
            interior,
            index == 1 and "Checkout Customer" or ("Queue Customer " .. index),
            position,
            colors[1],
            colors[2],
            colors[3],
            true
        )
        local head = customer:FindFirstChild("Head")
        local customerBillboard = Instance.new("BillboardGui")
        customerBillboard.Name = "CustomerNameplate"
        customerBillboard.Adornee = head
        customerBillboard.Size = UDim2.fromOffset(150, 38)
        customerBillboard.StudsOffset = Vector3.new(0, 1.25, 0)
        customerBillboard.AlwaysOnTop = true
        customerBillboard.Enabled = false
        customerBillboard.Parent = head
        local customerLabel = Instance.new("TextLabel")
        customerLabel.Size = UDim2.fromScale(1, 1)
        customerLabel.BackgroundColor3 = COLORS.deepTeal
        customerLabel.BackgroundTransparency = 0.08
        customerLabel.Text = index == 1 and "NEXT CUSTOMER" or "IN QUEUE"
        customerLabel.TextColor3 = COLORS.warmWhite
        customerLabel.Font = Enum.Font.GothamBold
        customerLabel.TextScaled = true
        customerLabel.Parent = customerBillboard
        local customerCorner = Instance.new("UICorner")
        customerCorner.CornerRadius = UDim.new(0, 8)
        customerCorner.Parent = customerLabel

        for _, item in ipairs(customer:GetDescendants()) do
            if item:IsA("BasePart") then
                item.Transparency = 1
                item.CanCollide = false
            end
        end
        table.insert(customerModels, {
            model = customer,
            homePosition = position,
            homePivot = customer:GetPivot(),
            billboard = customerBillboard,
            label = customerLabel,
        })
    end

    local register = prompt(counter, "Serve Customer", "Checkout", "Checkout", 9)
    register.Enabled = false
    local customerFlowVersion = 0
    local customerFlowTweens = {}
    local remainingCustomers
    local customerTotal = 0
    local checkoutReady = false
    local checkoutReadyAt = 0
    local function customerLaneFor(index)
        return selfCheckoutPurchased and index % 2 == 1 and "SelfCheckout" or "Checkout"
    end
    local function customerQueuePosition(index, served)
        local lane = customerLaneFor(index)
        local lanePosition = 1
        for previousIndex = served + 1, index - 1 do
            if customerLaneFor(previousIndex) == lane then
                lanePosition += 1
            end
        end
        local positions = lane == "SelfCheckout" and selfCheckoutQueuePositions or customerPositions
        return positions[lanePosition] or positions[#positions]
    end
    local function updateCheckoutPrompts()
        local stageAllowsCheckout = currentStage == "Checkout" or currentStage == "CustomerRush"
        local activeIndex = customerTotal - (remainingCustomers or 0) + 1
        local selfCheckoutActive = selfCheckoutPurchased
            and remainingCustomers ~= nil
            and remainingCustomers > 0
            and activeIndex % 2 == 1
        register.Enabled = stageAllowsCheckout and checkoutReady and not selfCheckoutActive
        selfCheckoutPrompt.Enabled = stageAllowsCheckout and checkoutReady and selfCheckoutActive
    end
    local function cancelCustomerFlow()
        customerFlowVersion += 1
        for _, tween in pairs(customerFlowTweens) do
            tween:Cancel()
        end
        for entry in pairs(customerFlowTweens) do
            customerFlowTweens[entry] = nil
        end
    end

    local function moveCustomer(entry, targetPosition, duration, flowVersion)
        if not entry.model.Parent or flowVersion ~= customerFlowVersion then
            return false
        end
        local driver = Instance.new("CFrameValue")
        driver.Value = entry.model:GetPivot()
        local targetPivot = entry.homePivot + (targetPosition - entry.homePosition)
        local connection = driver:GetPropertyChangedSignal("Value"):Connect(function()
            if flowVersion == customerFlowVersion and entry.model.Parent then
                entry.model:PivotTo(driver.Value)
            end
        end)
        local tween = TweenService:Create(
            driver,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            { Value = targetPivot }
        )
        customerFlowTweens[entry] = tween
        tween:Play()
        local result = tween.Completed:Wait()
        connection:Disconnect()
        if customerFlowTweens[entry] == tween then
            customerFlowTweens[entry] = nil
        end
        driver:Destroy()
        return result == Enum.PlaybackState.Completed and flowVersion == customerFlowVersion
    end

    local customerProductName = "Citrus Pop"
    local customerBasketName = "Citrus Pop x1"
    local customerPreferenceName = "Everyday"
    local customerBasketItems = {}
    local customerProductPositions = {}
    local function customerBrowsePosition(productId)
        for _, aisle in ipairs(constructedAisleBrowsePositions[productId] or {}) do
            if aisle.stock > 0 then
                local forwardOffset = CFrame.Angles(0, math.rad(aisle.rotation or 0), 0)
                    :VectorToWorldSpace(Vector3.new(0, 0, 3))
                return Vector3.new(aisle.x, 0.45, aisle.z) + forwardOffset
            end
        end
        local shelfPosition = retailShelfPositions[productId]
        if not shelfPosition then
            return Vector3.new(-10, 0.45, 2)
        end
        local forwardOffset = CFrame.Angles(0, math.rad(shelfPosition.rotation or 0), 0)
            :VectorToWorldSpace(Vector3.new(0, 0, 3))
        return Vector3.new(shelfPosition.x, 0.45, shelfPosition.z) + forwardOffset
    end
    local function updateCustomerBasketPositions()
        customerProductPositions = {}
        local visited = {}
        for _, item in ipairs(customerBasketItems) do
            if not visited[item.productId] and retailShelfPositions[item.productId] then
                visited[item.productId] = true
                table.insert(customerProductPositions, customerBrowsePosition(item.productId))
            end
        end
        if #customerProductPositions == 0 then
            table.insert(customerProductPositions, customerBrowsePosition("citrusPop"))
        end
    end
    updateCustomerBasketPositions()
    local function customerQueueStatus(queueNumber)
        if currentStage == "Spill" then
            return "WAITING • SPILL"
        elseif currentStage == "PowerOutage" then
            return "WAITING • POWER OUT"
        end
        if queueNumber == 1 and checkoutReady and checkoutReadyAt > 0 then
            local waitedSeconds = math.floor(os.clock() - checkoutReadyAt)
            if waitedSeconds >= 20 then
                return string.format("GETTING IMPATIENT • %ds", waitedSeconds)
            end
        end
        if currentStage == "CustomerRush" then
            return "RUSH CUSTOMER"
        end
        return queueNumber == 1 and "NEXT CUSTOMER" or "IN QUEUE"
    end

    local function browseCustomerBasket(entry, speed, flowVersion)
        local browseSpeed = customerAssistantHired and speed * 0.7 or speed
        for _, position in ipairs(customerProductPositions) do
            if position.Z < -41 then
                if not moveCustomer(entry, Vector3.new(0, 0.45, -17), browseSpeed, flowVersion) then
                    return false
                end
                if not moveCustomer(entry, Vector3.new(0, 0.45, -30), browseSpeed, flowVersion) then
                    return false
                end
                if not moveCustomer(entry, Vector3.new(0, 0.45, -45), browseSpeed, flowVersion) then
                    return false
                end
            elseif position.Z < -17 then
                if not moveCustomer(entry, Vector3.new(0, 0.45, -17), browseSpeed, flowVersion) then
                    return false
                end
            end
            if not moveCustomer(entry, position, browseSpeed, flowVersion) then
                return false
            end
        end
        return true
    end

    local function runCustomerVisit(entry, queuePosition, queueNumber, flowVersion, checkoutLane)
        if queueNumber > 1 then
            task.wait((queueNumber - 1) * 1.1)
        end
        local waypoints = {
            { Vector3.new(0, 0.45, 20), 0.65 },
            { Vector3.new(0, 0.45, 13), 0.55 },
            { Vector3.new(-5, 0.45, 8), 0.75 },
        }
        entry.label.Text = "ENTERING"
        for _, waypoint in ipairs(waypoints) do
            if waypoint[1].Z <= 16.78 then
                setEntranceDoors(true)
            end
            if not moveCustomer(entry, waypoint[1], waypoint[2], flowVersion) then
                return
            end
        end
        entry.label.Text = "BROWSING"
        if not browseCustomerBasket(entry, 0.7, flowVersion) then
            return
        end
        entry.label.Text = string.upper(customerPreferenceName)
            .. " • "
            .. string.upper(customerBasketName)
        task.wait(0.55)
        if entry.model:GetPivot().Position.Z < -41 then
            if not moveCustomer(entry, Vector3.new(0, 0.45, -45), 0.55, flowVersion) then
                return
            end
            if not moveCustomer(entry, Vector3.new(0, 0.45, -30), 0.55, flowVersion) then
                return
            end
        end
        if entry.model:GetPivot().Position.Z < -17 then
            if not moveCustomer(entry, Vector3.new(0, 0.45, -17), 0.55, flowVersion) then
                return
            end
        end
        local laneOffset = checkoutLane == "SelfCheckout" and -3.5 or -5
        if
            not moveCustomer(
                entry,
                checkoutLocalPosition(Vector3.new(laneOffset, -1.25, -4)),
                0.75,
                flowVersion
            )
        then
            return
        end
        if not moveCustomer(entry, queuePosition, 0.65, flowVersion) then
            return
        end
        entry.label.Text = customerQueueStatus(queueNumber)
        if queueNumber == 1 then
            checkoutReady = true
            checkoutReadyAt = os.clock()
            updateCheckoutPrompts()
        end
    end

    local function runCustomerAdvance(entry, queuePosition, queueNumber, flowVersion, checkoutLane)
        entry.label.Text = string.upper(customerPreferenceName)
            .. " • "
            .. string.upper(customerBasketName)
        if not browseCustomerBasket(entry, 0.55, flowVersion) then
            return
        end
        task.wait(0.35)
        entry.label.Text = "MOVING TO CHECKOUT"
        if entry.model:GetPivot().Position.Z < -41 then
            if not moveCustomer(entry, Vector3.new(0, 0.45, -45), 0.45, flowVersion) then
                return
            end
            if not moveCustomer(entry, Vector3.new(0, 0.45, -30), 0.45, flowVersion) then
                return
            end
        end
        if entry.model:GetPivot().Position.Z < -17 then
            if not moveCustomer(entry, Vector3.new(0, 0.45, -17), 0.45, flowVersion) then
                return
            end
        end
        local laneOffset = checkoutLane == "SelfCheckout" and -3.5 or -5
        local waypoints = {
            checkoutLocalPosition(Vector3.new(laneOffset, -1.25, 0)),
            checkoutLocalPosition(Vector3.new(laneOffset, -1.25, -4)),
            queuePosition,
        }
        for _, waypoint in ipairs(waypoints) do
            if not moveCustomer(entry, waypoint, 0.45, flowVersion) then
                return
            end
        end
        entry.label.Text = customerQueueStatus(queueNumber)
        if queueNumber == 1 then
            checkoutReady = true
            checkoutReadyAt = os.clock()
            updateCheckoutPrompts()
        end
    end

    local function runCustomerExit(entry, flowVersion, checkoutLane)
        entry.label.Text = "THANK YOU!"
        local laneOffset = checkoutLane == "SelfCheckout" and -3.5 or -5
        local waypoints = {
            checkoutLocalPosition(Vector3.new(laneOffset, -1.25, -4)),
            Vector3.new(0, 0.45, 13),
            Vector3.new(0, 0.45, 22),
        }
        for _, waypoint in ipairs(waypoints) do
            if waypoint.Z >= 16.78 then
                setEntranceDoors(true)
            end
            if not moveCustomer(entry, waypoint, 0.45, flowVersion) then
                return
            end
        end
        for _, item in ipairs(entry.model:GetDescendants()) do
            if item:IsA("BasePart") then
                item.Transparency = 1
            end
        end
        entry.billboard.Enabled = false
    end

    local function recoverCustomerQueue()
        cancelCustomerFlow()
        local served = customerTotal - (remainingCustomers or 0)
        for index, entry in ipairs(customerModels) do
            local visible = index > served and index <= customerTotal
            if visible then
                local queueNumber = index - served
                local targetPosition = customerQueuePosition(index, served)
                entry.model:PivotTo(entry.homePivot + (targetPosition - entry.homePosition))
                entry.label.Text = customerQueueStatus(queueNumber)
            end
            for _, item in ipairs(entry.model:GetDescendants()) do
                if item:IsA("BasePart") then
                    item.Transparency = visible and 0 or 1
                end
            end
            entry.billboard.Enabled = visible
        end
        checkoutReady = (remainingCustomers or 0) > 0
        checkoutReadyAt = checkoutReady and os.clock() or 0
        updateCheckoutPrompts()
    end

    local function setCustomerCount(count, targetCount)
        local activeStage = currentStage == "Checkout"
            or currentStage == "Spill"
            or currentStage == "PowerOutage"
            or currentStage == "CustomerRush"
        local countAllowed = activeStage or currentStage == "CloseShift"
        local target = countAllowed
                and math.min(
                    math.max(math.floor(targetCount or #customerModels), 0),
                    #customerModels
                )
            or 0
        local remaining = countAllowed and math.min(math.max(math.floor(count), 0), target) or 0
        if not activeStage and currentStage ~= "CloseShift" then
            cancelCustomerFlow()
            remainingCustomers = nil
            customerTotal = 0
            checkoutReady = false
            checkoutReadyAt = 0
            updateCheckoutPrompts()
            for _, entry in ipairs(customerModels) do
                for _, item in ipairs(entry.model:GetDescendants()) do
                    if item:IsA("BasePart") then
                        item.Transparency = 1
                    end
                end
                entry.billboard.Enabled = false
            end
            return
        end
        if remainingCustomers == remaining and customerTotal == target then
            return
        end

        local previousRemaining = remainingCustomers
        local previousTotal = customerTotal
        remainingCustomers = remaining
        customerTotal = target
        checkoutReady = false
        checkoutReadyAt = 0
        updateCheckoutPrompts()
        cancelCustomerFlow()
        local flowVersion = customerFlowVersion
        local served = target - remaining

        for index, entry in ipairs(customerModels) do
            local visible = index > served and index <= target
            for _, item in ipairs(entry.model:GetDescendants()) do
                if item:IsA("BasePart") then
                    item.Transparency = visible and 0 or 1
                end
            end
            entry.billboard.Enabled = visible
        end

        if
            previousRemaining
            and (
                (target == previousTotal and remaining < previousRemaining)
                or target > previousTotal
            )
        then
            local servedIndex = previousTotal - previousRemaining + 1
            local servedEntry = customerModels[servedIndex]
            if servedEntry then
                task.spawn(runCustomerExit, servedEntry, flowVersion, customerLaneFor(servedIndex))
            end
        elseif not previousRemaining then
            for index = 1, served do
                local entry = customerModels[index]
                for _, item in ipairs(entry.model:GetDescendants()) do
                    if item:IsA("BasePart") then
                        item.Transparency = 1
                    end
                end
                entry.billboard.Enabled = false
            end
        end

        for index = served + 1, target do
            local entry = customerModels[index]
            local queueNumber = index - served
            local lane = customerLaneFor(index)
            local queuePosition = customerQueuePosition(index, served)
            if previousRemaining == nil or index > previousTotal then
                local spawnPosition = Vector3.new((index - 2) * 1.7, 0.45, 22)
                entry.model:PivotTo(entry.homePivot + (spawnPosition - entry.homePosition))
            end
            if previousRemaining == nil or index > previousTotal then
                task.spawn(runCustomerVisit, entry, queuePosition, queueNumber, flowVersion, lane)
            else
                task.spawn(runCustomerAdvance, entry, queuePosition, queueNumber, flowVersion, lane)
            end
        end
        if remaining > 0 then
            task.delay(12, function()
                if
                    customerFlowVersion == flowVersion
                    and remainingCustomers == remaining
                    and not checkoutReady
                then
                    recoverCustomerQueue()
                end
            end)
        end
        register.ActionText = remaining > 0 and string.format("Serve Customer (%d left)", remaining)
            or "Checkout Complete"
    end

    local function setCustomerVisible(visible)
        setCustomerCount(visible and #customerModels or 0, #customerModels)
    end

    task.spawn(function()
        while interior.Parent do
            task.wait(5)
            if checkoutReady and (currentStage == "Checkout" or currentStage == "CustomerRush") then
                local served = customerTotal - (remainingCustomers or 0)
                local entry = customerModels[served + 1]
                if entry then
                    entry.label.Text = customerQueueStatus(1)
                end
            end
        end
    end)

    local spillModel = Instance.new("Model")
    spillModel.Name = "Checkout Spill"
    spillModel.Parent = interior
    local spillPuddle = part(
        spillModel,
        "Dropped Grocery Spill",
        Vector3.new(3.2, 0.12, 2.3),
        CFrame.new(7, 0.58, 5.5),
        COLORS.gold,
        Enum.Material.SmoothPlastic,
        1
    )
    spillPuddle.Shape = Enum.PartType.Ball
    spillPuddle.CanCollide = false
    local spillSign = label(
        spillModel,
        "Spill Caution Sign",
        "SPILL!\nCLEAN UP",
        Vector3.new(2.2, 1.35, 0.25),
        CFrame.new(7, 1.45, 6.2),
        COLORS.gold,
        COLORS.deepTeal
    )
    spillSign.Transparency = 1
    spillSign.CanCollide = false
    local spillSurface = spillSign:FindFirstChildOfClass("SurfaceGui")
    if spillSurface then
        spillSurface.Enabled = false
    end
    local spillPrompt = prompt(spillPuddle, "Clean Spill", "Dropped Groceries", "Spill", 9)
    spillPrompt.Enabled = false
    local function setSpillVisible(visible)
        spillPuddle.Transparency = visible and 0.08 or 1
        spillSign.Transparency = visible and 0 or 1
        if spillSurface then
            spillSurface.Enabled = visible
        end
        spillPrompt.Enabled = visible and currentStage == "Spill"
    end

    local stockedCans = {}
    local function shelfDisplayFrame(productId, offset)
        local position = retailShelfPositions[productId]
        if not position then
            return CFrame.new(offset)
        end
        return CFrame.new(position.x, 0, position.z)
            * CFrame.Angles(0, math.rad(position.rotation or 0), 0)
            * CFrame.new(offset)
    end

    local function setStockVisual(count)
        for _, can in ipairs(stockedCans) do
            can:Destroy()
        end
        stockedCans = {}
        for index = 1, count do
            local column = (index - 1) % 8
            local row = math.floor((index - 1) / 8)
            local x = -12.45 + column * 0.7
            local y = 2.35 + row * 1.3
            local can = part(
                retailDepartmentShelves.citrusPop,
                "Stocked Citrus Pop Can",
                Vector3.new(0.62, 0.8, 0.62),
                shelfDisplayFrame("citrusPop", Vector3.new(x + 10, y, 0.46))
                    * CFrame.Angles(0, 0, math.rad(90)),
                index % 2 == 0 and COLORS.green or COLORS.coral,
                Enum.Material.Metal
            )
            can.Shape = Enum.PartType.Cylinder
            table.insert(stockedCans, can)
        end
    end

    local stockedBerryBags = {}
    local function setBerryStockVisual(count)
        for _, bag in ipairs(stockedBerryBags) do
            bag:Destroy()
        end
        stockedBerryBags = {}
        for index = 1, count do
            local x = 10 + (index - (count + 1) / 2) * 0.62
            local bag = part(
                retailDepartmentShelves.berryBites,
                "Stocked Berry Bites Pack",
                Vector3.new(0.5, 0.65, 0.5),
                shelfDisplayFrame("berryBites", Vector3.new(x - 10, 2.53, 0.38)),
                index % 2 == 0 and COLORS.coral or COLORS.orange,
                Enum.Material.SmoothPlastic
            )
            table.insert(stockedBerryBags, bag)
        end
    end

    local stockedGoldenApples = {}
    local function setGoldenAppleStockVisual(count)
        for _, apple in ipairs(stockedGoldenApples) do
            apple:Destroy()
        end
        stockedGoldenApples = {}
        for index = 1, count do
            local column = (index - 1) % 8
            local row = math.floor((index - 1) / 8)
            local apple = part(
                retailDepartmentShelves.goldenApples,
                "Stocked Golden Apple",
                Vector3.new(0.48, 0.48, 0.48),
                shelfDisplayFrame(
                    "goldenApples",
                    Vector3.new(-1.47 + column * 0.42, 2.35 + row * 1.3, 0.43)
                ),
                index % 2 == 0 and COLORS.gold or COLORS.paleGreen,
                Enum.Material.SmoothPlastic
            )
            apple.Shape = Enum.PartType.Ball
            table.insert(stockedGoldenApples, apple)
        end
    end

    local stockedCerealBoxes = {}
    local function setCerealStockVisual(count)
        for _, item in ipairs(stockedCerealBoxes) do
            item:Destroy()
        end
        stockedCerealBoxes = {}
        for index = 1, count do
            local column = (index - 1) % 8
            local row = math.floor((index - 1) / 8)
            local x = -2.45 + column * 0.7
            local y = 3.75 + row * 1.3
            local box = part(
                retailDepartmentShelves.sunriseCereal,
                "Stocked Sunrise Cereal Box",
                Vector3.new(0.56, 0.82, 0.44),
                shelfDisplayFrame("sunriseCereal", Vector3.new(x, y - 1.2, -0.55)),
                ({ COLORS.orange, COLORS.gold, COLORS.green, COLORS.blue })[((index - 1) % 4) + 1],
                Enum.Material.SmoothPlastic
            )
            local labelPlate = part(
                retailDepartmentShelves.sunriseCereal,
                "Sunrise Cereal Package Label",
                Vector3.new(0.4, 0.24, 0.03),
                shelfDisplayFrame("sunriseCereal", Vector3.new(x, y - 1.2, -0.32)),
                COLORS.warmWhite,
                Enum.Material.SmoothPlastic
            )
            box:SetAttribute("ProductDisplay", true)
            labelPlate:SetAttribute("ProductDisplay", true)
            table.insert(stockedCerealBoxes, box)
            table.insert(stockedCerealBoxes, labelPlate)
        end
    end

    local function setCinnamonTwistStockVisual(count)
        for _, item in ipairs(stockedCinnamonTwists) do
            item:Destroy()
        end
        stockedCinnamonTwists = {}
        if not bakeryModel then
            return
        end
        local visibleCount = math.max(0, math.min(24, math.floor(tonumber(count) or 0)))
        local placement = retailShelfPositions.cinnamonTwists or { x = 16, z = -29, rotation = 0 }
        local fixtureCFrame = CFrame.new(placement.x, 0, placement.z)
            * CFrame.Angles(0, math.rad(placement.rotation), 0)
        for index = 1, math.min(visibleCount, 12) do
            local column = (index - 1) % 6
            local row = math.floor((index - 1) / 6)
            local pastry = part(
                bakeryModel,
                "Cinnamon Twist Display",
                Vector3.new(0.62, 0.28, 0.38),
                fixtureCFrame * CFrame.new(-2.8 + column * 0.72, 2.05 + row * 0.34, 0),
                index % 2 == 0 and COLORS.orange or COLORS.gold,
                Enum.Material.SmoothPlastic
            )
            pastry.Shape = Enum.PartType.Cylinder
            pastry:SetAttribute("ProductDisplay", true)
            table.insert(stockedCinnamonTwists, pastry)
        end
        if bakerySign then
            local surface = bakerySign:FindFirstChildOfClass("SurfaceGui")
            local textLabel = surface and surface:FindFirstChildOfClass("TextLabel")
            if textLabel then
                textLabel.Text = string.format("BAKERY  •  %d FRESH", visibleCount)
            end
        end
    end

    local function setFrozenMealStockVisual(count)
        for _, item in ipairs(stockedFrozenMeals) do
            item:Destroy()
        end
        stockedFrozenMeals = {}
        if not freezerModel then
            return
        end
        local visibleCount = math.max(0, math.min(24, math.floor(tonumber(count) or 0)))
        local placement = retailShelfPositions.frozenMeals or { x = 6, z = -29, rotation = 0 }
        local fixtureCFrame = CFrame.new(placement.x, 0, placement.z)
            * CFrame.Angles(0, math.rad(placement.rotation), 0)
        for index = 1, math.min(visibleCount, 12) do
            local column = (index - 1) % 6
            local row = math.floor((index - 1) / 6)
            local meal = part(
                freezerModel,
                "Frozen Meal Pack Display",
                Vector3.new(0.62, 0.42, 0.5),
                fixtureCFrame * CFrame.new(-2.75 + column * 0.92, 2.25 + row * 0.48, 0),
                index % 2 == 0 and COLORS.blue or COLORS.paleGreen,
                Enum.Material.SmoothPlastic
            )
            meal:SetAttribute("ProductDisplay", true)
            table.insert(stockedFrozenMeals, meal)
        end
        if freezerSign then
            local surface = freezerSign:FindFirstChildOfClass("SurfaceGui")
            local textLabel = surface and surface:FindFirstChildOfClass("TextLabel")
            if textLabel then
                textLabel.Text = string.format("FROZEN FOODS  •  %d IN STOCK", visibleCount)
            end
        end
    end

    local hiringBoard = label(
        interior,
        "Staff Hiring Board",
        "HIRE A CASHIER  $100",
        Vector3.new(5, 2, 0.45),
        CFrame.new(17.8, 3.4, -3.8),
        COLORS.teal,
        COLORS.gold
    )
    local cashierHirePrompt =
        prompt(hiringBoard, "Hire Cashier ($100)", "Staff Board", "HireCashier", 10)
    local cashierAutomationPrompt =
        prompt(hiringBoard, "Pause Automation", "Cashier", "ToggleCashierAutomation", 10)
    cashierAutomationPrompt.Enabled = false
    cashierModel = createLowPolyPerson(
        interior,
        "Store Cashier",
        Vector3.new(10.5, 0.45, 8),
        COLORS.teal,
        COLORS.deepTeal,
        COLORS.ink
    )
    for _, item in ipairs(cashierModel:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Transparency = 1
            item.CanCollide = false
        end
    end
    local cashierHired = false
    local stockerHiringBoard = label(
        interior,
        "Stocker Hiring Board",
        "HIRE A STOCKER  $80",
        Vector3.new(5, 2, 0.45),
        CFrame.new(-17.8, 3.4, -3.8),
        COLORS.teal,
        COLORS.gold
    )
    local stockerHirePrompt =
        prompt(stockerHiringBoard, "Hire Stocker ($80)", "Staff Board", "HireStocker", 10)
    local stockerAutomationPrompt =
        prompt(stockerHiringBoard, "Pause Automation", "Stock Clerk", "ToggleStockerAutomation", 10)
    stockerAutomationPrompt.Enabled = false
    local stockerModel = createLowPolyPerson(
        interior,
        "Store Stock Clerk",
        Vector3.new(-6.5, 0.45, -1),
        COLORS.green,
        COLORS.wood,
        COLORS.deepTeal
    )
    for _, item in ipairs(stockerModel:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Transparency = 1
            item.CanCollide = false
        end
    end
    local stockerHired = false
    local cleanerHiringBoard = label(
        interior,
        "Cleaner Hiring Board",
        "HIRE A CLEANER  $120",
        Vector3.new(5, 2, 0.45),
        CFrame.new(5.5, 3.4, -18.4),
        COLORS.gold,
        COLORS.deepTeal
    )
    local cleanerHirePrompt =
        prompt(cleanerHiringBoard, "Hire Cleaner ($120)", "Staff Board", "HireCleaner", 10)
    local cleanerAutomationPrompt =
        prompt(cleanerHiringBoard, "Pause Automation", "Cleaner", "ToggleCleanerAutomation", 10)
    cleanerAutomationPrompt.Enabled = false
    local cleanerModel = createLowPolyPerson(
        interior,
        "Store Cleaner",
        Vector3.new(6.5, 0.45, 6.5),
        COLORS.blue,
        COLORS.deepTeal,
        COLORS.gray
    )
    local broomHandle = part(
        cleanerModel,
        "Cleaner Broom Handle",
        Vector3.new(0.14, 2.2, 0.14),
        CFrame.new(7.25, 1.65, 6.5) * CFrame.Angles(0, 0, math.rad(-16)),
        COLORS.wood,
        Enum.Material.Wood
    )
    broomHandle.CanCollide = false
    local broomHead = part(
        cleanerModel,
        "Cleaner Broom Head",
        Vector3.new(0.9, 0.24, 0.45),
        CFrame.new(7.55, 0.6, 6.5),
        COLORS.gold,
        Enum.Material.SmoothPlastic
    )
    broomHead.CanCollide = false
    for _, item in ipairs(cleanerModel:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Transparency = 1
            item.CanCollide = false
        end
    end
    local cleanerHired = false
    local deliveryWorkerBoard = label(
        interior,
        "Delivery Worker Hiring Board",
        "HIRE DELIVERY WORKER  $140\nSHIPMENTS + ONLINE ORDERS",
        Vector3.new(5, 2, 0.45),
        CFrame.new(17.8, 3.4, -18.4),
        COLORS.orange,
        COLORS.ink
    )
    local deliveryWorkerHirePrompt = prompt(
        deliveryWorkerBoard,
        "Hire Delivery Worker ($140)",
        "Staff Board",
        "HireDeliveryWorker",
        10
    )
    local deliveryWorkerAutomationPrompt = prompt(
        deliveryWorkerBoard,
        "Pause Automation",
        "Delivery Worker",
        "ToggleDeliveryWorkerAutomation",
        10
    )
    deliveryWorkerAutomationPrompt.Enabled = false
    local deliveryWorkerModel = createLowPolyPerson(
        exterior,
        "Warehouse Delivery Worker",
        Vector3.new(51, 0.45, 11),
        COLORS.orange,
        COLORS.wood,
        COLORS.deepTeal
    )
    for _, item in ipairs(deliveryWorkerModel:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Transparency = 1
            item.CanCollide = false
        end
    end
    local deliveryWorkerHired = false
    local deliveryFleetPurchased = false
    local deliveryFleetModel
    local customerAssistantBoard = label(
        interior,
        "Customer Assistant Hiring Board",
        "HIRE CUSTOMER ASSISTANT  $160",
        Vector3.new(5, 2, 0.45),
        CFrame.new(-5.6, 3.4, -18.4),
        COLORS.blue,
        COLORS.deepTeal
    )
    local customerAssistantHirePrompt = prompt(
        customerAssistantBoard,
        "Hire Customer Assistant ($160)",
        "Staff Board",
        "HireCustomerAssistant",
        10
    )
    local customerAssistantModel = createLowPolyPerson(
        interior,
        "Customer Assistant",
        Vector3.new(-8, 0.45, -14.5),
        COLORS.blue,
        COLORS.teal,
        COLORS.ink
    )
    for _, item in ipairs(customerAssistantModel:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Transparency = 1
            item.CanCollide = false
        end
    end
    local stockPrompt = prompt(shelf.PrimaryPart, "Stock Shelf", "Citrus Pop", "Stock", 9)
    stockPrompt.Enabled = false
    local citrusStockAvailable = false
    local function updateCitrusStockPrompt()
        stockPrompt.Enabled = citrusStockAvailable
            and (
                currentStage == "Stock"
                or currentStage == "Checkout"
                or currentStage == "CustomerRush"
            )
    end
    local berryStockPrompt =
        prompt(berryShelf.PrimaryPart, "Stock Shelf", "Berry Bites", "StockBerryBites", 9)
    berryStockPrompt.Enabled = false
    local berryStockAvailable = false
    local goldenAppleStockPrompt = prompt(
        goldenAppleShelf.PrimaryPart,
        "Stock Produce",
        "Golden Apples",
        "StockGoldenApples",
        9
    )
    goldenAppleStockPrompt.Enabled = false
    local goldenAppleStockAvailable = false
    local cerealStockPrompt =
        prompt(cerealShelf.PrimaryPart, "Stock Shelf", "Sunrise Cereal", "StockSunriseCereal", 9)
    cerealStockPrompt.Enabled = false
    local cerealStockAvailable = false
    local shiftBoard = label(
        interior,
        "Shift Board",
        "FIRST SHIFT",
        Vector3.new(5, 3, 0.4),
        CFrame.new(-17, 5, -18.35),
        COLORS.teal
    )
    local closePrompt = prompt(shiftBoard, "Close Shift", "Shift Summary", "CloseShift", 9)
    local restartPrompt = prompt(shiftBoard, "Start Next Shift", "Shift Board", "RestartShift", 9)
    local breakerBox = part(
        interior,
        "Checkout Power Breaker",
        Vector3.new(1.4, 2, 0.3),
        CFrame.new(20.2, 2.7, 6.1),
        COLORS.gray,
        Enum.Material.Metal
    )
    local breakerSign = label(
        interior,
        "Power Breaker Sign",
        "CHECKOUT POWER",
        Vector3.new(3.2, 0.8, 0.25),
        CFrame.new(19.4, 4.2, 6.1),
        COLORS.teal,
        COLORS.warmWhite
    )
    breakerSign.Transparency = 1
    local breakerSurface = breakerSign:FindFirstChildOfClass("SurfaceGui")
    if breakerSurface then
        breakerSurface.Enabled = false
    end
    local powerPrompt = prompt(breakerBox, "Restore Power", "Checkout Breaker", "RestorePower", 9)
    powerPrompt.Enabled = false
    local upgradePad = part(
        interior,
        "Upgrade Pad",
        Vector3.new(5.5, 0.55, 5.5),
        CFrame.new(17.5, 0.52, 12.5),
        COLORS.gold,
        Enum.Material.Neon
    )
    local upgradePrompt = prompt(upgradePad, "Add Shelf Bay ($45)", "Store Upgrade", "Upgrade", 10)
    local aisleExpansionPad = upgradePad
    local aisleExpansionPrompt = prompt(
        aisleExpansionPad,
        "Add Household Aisle ($220)",
        "Store Expansion",
        "AisleExpansion",
        10
    )
    aisleExpansionPrompt.Enabled = false
    local floorExpansionPad = part(
        interior,
        "Rear Department Expansion Pad",
        Vector3.new(4.5, 0.5, 4.5),
        CFrame.new(18, 0.5, -14),
        COLORS.gold,
        Enum.Material.Neon
    )
    local floorExpansionPrompt =
        prompt(floorExpansionPad, "Build Rear Wing ($500)", "Store Expansion", "FloorExpansion", 10)
    floorExpansionPrompt.Enabled = false
    local selfCheckoutBuildPrompt = prompt(
        floorExpansionPad,
        "Install Self-Checkout ($300)",
        "Second Checkout Lane",
        "BuildSelfCheckout",
        10
    )
    selfCheckoutBuildPrompt.Enabled = false
    local bakeryExpansionPad = part(
        interior,
        "Bakery Department Pad",
        Vector3.new(4.5, 0.5, 4.5),
        CFrame.new(-16, 0.5, -24),
        COLORS.coral,
        Enum.Material.Neon
    )
    local bakeryDepartmentPrompt =
        prompt(bakeryExpansionPad, "Build Bakery ($350)", "New Department", "BuildBakery", 10)
    bakeryDepartmentPrompt.Enabled = false
    cinnamonTwistStockPrompt =
        prompt(bakeryExpansionPad, "Stock Display", "Cinnamon Twists", "StockCinnamonTwists", 9)
    cinnamonTwistStockPrompt.Enabled = false
    pricePrompts.cinnamonTwists =
        prompt(bakeryExpansionPad, "Change Price", "Cinnamon Twists", "ChangePrice", 9)
    pricePrompts.cinnamonTwists.Enabled = false
    local freezerExpansionPad = part(
        interior,
        "Freezer Department Pad",
        Vector3.new(4.5, 0.5, 4.5),
        CFrame.new(-16, 0.5, -34),
        COLORS.blue,
        Enum.Material.Neon
    )
    local freezerDepartmentPrompt = prompt(
        freezerExpansionPad,
        "Build Freezer Section ($400)",
        "New Department",
        "BuildFreezer",
        10
    )
    freezerDepartmentPrompt.Enabled = false
    local retailPlotBuild = {
        pad = part(
            interior,
            "Retail Expansion Plot Pad",
            Vector3.new(4.5, 0.5, 4.5),
            CFrame.new(18, 0.5, -36),
            COLORS.gold,
            Enum.Material.Neon
        ),
    }
    retailPlotBuild.prompt =
        prompt(retailPlotBuild.pad, "Build Retail Plot ($900)", "Store Expansion", "RetailPlot", 10)
    retailPlotBuild.prompt.Enabled = false
    retailPlotBuild.pad.Transparency = 1
    retailPlotBuild.pad.CanCollide = false
    frozenMealStockPrompt =
        prompt(freezerExpansionPad, "Stock Freezer", "Freezer Meals", "StockFrozenMeals", 9)
    frozenMealStockPrompt.Enabled = false
    pricePrompts.frozenMeals =
        prompt(freezerExpansionPad, "Change Price", "Freezer Meals", "ChangePrice", 9)
    pricePrompts.frozenMeals.Enabled = false
    local floorExpansionSign = label(
        interior,
        "Rear Department Expansion Sign",
        "REAR MARKET WING\n$500",
        Vector3.new(5, 2.5, 0.4),
        CFrame.new(17.5, 4, -17.1),
        COLORS.green,
        COLORS.warmWhite
    )
    local upgradeSign = label(
        interior,
        "Upgrade Sign",
        "UPGRADE\n$45",
        Vector3.new(5, 2.7, 0.4),
        CFrame.new(17.5, 4.3, 9.4),
        COLORS.teal
    )
    local upgradeMarker = Instance.new("BillboardGui")
    upgradeMarker.Name = "UpgradeDirectionMarker"
    upgradeMarker.Adornee = upgradePad
    upgradeMarker.Size = UDim2.fromOffset(180, 64)
    upgradeMarker.StudsOffset = Vector3.new(0, 4.5, 0)
    upgradeMarker.AlwaysOnTop = true
    upgradeMarker.MaxDistance = 250
    upgradeMarker.Enabled = false
    upgradeMarker.Parent = upgradePad
    local markerText = Instance.new("TextLabel")
    markerText.Size = UDim2.fromScale(1, 1)
    markerText.BackgroundColor3 = COLORS.deepTeal
    markerText.BackgroundTransparency = 0.05
    markerText.Text = "UPGRADE  $45"
    markerText.TextColor3 = COLORS.gold
    markerText.Font = Enum.Font.GothamBold
    markerText.TextScaled = true
    markerText.Parent = upgradeMarker
    local markerCorner = Instance.new("UICorner")
    markerCorner.CornerRadius = UDim.new(0, 10)
    markerCorner.Parent = markerText

    local stylePad = part(
        interior,
        "Storefront Style Pad",
        Vector3.new(5.5, 0.55, 5.5),
        CFrame.new(-17.5, 0.52, 12.5),
        COLORS.green,
        Enum.Material.Neon
    )
    local stylePrompt =
        prompt(stylePad, "Install Preview ($180)", "Store Refresh", "MarketStyle", 10)
    stylePrompt.Enabled = false
    local stylePreviewPad = part(
        interior,
        "Storefront Preview Pad",
        Vector3.new(4.5, 0.35, 4.5),
        CFrame.new(-11.5, 0.52, 12.5),
        COLORS.gold,
        Enum.Material.Neon
    )
    local stylePreviewPrompt = prompt(
        stylePreviewPad,
        "Preview Next Style",
        "Store Interior Preview",
        "PreviewMarketStyle",
        10
    )
    stylePreviewPrompt.ActionText = "Next Style / Cancel"
    stylePreviewPrompt.Enabled = false
    local styleSign = label(
        interior,
        "Store Style Sign",
        "COASTAL MARKET\n$180",
        Vector3.new(5, 2.7, 0.4),
        CFrame.new(-17.5, 4.3, 9.4),
        COLORS.green
    )
    local marketStylePurchased = false
    local marketStylePreviewId = nil
    local marketStyleId = ""
    local MARKET_STYLES = {
        coastal = {
            name = "Coastal Market",
            fascia = COLORS.green,
            sign = COLORS.green,
            canopy = COLORS.gold,
            valance = COLORS.teal,
            header = COLORS.green,
            floor = COLORS.cream,
            wall = COLORS.warmWhite,
            wallAccent = COLORS.green,
            shelfBody = COLORS.teal,
            shelfAccent = COLORS.gold,
            departmentSign = COLORS.deepTeal,
            checkout = COLORS.deepTeal,
            checkoutAccent = COLORS.wood,
        },
        urban = {
            name = "City Grocer",
            fascia = COLORS.deepTeal,
            sign = COLORS.deepTeal,
            canopy = COLORS.gray,
            valance = COLORS.coral,
            header = COLORS.deepTeal,
            floor = Color3.fromRGB(221, 228, 229),
            wall = Color3.fromRGB(246, 247, 245),
            wallAccent = COLORS.coral,
            shelfBody = COLORS.gray,
            shelfAccent = COLORS.deepTeal,
            departmentSign = COLORS.deepTeal,
            checkout = COLORS.ink,
            checkoutAccent = COLORS.coral,
        },
        harvest = {
            name = "Harvest Market",
            fascia = COLORS.coral,
            sign = COLORS.green,
            canopy = COLORS.gold,
            valance = COLORS.green,
            header = COLORS.coral,
            floor = Color3.fromRGB(242, 225, 193),
            wall = COLORS.warmWhite,
            wallAccent = COLORS.gold,
            shelfBody = COLORS.wood,
            shelfAccent = COLORS.green,
            departmentSign = COLORS.green,
            checkout = COLORS.green,
            checkoutAccent = COLORS.wood,
        },
    }
    local function applyMarketStyle(styleId)
        local selectedStyle = MARKET_STYLES[styleId]
        stylePad.Color = selectedStyle and COLORS.deepTeal or COLORS.green
        styleSign.Color = selectedStyle and COLORS.teal or COLORS.green
        storefrontFascia.Color = selectedStyle and selectedStyle.fascia or COLORS.teal
        storefrontSign.Color = selectedStyle and selectedStyle.sign or COLORS.teal
        entryCanopy.Color = selectedStyle and selectedStyle.canopy or COLORS.coral
        canopyValance.Color = selectedStyle and selectedStyle.valance or COLORS.deepTeal
        frontHeader.Color = selectedStyle and selectedStyle.header or COLORS.teal
        local paletteColors = {
            Floor = selectedStyle and selectedStyle.floor or COLORS.cream,
            Wall = selectedStyle and selectedStyle.wall or COLORS.cream,
            WallAccent = selectedStyle and selectedStyle.wallAccent or COLORS.teal,
            ShelfBody = selectedStyle and selectedStyle.shelfBody or COLORS.cream,
            ShelfAccent = selectedStyle and selectedStyle.shelfAccent or COLORS.blue,
            DepartmentSign = selectedStyle and selectedStyle.departmentSign or COLORS.deepTeal,
            Checkout = selectedStyle and selectedStyle.checkout or COLORS.deepTeal,
            CheckoutAccent = selectedStyle and selectedStyle.checkoutAccent or COLORS.wood,
        }
        for _, item in ipairs(interior:GetDescendants()) do
            if item:IsA("BasePart") then
                local role = item:GetAttribute("MarketPaletteRole")
                local color = role and paletteColors[role]
                if color then
                    item.Color = color
                end
            end
        end
        stylePrompt.ActionText = selectedStyle and "Install Style ($180)"
            or "Install Preview ($180)"
        stylePreviewPrompt.ActionText = "Preview Next Store Style / Cancel"
        local surface = styleSign:FindFirstChildOfClass("SurfaceGui")
        local signText = surface and surface:FindFirstChildOfClass("TextLabel")
        if signText then
            local name = selectedStyle and selectedStyle.name or "STORE REFRESH"
            signText.Text = if marketStylePurchased
                then string.upper(name) .. "\nINSTALLED"
                elseif selectedStyle then string.upper(name) .. "\nPREVIEW"
                else "CHOOSE A STYLE\n$180"
        end
        stylePrompt.Enabled = not marketStylePurchased and currentStage == "Complete"
        stylePreviewPrompt.Enabled = not marketStylePurchased and currentStage == "Complete"
    end
    local function setMarketStyle(purchased, styleId)
        marketStylePurchased = purchased == true
        marketStyleId = marketStylePurchased and MARKET_STYLES[styleId] and styleId or ""
        marketStylePreviewId = nil
        local displayStyleId = marketStylePurchased and marketStyleId or nil
        applyMarketStyle(displayStyleId)
    end
    local function setMarketStylePreview(styleId)
        marketStylePreviewId = MARKET_STYLES[styleId] and styleId or nil
        applyMarketStyle(marketStylePurchased and marketStyleId or marketStylePreviewId)
    end
    local function getMarketStyleName(styleId)
        local style = MARKET_STYLES[styleId]
        return style and style.name or "Coastal Market"
    end

    -- A single anchored cart root is tweened only while the opening event is active.
    local cart = Instance.new("Model")
    cart.Name = "Runaway Shopping Cart"
    cart.Parent = exterior
    local root = part(
        cart,
        "Cart Root",
        Vector3.new(2.8, 0.35, 3.8),
        CFrame.new(-5, 1.3, 25),
        COLORS.gray,
        Enum.Material.Metal
    )
    root.CanCollide = false
    cart.PrimaryPart = root
    for _, definition in ipairs({
        { "Basket Front", Vector3.new(2.5, 1.5, 0.2), CFrame.new(-5, 2.1, 23.2) },
        { "Basket Back", Vector3.new(2.5, 1.5, 0.2), CFrame.new(-5, 2.1, 26.8) },
        { "Basket Left", Vector3.new(0.2, 1.5, 3.4), CFrame.new(-6.25, 2.1, 25) },
        { "Basket Right", Vector3.new(0.2, 1.5, 3.4), CFrame.new(-3.75, 2.1, 25) },
        { "Handle", Vector3.new(2.4, 0.25, 0.25), CFrame.new(-5, 2.9, 27.8) },
    }) do
        local piece = part(
            cart,
            definition[1],
            definition[2],
            definition[3],
            COLORS.gray,
            Enum.Material.Metal
        )
        piece.CanCollide = false
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = root
        weld.Part1 = piece
        weld.Parent = root
        piece.Anchored = false
    end
    for _, x in ipairs({ -6, -4 }) do
        for _, z in ipairs({ 23.7, 26.3 }) do
            local wheel = part(
                cart,
                "Cart Wheel",
                Vector3.new(0.65, 0.65, 0.25),
                CFrame.new(x, 0.65, z),
                COLORS.deepTeal,
                Enum.Material.SmoothPlastic
            )
            wheel.CanCollide = false
            wheel.Shape = Enum.PartType.Cylinder
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = root
            weld.Part1 = wheel
            weld.Parent = root
            wheel.Anchored = false
        end
    end
    local cartPrompt = prompt(root, "Stop Runaway Cart", "Shopping Cart", "Cart", 10)
    local cartTween

    for _, x in ipairs({ -31, 31 }) do
        createTree(exterior, x, 23)
        createTree(exterior, x + (x < 0 and -12 or 12), -5)
    end
    for _, x in ipairs({ -8, 8 }) do
        local planter = part(
            exterior,
            "Entry Planter",
            Vector3.new(3, 0.9, 3),
            CFrame.new(x, 0.8, 23),
            COLORS.wood,
            Enum.Material.Wood
        )
        local leaves = part(
            exterior,
            "Planter Greens",
            Vector3.new(2.5, 1.7, 2.5),
            CFrame.new(x, 2.0, 23),
            COLORS.green,
            Enum.Material.Grass
        )
        leaves.Shape = Enum.PartType.Ball
        planter:SetAttribute("Decorative", true)
    end
    part(
        exterior,
        "Cart Return Bay Pad",
        Vector3.new(10, 0.15, 5),
        CFrame.new(-46, 0.43, 28.5),
        COLORS.gray,
        Enum.Material.Concrete
    )
    for _, x in ipairs({ -50.5, -41.5 }) do
        part(
            exterior,
            "Cart Return Shelter Post",
            Vector3.new(0.25, 3.4, 0.25),
            CFrame.new(x, 2.15, 30.5),
            COLORS.deepTeal,
            Enum.Material.Metal
        )
    end
    part(
        exterior,
        "Cart Return Shelter Roof",
        Vector3.new(10, 0.35, 5),
        CFrame.new(-46, 4, 28.5),
        COLORS.teal,
        Enum.Material.Metal
    )
    label(
        exterior,
        "Cart Return Sign",
        "CART RETURN",
        Vector3.new(8, 1.1, 0.3),
        CFrame.new(-46, 3.25, 31.1),
        COLORS.deepTeal,
        COLORS.warmWhite
    )
    for _, x in ipairs({ -49, -46, -43 }) do
        part(
            exterior,
            "Parked Cart Basket",
            Vector3.new(1.65, 0.9, 1.25),
            CFrame.new(x, 1.55, 27.8),
            COLORS.gray,
            Enum.Material.Metal
        )
        part(
            exterior,
            "Parked Cart Handle",
            Vector3.new(1.5, 0.12, 0.12),
            CFrame.new(x, 2.15, 29.0),
            COLORS.deepTeal,
            Enum.Material.Metal
        )
        for _, wheelX in ipairs({ x - 0.62, x + 0.62 }) do
            local wheel = part(
                exterior,
                "Parked Cart Wheel",
                Vector3.new(0.3, 0.3, 0.16),
                CFrame.new(wheelX, 0.72, 27.5),
                COLORS.ink,
                Enum.Material.SmoothPlastic
            )
            wheel.Shape = Enum.PartType.Cylinder
        end
    end
    part(
        exterior,
        "Future Business Plot",
        Vector3.new(24, 0.2, 26),
        CFrame.new(59, 0.05, -3),
        COLORS.gray,
        Enum.Material.Concrete
    )
    local cafePurchased = false
    local cafeStock = 0
    local cafeSales = 0
    local cafeModel
    local cafeCupVisuals = {}
    local cafeMenuLabel
    local cafeRestockPrompt
    local cafeServePrompt
    local restaurantPurchased = false
    local restaurantStock = 0
    local restaurantSales = 0
    local restaurantModel
    local restaurantMealVisuals = {}
    local restaurantMenuLabel
    local restaurantRestockPrompt
    local restaurantServePrompt
    local electronicsStorePurchased = false
    local electronicsStock = 0
    local electronicsSales = 0
    local electronicsStoreModel
    local electronicsItemVisuals = {}
    local electronicsMenuLabel
    local electronicsRestockPrompt
    local electronicsSalePrompt
    local gardenStorePurchased = false
    local gardenStock = 0
    local gardenSales = 0
    local gardenStoreModel
    local gardenItemVisuals = {}
    local gardenMenuLabel
    local gardenRestockPrompt
    local gardenSalePrompt
    local floristStorePurchased = false
    local floristStock = 0
    local floristSales = 0
    local floristItemVisuals = {}
    local floristMenuLabel
    local floristRestockPrompt
    local floristSalePrompt
    local bookshopPurchased = false
    local bookshopStock = 0
    local bookshopSales = 0
    local bookshopItemVisuals = {}
    local bookshopMenuLabel
    local bookshopBuildPad
    local bookshopBuildPrompt
    local bookshopRestockPrompt
    local bookshopSalePrompt
    local plazaStylePurchased = false
    local plazaStyleId = ""
    local plazaStylePreviewId = nil
    local PLAZA_STYLES = {
        coastal = {
            name = "Coastal Walk",
            awning = COLORS.teal,
            roof = COLORS.cream,
            path = COLORS.gray,
        },
        urban = {
            name = "City Lights",
            awning = COLORS.coral,
            roof = COLORS.deepTeal,
            path = COLORS.gray,
        },
        harvest = {
            name = "Harvest Lane",
            awning = COLORS.green,
            roof = COLORS.wood,
            path = COLORS.cream,
        },
    }
    part(
        exterior,
        "Cafe Plaza Walkway",
        Vector3.new(10, 0.18, 24),
        CFrame.new(-65, 0.1, 19),
        COLORS.gray,
        Enum.Material.Concrete
    )
    part(
        exterior,
        "Cafe Plaza Walkway Connector",
        Vector3.new(14, 0.18, 8),
        CFrame.new(-58, 0.1, 13),
        COLORS.gray,
        Enum.Material.Concrete
    )
    part(
        exterior,
        "Restaurant Plaza Walkway",
        Vector3.new(8, 0.18, 142),
        CFrame.new(-80, 0.1, -50),
        COLORS.gray,
        Enum.Material.Concrete
    )
    part(
        exterior,
        "Restaurant Walkway Connector",
        Vector3.new(30, 0.18, 10),
        CFrame.new(-65, 0.1, -25.8),
        COLORS.gray,
        Enum.Material.Concrete
    )
    part(
        exterior,
        "Electronics Plaza Walkway Connector",
        Vector3.new(30, 0.18, 10),
        CFrame.new(-65, 0.1, -65.8),
        COLORS.gray,
        Enum.Material.Concrete
    )
    part(
        exterior,
        "Garden Plaza Walkway Connector",
        Vector3.new(30, 0.18, 10),
        CFrame.new(-65, 0.1, -105.8),
        COLORS.gray,
        Enum.Material.Concrete
    )
    part(
        exterior,
        "Cafe Side Walkway Connector",
        Vector3.new(10, 0.18, 8),
        CFrame.new(-75, 0.1, 19),
        COLORS.gray,
        Enum.Material.Concrete
    )
    local cafeBuildPad = part(
        exterior,
        "Corner Cafe Purchase Pad",
        Vector3.new(4.5, 0.5, 4.5),
        CFrame.new(-52.5, 0.45, 9),
        COLORS.gold,
        Enum.Material.Neon
    )
    local cafeBuildPrompt =
        prompt(cafeBuildPad, "Build Corner Café ($650)", "Plaza Business", "BuildCafe", 10)
    cafeBuildPrompt.Enabled = false
    local cafeCounter = part(
        exterior,
        "Corner Cafe Counter",
        Vector3.new(8, 1.5, 1.6),
        CFrame.new(-65, 1.25, 1.5),
        COLORS.wood,
        Enum.Material.WoodPlanks,
        1
    )
    cafeRestockPrompt =
        prompt(cafeCounter, "Brew Coffee Batch ($45)", "Corner Café", "RestockCafe", 10)
    cafeServePrompt = prompt(cafeCounter, "Serve Coffee ($18)", "Corner Café", "ServeCafe", 10)
    cafeRestockPrompt.Enabled = false
    cafeServePrompt.Enabled = false
    local cafeMenuBoard = label(
        exterior,
        "Corner Cafe Menu Board",
        "CORNER CAFÉ\nCOFFEE $18\nSTOCK 0  •  SALES 0",
        Vector3.new(8, 3, 0.35),
        CFrame.new(-65, 5.3, 6.7),
        COLORS.deepTeal,
        COLORS.warmWhite
    )
    cafeMenuBoard.Transparency = 1
    local cafeMenuSurface = cafeMenuBoard:FindFirstChildOfClass("SurfaceGui")
    if cafeMenuSurface then
        cafeMenuSurface.Enabled = false
        cafeMenuLabel = cafeMenuSurface:FindFirstChildOfClass("TextLabel")
    end
    local restaurantBuildPad = part(
        exterior,
        "Market Table Restaurant Purchase Pad",
        Vector3.new(4.5, 0.5, 4.5),
        CFrame.new(-52.5, 0.45, -29.5),
        COLORS.gold,
        Enum.Material.Neon
    )
    local restaurantBuildPrompt = prompt(
        restaurantBuildPad,
        "Build Market Table ($1,200)",
        "Plaza Business",
        "BuildRestaurant",
        10
    )
    restaurantBuildPrompt.Enabled = false
    local restaurantCounter = part(
        exterior,
        "Market Table Service Counter",
        Vector3.new(9, 1.5, 1.8),
        CFrame.new(-65, 1.25, -38),
        COLORS.wood,
        Enum.Material.WoodPlanks,
        1
    )
    restaurantRestockPrompt =
        prompt(restaurantCounter, "Prep Meal Batch ($80)", "Market Table", "RestockRestaurant", 10)
    restaurantServePrompt =
        prompt(restaurantCounter, "Serve Market Bowl ($38)", "Market Table", "ServeRestaurant", 10)
    restaurantRestockPrompt.Enabled = false
    restaurantServePrompt.Enabled = false
    local restaurantMenuBoard = label(
        exterior,
        "Market Table Menu Board",
        "MARKET TABLE\nGARDEN BOWL $38\nSTOCK 0  •  SALES 0",
        Vector3.new(8, 3, 0.35),
        CFrame.new(-65, 5.3, -32.7),
        COLORS.deepTeal,
        COLORS.warmWhite
    )
    restaurantMenuBoard.Transparency = 1
    local restaurantMenuSurface = restaurantMenuBoard:FindFirstChildOfClass("SurfaceGui")
    if restaurantMenuSurface then
        restaurantMenuSurface.Enabled = false
        restaurantMenuLabel = restaurantMenuSurface:FindFirstChildOfClass("TextLabel")
    end
    local electronicsBuildPad = part(
        exterior,
        "Pixel and Plug Purchase Pad",
        Vector3.new(4.5, 0.5, 4.5),
        CFrame.new(-52.5, 0.45, -70),
        COLORS.gold,
        Enum.Material.Neon
    )
    local electronicsBuildPrompt = prompt(
        electronicsBuildPad,
        "Build Pixel & Plug ($2,400)",
        "Plaza Business",
        "BuildElectronicsStore",
        10
    )
    electronicsBuildPrompt.Enabled = false
    local electronicsCounter = part(
        exterior,
        "Pixel and Plug Service Counter",
        Vector3.new(9, 1.5, 1.8),
        CFrame.new(-65, 1.25, -78),
        COLORS.wood,
        Enum.Material.WoodPlanks,
        1
    )
    electronicsRestockPrompt = prompt(
        electronicsCounter,
        "Restock Headphones ($300)",
        "Pixel & Plug",
        "RestockElectronics",
        10
    )
    electronicsSalePrompt =
        prompt(electronicsCounter, "Sell Headphones ($220)", "Pixel & Plug", "SellElectronics", 10)
    electronicsRestockPrompt.Enabled = false
    electronicsSalePrompt.Enabled = false
    local electronicsMenuBoard = label(
        exterior,
        "Pixel and Plug Store Sign",
        "PIXEL & PLUG\nWIRELESS HEADPHONES $220\nSTOCK 0  •  SALES 0",
        Vector3.new(9, 3, 0.35),
        CFrame.new(-65, 5.3, -72.7),
        COLORS.deepTeal,
        COLORS.warmWhite
    )
    electronicsMenuBoard.Transparency = 1
    local electronicsMenuSurface = electronicsMenuBoard:FindFirstChildOfClass("SurfaceGui")
    if electronicsMenuSurface then
        electronicsMenuSurface.Enabled = false
        electronicsMenuLabel = electronicsMenuSurface:FindFirstChildOfClass("TextLabel")
    end
    local gardenBuildPad = part(
        exterior,
        "Little Sprout Garden Purchase Pad",
        Vector3.new(4.5, 0.5, 4.5),
        CFrame.new(-52.5, 0.45, -110),
        COLORS.gold,
        Enum.Material.Neon
    )
    local gardenBuildPrompt = prompt(
        gardenBuildPad,
        "Build Little Sprout ($1,800)",
        "Plaza Business",
        "BuildGardenStore",
        10
    )
    gardenBuildPrompt.Enabled = false
    local gardenCounter = part(
        exterior,
        "Little Sprout Garden Counter",
        Vector3.new(9, 1.5, 1.8),
        CFrame.new(-65, 1.25, -118),
        COLORS.wood,
        Enum.Material.WoodPlanks,
        1
    )
    gardenRestockPrompt =
        prompt(gardenCounter, "Restock Herbs ($120)", "Little Sprout", "RestockGarden", 10)
    gardenSalePrompt =
        prompt(gardenCounter, "Sell Potted Herb ($75)", "Little Sprout", "SellGarden", 10)
    gardenRestockPrompt.Enabled = false
    gardenSalePrompt.Enabled = false
    local gardenMenuBoard = label(
        exterior,
        "Little Sprout Garden Sign",
        "LITTLE SPROUT GARDEN\nPOTTED HERBS $75\nSTOCK 0  •  SALES 0",
        Vector3.new(9, 3, 0.35),
        CFrame.new(-65, 5.3, -112.7),
        COLORS.green,
        COLORS.warmWhite
    )
    gardenMenuBoard.Transparency = 1
    local gardenMenuSurface = gardenMenuBoard:FindFirstChildOfClass("SurfaceGui")
    if gardenMenuSurface then
        gardenMenuSurface.Enabled = false
        gardenMenuLabel = gardenMenuSurface:FindFirstChildOfClass("TextLabel")
    end
    local floristBuildPad = part(
        exterior,
        "Maple Corner Florist Purchase Pad",
        Vector3.new(4.5, 0.5, 4.5),
        CFrame.new(43, 0.45, -57),
        COLORS.gold,
        Enum.Material.Neon
    )
    local floristBuildPrompt =
        prompt(floristBuildPad, "Build Maple Corner ($1,500)", "Plaza Business", "BuildFlorist", 10)
    floristBuildPrompt.Enabled = false
    local floristCounter = part(
        floristShell,
        "Maple Corner Florist Counter",
        Vector3.new(8, 1.4, 1.8),
        CFrame.new(54, 1.2, -67.8),
        COLORS.wood,
        Enum.Material.WoodPlanks
    )
    floristRestockPrompt = prompt(
        floristCounter,
        "Restock Bouquets ($320)",
        "Maple Corner Florist",
        "RestockFlorist",
        10
    )
    floristSalePrompt =
        prompt(floristCounter, "Sell Bouquet ($240)", "Maple Corner Florist", "SellFlorist", 10)
    floristRestockPrompt.Enabled = false
    floristSalePrompt.Enabled = false
    local floristSign = label(
        floristShell,
        "Maple Corner Florist Menu",
        "MAPLE CORNER FLORIST\nFRESH BOUQUETS $240\nSTOCK 0  •  SALES 0",
        Vector3.new(8, 2.5, 0.3),
        CFrame.new(54, 4.8, -64.55),
        COLORS.green,
        COLORS.warmWhite
    )
    local floristSurface = floristSign:FindFirstChildOfClass("SurfaceGui")
    if floristSurface then
        floristMenuLabel = floristSurface:FindFirstChildOfClass("TextLabel")
    end
    for index = 1, Economy.FLORIST_SHELF_CAPACITY do
        local bouquet = part(
            floristShell,
            "Fresh Bouquet Display",
            Vector3.new(1.1, 1.7, 1.1),
            CFrame.new(50.5 + ((index - 1) % 6) * 1.7, 1.2, -75 + math.floor((index - 1) / 6) * 2.3),
            if index % 2 == 0 then COLORS.coral else COLORS.gold,
            Enum.Material.SmoothPlastic
        )
        bouquet.Shape = Enum.PartType.Ball
        bouquet.CanCollide = false
        bouquet.Transparency = 1
        table.insert(floristItemVisuals, bouquet)
    end
    bookshopBuildPad = part(
        exterior,
        "Riverside Bookshop Purchase Pad",
        Vector3.new(4.5, 0.5, 4.5),
        CFrame.new(78, 0.45, -57),
        COLORS.gold,
        Enum.Material.Neon
    )
    bookshopBuildPrompt =
        prompt(bookshopBuildPad, "Open Bookshop ($2,500)", "Plaza Business", "BuildBookshop", 10)
    bookshopBuildPrompt.Enabled = false
    local bookshopCounter = part(
        bookshopShell,
        "Riverside Bookshop Counter",
        Vector3.new(8, 1.4, 1.8),
        CFrame.new(79, 1.2, -67.8),
        COLORS.wood,
        Enum.Material.WoodPlanks
    )
    bookshopRestockPrompt = prompt(
        bookshopCounter,
        "Restock Paperbacks ($300)",
        "Riverside Bookshop",
        "RestockBookshop",
        10
    )
    bookshopSalePrompt =
        prompt(bookshopCounter, "Sell Paperback ($130)", "Riverside Bookshop", "SellBookshop", 10)
    bookshopRestockPrompt.Enabled = false
    bookshopSalePrompt.Enabled = false
    local bookshopSign = label(
        bookshopShell,
        "Riverside Bookshop Menu",
        "RIVERSIDE BOOKSHOP\nPAPERBACKS $130\nSTOCK 0  •  SALES 0",
        Vector3.new(8, 2.5, 0.3),
        CFrame.new(79, 4.8, -64.55),
        COLORS.coral,
        COLORS.warmWhite
    )
    local bookshopSurface = bookshopSign:FindFirstChildOfClass("SurfaceGui")
    if bookshopSurface then
        bookshopMenuLabel = bookshopSurface:FindFirstChildOfClass("TextLabel")
    end
    for shelfIndex = 1, 3 do
        local shelfX = 72 + shelfIndex * 4.5
        part(
            bookshopShell,
            "Paperback Bookcase",
            Vector3.new(3.8, 4.8, 0.7),
            CFrame.new(shelfX, 2.8, -77),
            COLORS.wood,
            Enum.Material.WoodPlanks
        )
        for level = 1, 2 do
            part(
                bookshopShell,
                "Bookcase Shelf",
                Vector3.new(3.5, 0.18, 1.15),
                CFrame.new(shelfX, 1.6 + level * 1.65, -76.3),
                COLORS.warmWhite,
                Enum.Material.WoodPlanks
            )
        end
    end
    local bookColors = { COLORS.blue, COLORS.green, COLORS.coral, COLORS.gold }
    for index = 1, Economy.BOOKSHOP_SHELF_CAPACITY do
        local column = (index - 1) % 6
        local row = math.floor((index - 1) / 6)
        local paperback = part(
            bookshopShell,
            "Paperback Display",
            Vector3.new(0.68, 1.1, 0.22),
            CFrame.new(73.5 + column * 2.15, 2 + row * 2, -75.5),
            bookColors[((index - 1) % #bookColors) + 1],
            Enum.Material.SmoothPlastic
        )
        paperback.CanCollide = false
        paperback.Transparency = 1
        table.insert(bookshopItemVisuals, paperback)
    end
    local plazaStylePad = part(
        exterior,
        "Plaza Style Installation Pad",
        Vector3.new(4.5, 0.5, 4.5),
        CFrame.new(-52.5, 0.45, -51),
        COLORS.green,
        Enum.Material.Neon
    )
    local plazaStylePrompt =
        prompt(plazaStylePad, "Install Plaza Style ($750)", "Plaza Refresh", "PlazaStyle", 10)
    plazaStylePrompt.Enabled = false
    local plazaStylePreviewPad = part(
        exterior,
        "Plaza Style Preview Pad",
        Vector3.new(4.5, 0.35, 4.5),
        CFrame.new(-58, 0.38, -51),
        COLORS.gold,
        Enum.Material.Neon
    )
    local plazaStylePreviewPrompt = prompt(
        plazaStylePreviewPad,
        "Preview Next Style",
        "Plaza Style Preview",
        "PreviewPlazaStyle",
        10
    )
    plazaStylePreviewPrompt.ActionText = "Next Style / Cancel"
    plazaStylePreviewPrompt.Enabled = false
    local plazaStyleSign = label(
        exterior,
        "Plaza Style Sign",
        "PLAZA REFRESH\nPREVIEW / INSTALL $750",
        Vector3.new(8, 2.6, 0.35),
        CFrame.new(-55.2, 4.2, -47.9),
        COLORS.deepTeal,
        COLORS.warmWhite
    )
    local warehousePad = part(
        exterior,
        "Warehouse Expansion Pad",
        Vector3.new(5, 0.5, 5),
        CFrame.new(59, 0.45, 7),
        COLORS.gold,
        Enum.Material.Neon
    )
    local warehousePrompt =
        prompt(warehousePad, "Build Warehouse ($200)", "Retail Empire Expansion", "Warehouse", 10)
    local deliveryFleetPad = part(
        exterior,
        "Regional Delivery Fleet Pad",
        Vector3.new(4.5, 0.5, 4.5),
        CFrame.new(75, 0.45, 10),
        COLORS.gold,
        Enum.Material.Neon
    )
    local deliveryFleetPrompt = prompt(
        deliveryFleetPad,
        "Add Delivery Fleet ($3,000)",
        "Retail Empire Logistics",
        "DeliveryFleet",
        10
    )
    deliveryFleetPrompt.Enabled = false
    local distributionCenterPad = part(
        exterior,
        "Regional Distribution Center Pad",
        Vector3.new(4.5, 0.5, 4.5),
        CFrame.new(82, 0.45, 7),
        COLORS.gold,
        Enum.Material.Neon
    )
    local distributionCenterPrompt = prompt(
        distributionCenterPad,
        "Build Distribution Center ($6,000)",
        "Regional Logistics",
        "DistributionCenter",
        10
    )
    distributionCenterPrompt.Enabled = false
    local supplierPartnershipPad = part(
        exterior,
        "Regional Supplier Partnership Pad",
        Vector3.new(3.5, 0.5, 3.5),
        CFrame.new(70.5, 0.45, -12),
        COLORS.gold,
        Enum.Material.Neon
    )
    supplierPartnershipPad.Transparency = 1
    supplierPartnershipPad.CanCollide = false
    local supplierPartnershipPrompt = prompt(
        supplierPartnershipPad,
        "Sign Supplier Partnership ($2,500)",
        "Regional Distribution",
        "SupplierPartnership",
        10
    )
    supplierPartnershipPrompt.Enabled = false
    local supplierPartnershipPurchased = false
    local distributionCenterModel
    local distributionCenterPurchased = false
    local warehouseModel
    local warehousePurchased = false
    local layoutFixtureFolder
    local layoutAnchor = part(
        exterior,
        "Warehouse Layout Board",
        Vector3.new(5, 2.2, 0.3),
        CFrame.new(59, 2.4, 4.2),
        COLORS.teal
    )
    layoutAnchor.Transparency = 1
    layoutAnchor.CanCollide = false
    local layoutHeader = label(
        exterior,
        "Warehouse Layout Header",
        "STORAGE BUILD ZONE",
        Vector3.new(5, 0.8, 0.25),
        CFrame.new(59, 4.1, 4.05),
        COLORS.deepTeal
    )
    layoutHeader.Transparency = 1
    local layoutHeaderSurface = layoutHeader:FindFirstChildOfClass("SurfaceGui")
    if layoutHeaderSurface then
        layoutHeaderSurface.Enabled = false
    end
    local layoutPrompt =
        prompt(layoutAnchor, "Edit Storage Layout", "Warehouse Build Board", "EditLayout", 10)
    layoutPrompt.Enabled = false
    local retailLayoutAnchor = part(
        interior,
        "Retail Layout Station",
        Vector3.new(4.2, 2.4, 0.6),
        CFrame.new(-18.2, 1.55, 10.5),
        COLORS.teal,
        Enum.Material.WoodPlanks
    )
    label(
        interior,
        "Retail Layout Station Header",
        "MOVE DEPARTMENT SHELVES",
        Vector3.new(4.2, 0.75, 0.24),
        CFrame.new(-18.2, 3.15, 10.12),
        COLORS.deepTeal,
        COLORS.warmWhite
    )
    local retailLayoutPrompt = prompt(
        retailLayoutAnchor,
        "Arrange Store Shelves",
        "Retail Layout Station",
        "EditRetailLayout",
        12
    )
    retailLayoutPrompt.Enabled = false
    local deliveryBoardLabel
    local deliveryCrateSurface
    local deliveryCrate
    local deliveryPrompt
    local orderDeliveryPrompt
    local berryDeliveryOrderPrompt
    local appleDeliveryOrderPrompt
    local cerealDeliveryOrderPrompt
    local cinnamonTwistDeliveryOrderPrompt
    local frozenMealDeliveryOrderPrompt
    local onlineOrderBoardLabel
    local onlineOrderBoardSurface
    local onlineOrderPrompt
    local onlineOrderReady = false
    local onlineOrderBoard = label(
        exterior,
        "Online Order Packing Board",
        "ONLINE ORDER #1\nCITRUS POP x1  •  BERRY BITES x1  •  GOLDEN APPLES x1\nPACK VALUE $55",
        Vector3.new(6, 2.8, 0.4),
        CFrame.new(65.2, 3.2, -8.8),
        COLORS.teal,
        COLORS.warmWhite
    )
    onlineOrderBoard.Transparency = 1
    onlineOrderBoardSurface = onlineOrderBoard:FindFirstChildOfClass("SurfaceGui")
    if onlineOrderBoardSurface then
        onlineOrderBoardSurface.Enabled = false
        onlineOrderBoardLabel = onlineOrderBoardSurface:FindFirstChildOfClass("TextLabel")
    end
    onlineOrderPrompt = prompt(
        onlineOrderBoard,
        "Pack Online Order",
        "Delivery Packing Station",
        "FulfillOnlineOrder",
        10
    )
    onlineOrderPrompt.Enabled = false
    local deliveryProductId = "citrusPop"
    local deliveryReadyAt = 0
    local deliveryQuantity = 0
    label(
        exterior,
        "Warehouse Plot Sign",
        "WAREHOUSE EXPANSION\n$200",
        Vector3.new(10, 3, 0.5),
        CFrame.new(59, 2.5, 10),
        COLORS.teal
    )

    local orderBoard = label(
        exterior,
        "Warehouse Delivery Board",
        "ORDER 24 CANS  •  $60",
        Vector3.new(8, 3, 0.45),
        CFrame.new(48.25, 4.5, -1) * CFrame.Angles(0, -math.pi / 2, 0),
        COLORS.teal,
        COLORS.warmWhite
    )
    orderBoard.Transparency = 1
    local deliverySurface = orderBoard:FindFirstChildOfClass("SurfaceGui")
    if deliverySurface then
        deliverySurface.Enabled = false
        deliveryBoardLabel = deliverySurface:FindFirstChildOfClass("TextLabel")
    end
    orderBoard:SetAttribute("WarehouseAccess", true)
    orderDeliveryPrompt =
        prompt(orderBoard, "Order Delivery ($60)", "Warehouse Board", "OrderDelivery", 10)
    orderDeliveryPrompt.Enabled = false
    berryDeliveryOrderPrompt =
        prompt(orderBoard, "Order Berry Bites ($45)", "Warehouse Board", "OrderBerryDelivery", 10)
    berryDeliveryOrderPrompt.Enabled = false
    appleDeliveryOrderPrompt =
        prompt(orderBoard, "Order Apples ($35)", "Warehouse Board", "OrderAppleDelivery", 10)
    appleDeliveryOrderPrompt.Enabled = false
    cerealDeliveryOrderPrompt =
        prompt(orderBoard, "Order Cereal ($45)", "Warehouse Board", "OrderCerealDelivery", 10)
    cerealDeliveryOrderPrompt.Enabled = false
    cinnamonTwistDeliveryOrderPrompt = prompt(
        orderBoard,
        "Order Cinnamon Twists ($50)",
        "Warehouse Board",
        "OrderCinnamonTwistsDelivery",
        10
    )
    cinnamonTwistDeliveryOrderPrompt.Enabled = false
    frozenMealDeliveryOrderPrompt = prompt(
        orderBoard,
        "Order Freezer Meals ($55)",
        "Warehouse Board",
        "OrderFrozenMealsDelivery",
        10
    )
    frozenMealDeliveryOrderPrompt.Enabled = false
    deliveryCrate = Instance.new("Model")
    deliveryCrate.Name = "Warehouse Delivery Crate"
    deliveryCrate.Parent = exterior
    local crate = part(
        deliveryCrate,
        "Delivery Crate",
        Vector3.new(3.2, 2.3, 2.8),
        CFrame.new(59, 2.15, 8.5),
        COLORS.wood,
        Enum.Material.WoodPlanks
    )
    crate.Transparency = 1
    crate.CanCollide = false
    local crateLabel = label(
        deliveryCrate,
        "Shipment Label",
        "CITRUS POP\n24 CANS",
        Vector3.new(2.2, 1.1, 0.08),
        CFrame.new(59, 2.2, 9.92),
        COLORS.cream,
        COLORS.deepTeal
    )
    crateLabel.Transparency = 1
    crateLabel.CanCollide = false
    local crateSurface = crateLabel:FindFirstChildOfClass("SurfaceGui")
    if crateSurface then
        crateSurface.Enabled = false
        deliveryCrateSurface = crateSurface
    end
    deliveryPrompt = prompt(crate, "Receive Delivery", "Citrus Pop Shipment", "ReceiveDelivery", 10)
    deliveryPrompt.Enabled = false

    local lighting = game:GetService("Lighting")
    lighting.ClockTime = 14
    lighting.Brightness = 2.3
    lighting.Ambient = Color3.fromRGB(150, 157, 152)
    lighting.OutdoorAmbient = Color3.fromRGB(173, 182, 165)
    workspace.Gravity = 196.2

    local function setPowerOutage(active)
        local isOutage = active == true
        lighting.Brightness = isOutage and 0.65 or 2.3
        lighting.Ambient = isOutage and Color3.fromRGB(52, 62, 70) or Color3.fromRGB(150, 157, 152)
        lighting.OutdoorAmbient = isOutage and Color3.fromRGB(80, 88, 92)
            or Color3.fromRGB(173, 182, 165)
        for _, item in ipairs(interior:GetDescendants()) do
            if item:IsA("PointLight") then
                item.Enabled = not isOutage
            end
        end
        powerPrompt.Enabled = isOutage and currentStage == "PowerOutage"
        if breakerSurface then
            breakerSurface.Enabled = isOutage
        end
    end

    local function addCafe()
        if cafeModel then
            return
        end
        cafePurchased = true
        cafeModel = Instance.new("Model")
        cafeModel.Name = "Corner Cafe Plaza Business"
        cafeModel.Parent = exterior
        local center = Vector3.new(-65, 0, -2)
        part(
            cafeModel,
            "Cafe Tile Floor",
            Vector3.new(22, 0.35, 18),
            CFrame.new(center + Vector3.new(0, 0.05, 0)),
            COLORS.cream,
            Enum.Material.CeramicTiles
        )
        part(
            cafeModel,
            "Cafe Back Wall",
            Vector3.new(22, 9, 0.55),
            CFrame.new(center + Vector3.new(0, 4.5, -8.7)),
            COLORS.deepTeal
        )
        for _, side in ipairs({ -10.7, 10.7 }) do
            part(
                cafeModel,
                "Cafe Side Wall",
                Vector3.new(0.55, 9, 18),
                CFrame.new(center + Vector3.new(side, 4.5, 0)),
                COLORS.cream
            )
        end
        for _, side in ipairs({ -7.3, 7.3 }) do
            part(
                cafeModel,
                "Cafe Front Pier",
                Vector3.new(7.4, 9, 0.55),
                CFrame.new(center + Vector3.new(side, 4.5, 8.7)),
                COLORS.cream
            )
        end
        part(
            cafeModel,
            "Cafe Roof",
            Vector3.new(23, 0.8, 19),
            CFrame.new(center + Vector3.new(0, 9.4, 0)),
            COLORS.teal,
            Enum.Material.Metal
        )
        part(
            cafeModel,
            "Cafe Awning",
            Vector3.new(18, 0.35, 2.3),
            CFrame.new(center + Vector3.new(0, 7.4, 9.8)),
            COLORS.coral,
            Enum.Material.Fabric
        )
        cafeMenuBoard.Parent = cafeModel
        cafeMenuBoard.CFrame = CFrame.new(center + Vector3.new(0, 5.7, 8.95))
        cafeMenuBoard.Transparency = 0
        if cafeMenuSurface then
            cafeMenuSurface.Enabled = true
        end
        cafeCounter.Parent = cafeModel
        cafeCounter.CFrame = CFrame.new(center + Vector3.new(0, 1.45, 3.7))
        cafeCounter.Transparency = 0
        cafeCounter.CanCollide = true
        part(
            cafeModel,
            "Espresso Machine",
            Vector3.new(2.7, 2.8, 1.8),
            CFrame.new(center + Vector3.new(-2.4, 3.55, 3.1)),
            COLORS.gray,
            Enum.Material.Metal
        )
        for index = 1, 6 do
            local cup = part(
                cafeModel,
                "Coffee Cup Stock Visual",
                Vector3.new(0.38, 0.62, 0.38),
                CFrame.new(center + Vector3.new(-1 + index * 0.72, 2.5, 3.1)),
                COLORS.warmWhite,
                Enum.Material.SmoothPlastic
            )
            cup.Shape = Enum.PartType.Cylinder
            cup.CanCollide = false
            cup.Transparency = 1
            table.insert(cafeCupVisuals, cup)
        end
        local barista = createLowPolyPerson(
            cafeModel,
            "Corner Cafe Barista",
            center + Vector3.new(2.8, 0.45, 0.4),
            COLORS.coral,
            COLORS.wood,
            COLORS.deepTeal
        )
        for _, item in ipairs(barista:GetDescendants()) do
            if item:IsA("BasePart") then
                item.CanCollide = false
            end
        end
        cafeBuildPad.Transparency = 1
        cafeBuildPad.CanCollide = false
        cafeBuildPrompt.Enabled = false
    end

    local function addRestaurant()
        if restaurantModel then
            return
        end
        restaurantPurchased = true
        restaurantModel = Instance.new("Model")
        restaurantModel.Name = "Market Table Restaurant Plaza Business"
        restaurantModel.Parent = exterior
        local center = Vector3.new(-65, 0, -42)
        part(
            restaurantModel,
            "Restaurant Tile Floor",
            Vector3.new(26, 0.35, 20),
            CFrame.new(center + Vector3.new(0, 0.05, 0)),
            COLORS.cream,
            Enum.Material.CeramicTiles
        )
        part(
            restaurantModel,
            "Restaurant Back Wall",
            Vector3.new(26, 9, 0.55),
            CFrame.new(center + Vector3.new(0, 4.5, -9.7)),
            COLORS.wood,
            Enum.Material.WoodPlanks
        )
        for _, side in ipairs({ -12.7, 12.7 }) do
            part(
                restaurantModel,
                "Restaurant Side Wall",
                Vector3.new(0.6, 9, 20),
                CFrame.new(center + Vector3.new(side, 4.5, 0)),
                COLORS.cream
            )
        end
        for _, side in ipairs({ -8.8, 8.8 }) do
            part(
                restaurantModel,
                "Restaurant Front Pier",
                Vector3.new(8.3, 9, 0.6),
                CFrame.new(center + Vector3.new(side, 4.5, 9.7)),
                COLORS.cream
            )
        end
        part(
            restaurantModel,
            "Restaurant Roof",
            Vector3.new(27, 0.8, 21),
            CFrame.new(center + Vector3.new(0, 9.4, 0)),
            COLORS.deepTeal,
            Enum.Material.Metal
        )
        part(
            restaurantModel,
            "Restaurant Awning",
            Vector3.new(20, 0.35, 2.4),
            CFrame.new(center + Vector3.new(0, 7.4, 10.8)),
            COLORS.gold,
            Enum.Material.Fabric
        )
        restaurantMenuBoard.Parent = restaurantModel
        restaurantMenuBoard.CFrame = CFrame.new(center + Vector3.new(0, 5.6, 10.05))
        restaurantMenuBoard.Transparency = 0
        if restaurantMenuSurface then
            restaurantMenuSurface.Enabled = true
        end
        restaurantCounter.Parent = restaurantModel
        restaurantCounter.CFrame = CFrame.new(center + Vector3.new(0, 1.45, 5.4))
        restaurantCounter.Transparency = 0
        restaurantCounter.CanCollide = true
        part(
            restaurantModel,
            "Meal Warmer",
            Vector3.new(2.8, 2, 1.8),
            CFrame.new(center + Vector3.new(-2.8, 3, 4.9)),
            COLORS.gray,
            Enum.Material.Metal
        )
        for index = 1, 4 do
            local meal = part(
                restaurantModel,
                "Garden Bowl Stock Visual",
                Vector3.new(0.85, 0.28, 0.85),
                CFrame.new(center + Vector3.new(-1 + index * 1.05, 2.4, 4.8)),
                COLORS.green,
                Enum.Material.SmoothPlastic
            )
            meal.Shape = Enum.PartType.Cylinder
            meal.CanCollide = false
            meal.Transparency = 1
            table.insert(restaurantMealVisuals, meal)
        end
        for _, x in ipairs({ -7, 7 }) do
            part(
                restaurantModel,
                "Dining Table",
                Vector3.new(4.5, 0.35, 3.2),
                CFrame.new(center + Vector3.new(x, 2.2, -2)),
                COLORS.wood,
                Enum.Material.WoodPlanks
            )
            for _, side in ipairs({ -1, 1 }) do
                local seat = part(
                    restaurantModel,
                    "Dining Chair Seat",
                    Vector3.new(1.2, 0.3, 1.2),
                    CFrame.new(center + Vector3.new(x + side * 2.7, 1.2, -2)),
                    COLORS.coral,
                    Enum.Material.Wood
                )
                seat.CanCollide = false
            end
        end
        local chef = createLowPolyPerson(
            restaurantModel,
            "Market Table Chef",
            center + Vector3.new(3.1, 0.45, 2.2),
            COLORS.green,
            COLORS.wood,
            COLORS.deepTeal
        )
        for _, item in ipairs(chef:GetDescendants()) do
            if item:IsA("BasePart") then
                item.CanCollide = false
            end
        end
        restaurantBuildPad.Transparency = 1
        restaurantBuildPad.CanCollide = false
        restaurantBuildPrompt.Enabled = false
    end

    local function addElectronicsStore()
        if electronicsStoreModel then
            return
        end
        electronicsStorePurchased = true
        electronicsStoreModel = Instance.new("Model")
        electronicsStoreModel.Name = "Pixel and Plug Electronics Plaza Business"
        electronicsStoreModel.Parent = exterior
        local center = Vector3.new(-65, 0, -82)
        part(
            electronicsStoreModel,
            "Electronics Store Tile Floor",
            Vector3.new(24, 0.35, 20),
            CFrame.new(center + Vector3.new(0, 0.05, 0)),
            COLORS.cream,
            Enum.Material.CeramicTiles
        )
        part(
            electronicsStoreModel,
            "Electronics Store Back Wall",
            Vector3.new(24, 9, 0.55),
            CFrame.new(center + Vector3.new(0, 4.5, -9.7)),
            COLORS.deepTeal
        )
        for _, side in ipairs({ -11.7, 11.7 }) do
            part(
                electronicsStoreModel,
                "Electronics Store Side Wall",
                Vector3.new(0.6, 9, 20),
                CFrame.new(center + Vector3.new(side, 4.5, 0)),
                COLORS.cream
            )
        end
        for _, side in ipairs({ -7.6, 7.6 }) do
            part(
                electronicsStoreModel,
                "Electronics Store Front Pier",
                Vector3.new(8, 9, 0.6),
                CFrame.new(center + Vector3.new(side, 4.5, 9.7)),
                COLORS.cream
            )
        end
        part(
            electronicsStoreModel,
            "Electronics Store Roof",
            Vector3.new(25, 0.8, 21),
            CFrame.new(center + Vector3.new(0, 9.4, 0)),
            COLORS.gray,
            Enum.Material.Metal
        )
        part(
            electronicsStoreModel,
            "Electronics Store Awning",
            Vector3.new(18, 0.35, 2.3),
            CFrame.new(center + Vector3.new(0, 7.4, 10.8)),
            COLORS.teal,
            Enum.Material.Fabric
        )
        electronicsMenuBoard.Parent = electronicsStoreModel
        electronicsMenuBoard.CFrame = CFrame.new(center + Vector3.new(0, 5.7, 10.05))
        electronicsMenuBoard.Transparency = 0
        if electronicsMenuSurface then
            electronicsMenuSurface.Enabled = true
        end
        electronicsCounter.Parent = electronicsStoreModel
        electronicsCounter.CFrame = CFrame.new(center + Vector3.new(0, 1.45, 5.4))
        electronicsCounter.Transparency = 0
        electronicsCounter.CanCollide = true
        part(
            electronicsStoreModel,
            "Headphone Display Cabinet",
            Vector3.new(10, 2.5, 2.2),
            CFrame.new(center + Vector3.new(0, 1.5, -1.8)),
            COLORS.gray,
            Enum.Material.Glass
        )
        for index = 1, 4 do
            local item = part(
                electronicsStoreModel,
                "Wireless Headphones Display",
                Vector3.new(1.25, 1.1, 0.5),
                CFrame.new(center + Vector3.new(-3.9 + index * 2.1, 3.35, -1.8)),
                COLORS.coral,
                Enum.Material.SmoothPlastic
            )
            item.CanCollide = false
            item.Transparency = 1
            table.insert(electronicsItemVisuals, item)
        end
        local clerk = createLowPolyPerson(
            electronicsStoreModel,
            "Pixel and Plug Clerk",
            center + Vector3.new(3.5, 0.45, 2),
            COLORS.teal,
            COLORS.gray,
            COLORS.deepTeal
        )
        for _, item in ipairs(clerk:GetDescendants()) do
            if item:IsA("BasePart") then
                item.CanCollide = false
            end
        end
        electronicsBuildPad.Transparency = 1
        electronicsBuildPad.CanCollide = false
        electronicsBuildPrompt.Enabled = false
    end

    local function addGardenStore()
        if gardenStoreModel then
            return
        end
        gardenStorePurchased = true
        gardenStoreModel = Instance.new("Model")
        gardenStoreModel.Name = "Little Sprout Garden Plaza Business"
        gardenStoreModel.Parent = exterior
        local center = Vector3.new(-65, 0, -122)
        part(
            gardenStoreModel,
            "Garden Store Floor",
            Vector3.new(24, 0.35, 20),
            CFrame.new(center + Vector3.new(0, 0.05, 0)),
            COLORS.cream,
            Enum.Material.CeramicTiles
        )
        part(
            gardenStoreModel,
            "Garden Store Back Wall",
            Vector3.new(24, 9, 0.55),
            CFrame.new(center + Vector3.new(0, 4.5, -9.7)),
            COLORS.green
        )
        for _, side in ipairs({ -11.7, 11.7 }) do
            part(
                gardenStoreModel,
                "Garden Store Side Wall",
                Vector3.new(0.6, 9, 20),
                CFrame.new(center + Vector3.new(side, 4.5, 0)),
                COLORS.cream
            )
        end
        part(
            gardenStoreModel,
            "Garden Store Roof",
            Vector3.new(25, 0.8, 21),
            CFrame.new(center + Vector3.new(0, 9.4, 0)),
            COLORS.green,
            Enum.Material.Grass
        )
        part(
            gardenStoreModel,
            "Garden Store Awning",
            Vector3.new(18, 0.35, 2.3),
            CFrame.new(center + Vector3.new(0, 7.4, 10.8)),
            COLORS.coral,
            Enum.Material.Fabric
        )
        gardenMenuBoard.Parent = gardenStoreModel
        gardenMenuBoard.CFrame = CFrame.new(center + Vector3.new(0, 5.7, 10.05))
        gardenMenuBoard.Transparency = 0
        if gardenMenuSurface then
            gardenMenuSurface.Enabled = true
        end
        gardenCounter.Parent = gardenStoreModel
        gardenCounter.CFrame = CFrame.new(center + Vector3.new(0, 1.45, 5.4))
        gardenCounter.Transparency = 0
        gardenCounter.CanCollide = true
        for index = 1, 4 do
            local plant = part(
                gardenStoreModel,
                "Potted Herb Display",
                Vector3.new(1.2, 1.7, 1.2),
                CFrame.new(center + Vector3.new(-3.8 + index * 2.3, 1.2, -1.8)),
                COLORS.green,
                Enum.Material.Grass
            )
            plant.CanCollide = false
            plant.Transparency = 1
            table.insert(gardenItemVisuals, plant)
        end
        local gardener = createLowPolyPerson(
            gardenStoreModel,
            "Little Sprout Gardener",
            center + Vector3.new(3.5, 0.45, 2),
            COLORS.green,
            COLORS.wood,
            COLORS.deepTeal
        )
        for _, item in ipairs(gardener:GetDescendants()) do
            if item:IsA("BasePart") then
                item.CanCollide = false
            end
        end
        gardenBuildPad.Transparency = 1
        gardenBuildPad.CanCollide = false
        gardenBuildPrompt.Enabled = false
    end

    local function applyPlazaStyle(styleId)
        local selected = PLAZA_STYLES[styleId]
        local models = { cafeModel, restaurantModel, electronicsStoreModel, gardenStoreModel }
        for _, model in ipairs(models) do
            if model then
                local baseAwning = COLORS.coral
                local baseRoof = COLORS.teal
                local baseSign = COLORS.deepTeal
                if string.find(model.Name, "Pixel and Plug") then
                    baseAwning = COLORS.teal
                    baseRoof = COLORS.gray
                elseif string.find(model.Name, "Little Sprout") then
                    baseRoof = COLORS.green
                    baseSign = COLORS.green
                end
                for _, item in ipairs(model:GetDescendants()) do
                    if item:IsA("BasePart") then
                        if string.find(item.Name, "Awning") then
                            item.Color = selected and selected.awning or baseAwning
                        elseif string.find(item.Name, "Roof") then
                            item.Color = selected and selected.roof or baseRoof
                        elseif
                            string.find(item.Name, "Menu Board")
                            or string.find(item.Name, "Store Sign")
                        then
                            item.Color = selected and selected.awning or baseSign
                        end
                    end
                end
            end
        end
        for _, item in ipairs(exterior:GetChildren()) do
            if item:IsA("BasePart") and string.find(item.Name, "Walkway") then
                item.Color = selected and selected.path or COLORS.gray
            end
        end
        plazaStylePad.Color = selected and selected.awning or COLORS.green
        local surface = plazaStyleSign:FindFirstChildOfClass("SurfaceGui")
        local signText = surface and surface:FindFirstChildOfClass("TextLabel")
        if signText then
            signText.Text = if plazaStylePurchased
                then string.upper(selected and selected.name or "Plaza") .. "\nINSTALLED"
                elseif selected then string.upper(selected.name) .. "\nPREVIEW"
                else "PLAZA REFRESH\nPREVIEW / INSTALL $750"
        end
        plazaStylePrompt.Enabled = not plazaStylePurchased
            and gardenStorePurchased
            and currentStage == "Complete"
        plazaStylePreviewPrompt.Enabled = not plazaStylePurchased
            and gardenStorePurchased
            and currentStage == "Complete"
    end

    local function setPlazaStyle(purchased, styleId)
        plazaStylePurchased = purchased == true
        plazaStyleId = plazaStylePurchased and PLAZA_STYLES[styleId] and styleId or ""
        plazaStylePreviewId = nil
        applyPlazaStyle(plazaStylePurchased and plazaStyleId or nil)
    end

    local function setPlazaStylePreview(styleId)
        plazaStylePreviewId = PLAZA_STYLES[styleId] and styleId or nil
        applyPlazaStyle(plazaStylePurchased and plazaStyleId or plazaStylePreviewId)
    end

    local function getPlazaStyleName(styleId)
        local style = PLAZA_STYLES[styleId]
        return style and style.name or "Coastal Walk"
    end

    local plazaVisitEvent = Instance.new("BindableEvent")
    plazaVisitEvent.Name = "PlazaBusinessVisit"
    plazaVisitEvent.Parent = exterior
    local plazaVisitors = {}
    local visitorColors = {
        { COLORS.blue, COLORS.deepTeal, COLORS.orange },
        { COLORS.coral, COLORS.gray, COLORS.deepTeal },
        { COLORS.green, COLORS.blue, COLORS.gold },
        { COLORS.orange, COLORS.deepTeal, COLORS.cream },
    }
    for index = 1, 4 do
        local colors = visitorColors[index]
        local visitor = createLowPolyPerson(
            exterior,
            "Plaza Visitor " .. index,
            Vector3.new(-80, 0.45, 22),
            colors[1],
            colors[2],
            colors[3],
            true
        )
        local head = visitor:FindFirstChild("Head")
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "PlazaVisitorNameplate"
        billboard.Adornee = head
        billboard.Size = UDim2.fromOffset(170, 38)
        billboard.StudsOffset = Vector3.new(0, 1.25, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = false
        billboard.Parent = head
        local caption = Instance.new("TextLabel")
        caption.Size = UDim2.fromScale(1, 1)
        caption.BackgroundColor3 = COLORS.deepTeal
        caption.BackgroundTransparency = 0.08
        caption.Text = "PLAZA VISITOR"
        caption.TextColor3 = COLORS.warmWhite
        caption.Font = Enum.Font.GothamBold
        caption.TextScaled = true
        caption.Parent = billboard
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = caption
        for _, item in ipairs(visitor:GetDescendants()) do
            if item:IsA("BasePart") then
                item.Transparency = 1
            end
        end
        table.insert(plazaVisitors, { model = visitor, billboard = billboard, caption = caption })
    end

    local function movePlazaVisitor(entry, destination)
        local startPivot = entry.model:GetPivot()
        local startPosition = startPivot.Position
        local flatDestination = Vector3.new(destination.X, 0.45, destination.Z)
        local delta = flatDestination - startPosition
        local distance = delta.Magnitude
        if distance < 0.1 then
            return
        end
        local targetPivot = CFrame.lookAt(flatDestination, flatDestination + delta.Unit)
        local duration = distance / 6
        local startedAt = os.clock()
        while entry.model.Parent == exterior do
            local alpha = math.min((os.clock() - startedAt) / duration, 1)
            entry.model:PivotTo(startPivot:Lerp(targetPivot, alpha))
            if alpha >= 1 then
                return
            end
            task.wait(0.05)
        end
    end

    for index, entry in ipairs(plazaVisitors) do
        task.spawn(function()
            while exterior.Parent do
                local openBusinesses = {}
                if cafePurchased then
                    table.insert(
                        openBusinesses,
                        { id = "cafe", name = "CORNER CAFÉ", front = Vector3.new(-65, 0.45, 7) }
                    )
                end
                if restaurantPurchased then
                    table.insert(openBusinesses, {
                        id = "restaurant",
                        name = "MARKET TABLE",
                        front = Vector3.new(-65, 0.45, -32),
                    })
                end
                if electronicsStorePurchased then
                    table.insert(openBusinesses, {
                        id = "electronics",
                        name = "PIXEL & PLUG",
                        front = Vector3.new(-65, 0.45, -72),
                    })
                end
                if gardenStorePurchased then
                    table.insert(openBusinesses, {
                        id = "garden",
                        name = "LITTLE SPROUT",
                        front = Vector3.new(-65, 0.45, -112),
                    })
                end
                if floristStorePurchased then
                    table.insert(openBusinesses, {
                        id = "florist",
                        name = "MAPLE CORNER FLORIST",
                        front = Vector3.new(54, 0.45, -64.5),
                    })
                end
                if bookshopPurchased then
                    table.insert(openBusinesses, {
                        id = "bookshop",
                        name = "RIVERSIDE BOOKSHOP",
                        front = Vector3.new(79, 0.45, -64.5),
                    })
                end
                if #openBusinesses == 0 then
                    entry.billboard.Enabled = false
                    for _, item in ipairs(entry.model:GetDescendants()) do
                        if item:IsA("BasePart") then
                            item.Transparency = 1
                        end
                    end
                    task.wait(4)
                    continue
                end

                local target = openBusinesses[(index - 1) % #openBusinesses + 1]
                for _, item in ipairs(entry.model:GetDescendants()) do
                    if item:IsA("BasePart") then
                        item.Transparency = 0
                    end
                end
                entry.model:PivotTo(CFrame.new(-80, 0.45, 22))
                entry.caption.Text = "VISITING " .. target.name
                entry.billboard.Enabled = true
                movePlazaVisitor(entry, Vector3.new(-80, 0.45, target.front.Z + 6))
                movePlazaVisitor(entry, target.front)
                entry.caption.Text = "BROWSING " .. target.name
                plazaVisitEvent:Fire(target.id)
                task.wait(2.5)
                movePlazaVisitor(entry, Vector3.new(-80, 0.45, target.front.Z + 6))
                movePlazaVisitor(entry, Vector3.new(-80, 0.45, 22))
                entry.billboard.Enabled = false
                for _, item in ipairs(entry.model:GetDescendants()) do
                    if item:IsA("BasePart") then
                        item.Transparency = 1
                    end
                end
                task.wait(8 + index * 2)
            end
        end)
    end

    local function addWarehouse()
        if warehouseModel then
            return
        end
        warehousePurchased = true
        warehouseModel = Instance.new("Model")
        warehouseModel.Name = "Purchased Warehouse Annex"
        warehouseModel.Parent = exterior
        local center = Vector3.new(59, 0, -2)
        part(
            warehouseModel,
            "Warehouse Tile Floor",
            Vector3.new(18, 0.3, 13),
            CFrame.new(center + Vector3.new(0, 0.05, 0)),
            COLORS.cream,
            Enum.Material.CeramicTiles
        )
        for _, x in ipairs({ 50.8, 67.2 }) do
            local edge = part(
                warehouseModel,
                "Warehouse Build Zone Boundary",
                Vector3.new(0.08, 0.025, 12),
                CFrame.new(x, 0.215, -2),
                COLORS.gold,
                Enum.Material.Neon,
                0.35
            )
            edge.CanCollide = false
            edge.CanQuery = false
        end
        for _, z in ipairs({ -8, 4 }) do
            local edge = part(
                warehouseModel,
                "Warehouse Build Zone Boundary",
                Vector3.new(16.4, 0.025, 0.08),
                CFrame.new(59, 0.215, z),
                COLORS.gold,
                Enum.Material.Neon,
                0.35
            )
            edge.CanCollide = false
            edge.CanQuery = false
        end
        warehousePad.Transparency = 1
        warehousePad.CanCollide = false
        local backWall = part(
            warehouseModel,
            "Warehouse Back Wall",
            Vector3.new(20, 10, 0.8),
            CFrame.new(center + Vector3.new(0, 5, -7.6)),
            COLORS.gray,
            Enum.Material.Metal
        )
        backWall:SetAttribute("PlayerPurchased", true)
        part(
            warehouseModel,
            "Warehouse Left Wall",
            Vector3.new(0.8, 10, 15.2),
            CFrame.new(center + Vector3.new(-9.6, 5, 0)),
            COLORS.gray,
            Enum.Material.Metal
        )
        part(
            warehouseModel,
            "Warehouse Right Wall",
            Vector3.new(0.8, 10, 15.2),
            CFrame.new(center + Vector3.new(9.6, 5, 0)),
            COLORS.gray,
            Enum.Material.Metal
        )
        for _, x in ipairs({ -7, 7 }) do
            part(
                warehouseModel,
                "Warehouse Front Wall",
                Vector3.new(6, 10, 0.8),
                CFrame.new(center + Vector3.new(x, 5, 7.6)),
                COLORS.gray,
                Enum.Material.Metal
            )
        end
        part(
            warehouseModel,
            "Warehouse Door Header",
            Vector3.new(8, 2, 0.8),
            CFrame.new(center + Vector3.new(0, 9, 7.6)),
            COLORS.gray,
            Enum.Material.Metal
        )
        part(
            warehouseModel,
            "Warehouse Roof",
            Vector3.new(22, 0.8, 18),
            CFrame.new(center + Vector3.new(0, 10.3, 0)),
            COLORS.deepTeal,
            Enum.Material.Metal
        )
        local door = part(
            warehouseModel,
            "Warehouse Loading Door",
            Vector3.new(7.5, 6.8, 0.3),
            CFrame.new(center + Vector3.new(0, 3.4, 7.7)),
            COLORS.gold,
            Enum.Material.Metal,
            0.55
        )
        door.CanCollide = false
        part(
            warehouseModel,
            "Loading Dock",
            Vector3.new(12, 1, 5),
            CFrame.new(center + Vector3.new(0, 0.5, 11)),
            COLORS.wood,
            Enum.Material.Wood
        )
        orderBoard.Transparency = 0
        if deliverySurface then
            deliverySurface.Enabled = true
        end
        deliveryCrate.Parent = warehouseModel
        layoutAnchor.Parent = warehouseModel
        layoutAnchor.Transparency = 0
        layoutHeader.Parent = warehouseModel
        layoutHeader.Transparency = 0
        if layoutHeaderSurface then
            layoutHeaderSurface.Enabled = true
        end
        layoutFixtureFolder = Instance.new("Folder")
        layoutFixtureFolder.Name = "Custom Warehouse Fixtures"
        layoutFixtureFolder.Parent = warehouseModel
        onlineOrderBoard.Parent = warehouseModel
        onlineOrderBoard.CFrame = CFrame.new(center + Vector3.new(6.2, 3.2, -6.8))
        onlineOrderBoard.Transparency = 0
        if onlineOrderBoardSurface then
            onlineOrderBoardSurface.Enabled = true
        end
        warehousePrompt.Enabled = false
    end

    local function addDeliveryFleet()
        if deliveryFleetModel then
            return
        end
        deliveryFleetModel = Instance.new("Model")
        deliveryFleetModel.Name = "Regional Delivery Fleet"
        deliveryFleetModel.Parent = exterior
        for index, x in ipairs({ 52, 66 }) do
            local truck = Instance.new("Model")
            truck.Name = "Delivery Fleet Truck " .. index
            truck.Parent = deliveryFleetModel
            part(
                truck,
                "Delivery Truck Chassis",
                Vector3.new(3.5, 0.7, 6.5),
                CFrame.new(x, 1.1, 17),
                COLORS.deepTeal,
                Enum.Material.Metal
            )
            part(
                truck,
                "Delivery Truck Cargo Box",
                Vector3.new(3.5, 2.7, 4.1),
                CFrame.new(x, 2.8, 16.2),
                index == 1 and COLORS.teal or COLORS.green,
                Enum.Material.Metal
            )
            part(
                truck,
                "Delivery Truck Cab",
                Vector3.new(3.3, 2.4, 2.3),
                CFrame.new(x, 2.65, 20),
                COLORS.cream,
                Enum.Material.SmoothPlastic
            )
            for _, wheelX in ipairs({ x - 1.55, x + 1.55 }) do
                for _, wheelZ in ipairs({ 14.8, 19.1 }) do
                    local wheel = part(
                        truck,
                        "Delivery Truck Wheel",
                        Vector3.new(0.35, 1.05, 1.05),
                        CFrame.new(wheelX, 0.82, wheelZ) * CFrame.Angles(0, 0, math.pi / 2),
                        COLORS.ink,
                        Enum.Material.Rubber
                    )
                    wheel.Shape = Enum.PartType.Cylinder
                end
            end
            local fleetLabel = label(
                truck,
                "Delivery Fleet Door Mark",
                "REGIONAL\nDELIVERY",
                Vector3.new(2.1, 1, 0.12),
                CFrame.new(x, 2.6, 21.18),
                COLORS.gold,
                COLORS.deepTeal
            )
            fleetLabel.CanCollide = false
            for _, item in ipairs(truck:GetDescendants()) do
                if item:IsA("BasePart") then
                    item.CanCollide = false
                    item.Anchored = true
                end
            end
        end
        deliveryFleetPad.Transparency = 1
        deliveryFleetPad.CanCollide = false
        deliveryFleetPrompt.Enabled = false
    end

    local function addDistributionCenter()
        if distributionCenterModel then
            return
        end
        distributionCenterModel = Instance.new("Model")
        distributionCenterModel.Name = "Regional Distribution Center"
        distributionCenterModel.Parent = exterior
        local center = Vector3.new(81, 0, -11)
        part(
            distributionCenterModel,
            "Distribution Center Loading Apron",
            Vector3.new(18, 0.25, 8),
            CFrame.new(center + Vector3.new(0, 0.12, 4)),
            COLORS.gray,
            Enum.Material.Concrete
        )
        part(
            distributionCenterModel,
            "Distribution Center Floor",
            Vector3.new(18, 0.3, 16),
            CFrame.new(center + Vector3.new(0, 0.18, -7)),
            COLORS.cream,
            Enum.Material.Concrete
        )
        part(
            distributionCenterModel,
            "Distribution Center Back Wall",
            Vector3.new(18, 10, 0.65),
            CFrame.new(center + Vector3.new(0, 5, -15)),
            COLORS.deepTeal,
            Enum.Material.Brick
        )
        for _, x in ipairs({ -9, 9 }) do
            part(
                distributionCenterModel,
                "Distribution Center Side Wall",
                Vector3.new(0.65, 10, 16),
                CFrame.new(center + Vector3.new(x, 5, -7)),
                COLORS.teal,
                Enum.Material.Brick
            )
            for rackIndex = 1, 3 do
                local z = -13 + rackIndex * 4
                part(
                    distributionCenterModel,
                    "High-Bay Storage Rack",
                    Vector3.new(2.2, 7, 0.4),
                    CFrame.new(center + Vector3.new(x * 0.62, 3.7, z)),
                    COLORS.orange,
                    Enum.Material.Metal
                )
                for level = 1, 3 do
                    part(
                        distributionCenterModel,
                        "Pallet Stock",
                        Vector3.new(1.8, 0.75, 1.3),
                        CFrame.new(center + Vector3.new(x * 0.62, 1 + level * 1.8, z)),
                        ({ COLORS.green, COLORS.coral, COLORS.gold })[level],
                        Enum.Material.WoodPlanks
                    )
                end
            end
        end
        for _, x in ipairs({ -5, 0, 5 }) do
            part(
                distributionCenterModel,
                "Loading Bay Door",
                Vector3.new(4.2, 6.5, 0.22),
                CFrame.new(center + Vector3.new(x, 3.4, 1.05)),
                COLORS.blue,
                Enum.Material.Glass,
                0.48
            )
        end
        label(
            distributionCenterModel,
            "Distribution Center Sign",
            "REGIONAL DISTRIBUTION\nBACKSTOCK CAPACITY 1,000 / SKU",
            Vector3.new(14, 2.2, 0.3),
            CFrame.new(center + Vector3.new(0, 9.3, 1)),
            COLORS.deepTeal,
            COLORS.warmWhite
        )
        distributionCenterPad.Transparency = 1
        distributionCenterPad.CanCollide = false
        distributionCenterPrompt.Enabled = false
    end

    local function setDeliveryState(readyAt, quantity, productId)
        deliveryReadyAt = readyAt or 0
        deliveryQuantity = quantity or 0
        deliveryProductId = productId == "frozenMeals" and "frozenMeals"
            or (
                productId == "cinnamonTwists" and "cinnamonTwists"
                or (
                    productId == "sunriseCereal" and "sunriseCereal"
                    or (
                        productId == "goldenApples" and "goldenApples"
                        or (productId == "berryBites" and "berryBites" or "citrusPop")
                    )
                )
            )
        local productInfoById = {
            citrusPop = { name = "CITRUS POP", units = "CANS" },
            berryBites = { name = "BERRY BITES", units = "PACKS" },
            goldenApples = { name = "GOLDEN APPLES", units = "APPLES" },
            sunriseCereal = { name = "SUNRISE CEREAL", units = "BOXES" },
            cinnamonTwists = { name = "CINNAMON TWISTS", units = "PASTRIES" },
            frozenMeals = { name = "FREEZER MEALS", units = "MEALS" },
        }
        local productInfo = productInfoById[deliveryProductId]
        if not warehousePurchased or not deliveryBoardLabel then
            return
        end
        if deliveryQuantity > 0 and os.time() < deliveryReadyAt then
            deliveryBoardLabel.Text = productInfo.name .. " DELIVERY EN ROUTE\nARRIVES SHORTLY"
        elseif deliveryQuantity > 0 then
            deliveryBoardLabel.Text = string.format(
                "%s ARRIVED\n%d %s TO COLLECT",
                productInfo.name,
                deliveryQuantity,
                productInfo.units
            )
        else
            deliveryBoardLabel.Text =
                "CITRUS $60 • BERRY $45\nAPPLES/CEREAL $35/45\nPASTRY/MEALS $50/55"
        end
        if crateLabel then
            local shipmentTextLabel = crateSurface
                and crateSurface:FindFirstChildOfClass("TextLabel")
            if shipmentTextLabel then
                shipmentTextLabel.Text = string.format(
                    "%s\n%d %s",
                    productInfo.name,
                    deliveryQuantity,
                    productInfo.units
                )
            end
        end
        if deliveryCrate then
            for _, item in ipairs(deliveryCrate:GetDescendants()) do
                if item:IsA("BasePart") then
                    item.Transparency = deliveryQuantity > 0 and os.time() >= deliveryReadyAt and 0
                        or 1
                end
            end
        end
        if deliveryCrateSurface then
            deliveryCrateSurface.Enabled = deliveryQuantity > 0 and os.time() >= deliveryReadyAt
        end
        if deliveryPrompt then
            deliveryPrompt.ObjectText = productInfo.name .. " Shipment"
            deliveryPrompt.Enabled = deliveryQuantity > 0 and os.time() >= deliveryReadyAt
        end
        if orderDeliveryPrompt then
            orderDeliveryPrompt.Enabled = deliveryQuantity == 0
        end
        if berryDeliveryOrderPrompt then
            berryDeliveryOrderPrompt.Enabled = deliveryQuantity == 0
        end
        if appleDeliveryOrderPrompt then
            appleDeliveryOrderPrompt.Enabled = deliveryQuantity == 0
        end
        if cerealDeliveryOrderPrompt then
            cerealDeliveryOrderPrompt.Enabled = deliveryQuantity == 0
        end
        if cinnamonTwistDeliveryOrderPrompt then
            cinnamonTwistDeliveryOrderPrompt.Enabled = bakeryPurchased and deliveryQuantity == 0
        end
        if frozenMealDeliveryOrderPrompt then
            frozenMealDeliveryOrderPrompt.Enabled = freezerPurchased and deliveryQuantity == 0
        end
    end

    local function addBakeryDepartment()
        if bakeryPurchased then
            return
        end
        if not floorExpansionPurchased or not warehousePurchased then
            return
        end
        bakeryPurchased = true
        bakeryExpansionPad.Transparency = 1
        bakeryExpansionPad.CanCollide = false
        bakeryDepartmentPrompt.Enabled = false
        bakeryModel = Instance.new("Model")
        bakeryModel.Name = "Bakery Department"
        bakeryModel.Parent = interior
        part(
            bakeryModel,
            "Bakery Display Counter",
            Vector3.new(6.2, 1.4, 2.2),
            CFrame.new(16, 1.05, -29),
            COLORS.wood,
            Enum.Material.WoodPlanks
        )
        local oven = part(
            bakeryModel,
            "Bakery Oven",
            Vector3.new(3.6, 3.4, 2.4),
            CFrame.new(18.1, 2.2, -35),
            COLORS.gray,
            Enum.Material.Metal
        )
        part(
            bakeryModel,
            "Oven Window",
            Vector3.new(2.1, 1.45, 0.12),
            CFrame.new(18.1, 2.35, -33.76),
            COLORS.orange,
            Enum.Material.Neon
        )
        bakerySign = label(
            bakeryModel,
            "Bakery Department Sign",
            "BAKERY  •  FRESH DAILY",
            Vector3.new(7, 1.1, 0.3),
            CFrame.new(16, 5, -29),
            COLORS.coral,
            COLORS.warmWhite
        )
        bakerySign:SetAttribute("PlayerPurchased", true)
        oven:SetAttribute("PlayerPurchased", true)
        local displayAnchor = part(
            bakeryModel,
            "Pastry Display Anchor",
            Vector3.new(5.4, 0.25, 1.5),
            CFrame.new(16, 1.85, -29),
            COLORS.gold,
            Enum.Material.SmoothPlastic
        )
        displayAnchor:SetAttribute("PlayerPurchased", true)
        displayAnchor.CanCollide = false
        bakeryModel.PrimaryPart = displayAnchor
        bakeryModel:SetAttribute("RetailProductId", "cinnamonTwists")
        retailDepartmentShelves.cinnamonTwists = bakeryModel
        retailShelfPositions.cinnamonTwists = { x = 16, z = -29, rotation = 0 }
        retailShelfPivotHeights.cinnamonTwists = 1.85
        createPriceTag("cinnamonTwists", "Cinnamon Twists", bakeryModel, 16, -29)
        cinnamonTwistStockPrompt.Parent = displayAnchor
        cinnamonTwistStockPrompt.Enabled = false
        setCinnamonTwistStockVisual(0)
        updateCustomerBasketPositions()
    end

    local function addFreezerDepartment()
        if freezerPurchased then
            return
        end
        if not floorExpansionPurchased or not warehousePurchased or not bakeryPurchased then
            return
        end
        freezerPurchased = true
        freezerExpansionPad.Transparency = 1
        freezerExpansionPad.CanCollide = false
        freezerDepartmentPrompt.Enabled = false
        freezerModel = Instance.new("Model")
        freezerModel.Name = "Frozen Foods Department"
        freezerModel.Parent = interior
        part(
            freezerModel,
            "Freezer Case Base",
            Vector3.new(8.4, 1.15, 2.5),
            CFrame.new(6, 0.95, -29),
            COLORS.gray,
            Enum.Material.Metal
        )
        part(
            freezerModel,
            "Freezer Glass Top",
            Vector3.new(8.2, 0.18, 2.3),
            CFrame.new(6, 1.62, -29),
            COLORS.blue,
            Enum.Material.Glass,
            0.45
        )
        freezerSign = label(
            freezerModel,
            "Freezer Department Sign",
            "FROZEN FOODS  •  KEEP IT COOL",
            Vector3.new(8, 1.1, 0.3),
            CFrame.new(6, 5, -29),
            COLORS.blue,
            COLORS.deepTeal
        )
        freezerSign:SetAttribute("PlayerPurchased", true)
        freezerModel.PrimaryPart = freezerModel:FindFirstChild("Freezer Case Base")
        freezerModel:SetAttribute("RetailProductId", "frozenMeals")
        retailDepartmentShelves.frozenMeals = freezerModel
        retailShelfPositions.frozenMeals = { x = 6, z = -29, rotation = 0 }
        retailShelfPivotHeights.frozenMeals = 0.95
        createPriceTag("frozenMeals", "Freezer Meals", freezerModel, 6, -29)
        local displayAnchor = part(
            freezerModel,
            "Freezer Stock Anchor",
            Vector3.new(7.8, 0.2, 1.8),
            CFrame.new(6, 1.75, -29),
            COLORS.blue,
            Enum.Material.SmoothPlastic
        )
        displayAnchor.CanCollide = false
        displayAnchor:SetAttribute("PlayerPurchased", true)
        frozenMealStockPrompt.Parent = displayAnchor
        frozenMealStockPrompt.Enabled = false
        setFrozenMealStockVisual(0)
        updateCustomerBasketPositions()
    end

    local function setCinnamonTwistStockAvailable(available)
        cinnamonTwistStockAvailable = available == true
        if cinnamonTwistStockPrompt then
            cinnamonTwistStockPrompt.Enabled = cinnamonTwistStockAvailable
                and bakeryPurchased
                and currentStage ~= "Cart"
                and currentStage ~= "Upgrade"
                and currentStage ~= "Loading"
                and currentStage ~= "OwnerOffline"
                and currentStage ~= "PowerOutage"
                and currentStage ~= "Spill"
                and currentStage ~= "CloseShift"
                and currentStage ~= "Complete"
        end
    end

    local function setFrozenMealStockAvailable(available)
        frozenMealStockAvailable = available == true
        if frozenMealStockPrompt then
            frozenMealStockPrompt.Enabled = frozenMealStockAvailable
                and freezerPurchased
                and currentStage ~= "Cart"
                and currentStage ~= "Upgrade"
                and currentStage ~= "Loading"
                and currentStage ~= "OwnerOffline"
                and currentStage ~= "PowerOutage"
                and currentStage ~= "Spill"
                and currentStage ~= "CloseShift"
                and currentStage ~= "Complete"
        end
    end

    local function updatePlazaPrompts()
        cafeBuildPrompt.Enabled = currentStage == "Complete"
            and warehousePurchased
            and not cafePurchased
        cafeRestockPrompt.Enabled = cafePurchased
            and currentStage == "Complete"
            and cafeStock + 6 <= 24
        cafeServePrompt.Enabled = cafePurchased
            and cafeStock > 0
            and currentStage ~= "Loading"
            and currentStage ~= "OwnerOffline"
        restaurantBuildPrompt.Enabled = currentStage == "Complete"
            and cafePurchased
            and not restaurantPurchased
        restaurantRestockPrompt.Enabled = restaurantPurchased
            and currentStage == "Complete"
            and restaurantStock + 4 <= 16
        restaurantServePrompt.Enabled = restaurantPurchased
            and restaurantStock > 0
            and currentStage ~= "Loading"
            and currentStage ~= "OwnerOffline"
        electronicsBuildPrompt.Enabled = currentStage == "Complete"
            and restaurantPurchased
            and not electronicsStorePurchased
        electronicsRestockPrompt.Enabled = electronicsStorePurchased
            and currentStage == "Complete"
            and electronicsStock + 2 <= 8
        electronicsSalePrompt.Enabled = electronicsStorePurchased
            and electronicsStock > 0
            and currentStage ~= "Loading"
            and currentStage ~= "OwnerOffline"
        gardenBuildPrompt.Enabled = currentStage == "Complete"
            and electronicsStorePurchased
            and not gardenStorePurchased
        gardenRestockPrompt.Enabled = gardenStorePurchased
            and currentStage == "Complete"
            and gardenStock + 3 <= 12
        gardenSalePrompt.Enabled = gardenStorePurchased
            and gardenStock > 0
            and currentStage ~= "Loading"
            and currentStage ~= "OwnerOffline"
        floristBuildPrompt.Enabled = currentStage == "Complete"
            and gardenStorePurchased
            and not floristStorePurchased
        floristRestockPrompt.Enabled = floristStorePurchased
            and currentStage == "Complete"
            and floristStock + 4 <= 12
        floristSalePrompt.Enabled = floristStorePurchased
            and floristStock > 0
            and currentStage ~= "Loading"
            and currentStage ~= "OwnerOffline"
        bookshopBuildPrompt.Enabled = currentStage == "Complete"
            and floristStorePurchased
            and not bookshopPurchased
        bookshopRestockPrompt.Enabled = bookshopPurchased
            and currentStage == "Complete"
            and bookshopStock + Economy.BOOKSHOP_RESTOCK_QUANTITY
                <= Economy.BOOKSHOP_SHELF_CAPACITY
        bookshopSalePrompt.Enabled = bookshopPurchased
            and bookshopStock > 0
            and currentStage ~= "Loading"
            and currentStage ~= "OwnerOffline"
        plazaStylePrompt.Enabled = not plazaStylePurchased
            and gardenStorePurchased
            and currentStage == "Complete"
        plazaStylePreviewPrompt.Enabled = not plazaStylePurchased
            and gardenStorePurchased
            and currentStage == "Complete"
    end

    local function setStage(stage)
        local previousStage = currentStage
        currentStage = stage
        if
            (
                previousStage == "Spill"
                or previousStage == "PowerOutage"
                or previousStage == "OwnerOffline"
            )
            and (stage == "Checkout" or stage == "CustomerRush")
            and checkoutReady
        then
            checkoutReadyAt = os.clock()
        end
        local served = customerTotal - (remainingCustomers or 0)
        for index, entry in ipairs(customerModels) do
            local queueNumber = index - served
            if remainingCustomers and queueNumber > 0 and queueNumber <= remainingCustomers then
                entry.label.Text = customerQueueStatus(queueNumber)
            end
        end
        cartPrompt.Enabled = stage == "Cart"
        updateCitrusStockPrompt()
        berryStockPrompt.Enabled = berryStockAvailable
            and stage ~= "Cart"
            and stage ~= "Upgrade"
            and stage ~= "Loading"
            and stage ~= "OwnerOffline"
            and stage ~= "PowerOutage"
            and stage ~= "Spill"
            and stage ~= "CloseShift"
            and stage ~= "Complete"
        updateCheckoutPrompts()
        closePrompt.Enabled = stage == "CloseShift"
        spillPrompt.Enabled = stage == "Spill"
        powerPrompt.Enabled = stage == "PowerOutage"
        layoutPrompt.Enabled = warehousePurchased and stage == "Complete"
        if onlineOrderPrompt then
            onlineOrderPrompt.Enabled = warehousePurchased
                and stage == "Complete"
                and onlineOrderReady
        end
        retailLayoutPrompt.Enabled = stage == "Complete"
        upgradePrompt.Enabled = stage == "Upgrade"
        aisleExpansionPrompt.Enabled = stage == "Complete"
            and not aisleExpansionPurchased
            and interior:FindFirstChild("Purchased Shelf Bay") ~= nil
        aisleExpansionPad.Transparency = 0
        floorExpansionPrompt.Enabled = stage == "Complete"
            and aisleExpansionPurchased
            and not floorExpansionPurchased
        selfCheckoutBuildPrompt.Enabled = stage == "Complete"
            and floorExpansionPurchased
            and warehousePurchased
            and not selfCheckoutPurchased
        local floorSignSurface = floorExpansionSign:FindFirstChildOfClass("SurfaceGui")
        local floorSignText = floorSignSurface
            and floorSignSurface:FindFirstChildOfClass("TextLabel")
        if floorSignText then
            floorSignText.Text = selfCheckoutPurchased and "SELF CHECKOUT\nINSTALLED"
                or (selfCheckoutBuildPrompt.Enabled and "SELF CHECKOUT\n$300")
                or (
                    floorExpansionPurchased and "REAR MARKET WING\nBUILT"
                    or (floorExpansionPrompt.Enabled and "REAR MARKET WING\n$500")
                    or (aisleExpansionPurchased and "REAR MARKET WING\nNEXT" or "REAR WING\nLOCKED")
                )
        end
        local expansionPadVisible = not floorExpansionPurchased or selfCheckoutBuildPrompt.Enabled
        floorExpansionPad.Transparency = expansionPadVisible and 0 or 1
        floorExpansionPad.CanCollide = expansionPadVisible
        bakeryDepartmentPrompt.Enabled = stage == "Complete"
            and floorExpansionPurchased
            and warehousePurchased
            and not bakeryPurchased
        local bakeryPadVisible = floorExpansionPurchased
            and warehousePurchased
            and not bakeryPurchased
        bakeryExpansionPad.Transparency = bakeryPadVisible and 0 or 1
        bakeryExpansionPad.CanCollide = bakeryPadVisible
        freezerDepartmentPrompt.Enabled = stage == "Complete"
            and floorExpansionPurchased
            and warehousePurchased
            and bakeryPurchased
            and not freezerPurchased
        local freezerPadVisible = floorExpansionPurchased
            and warehousePurchased
            and bakeryPurchased
            and not freezerPurchased
        freezerExpansionPad.Transparency = freezerPadVisible and 0 or 1
        freezerExpansionPad.CanCollide = freezerPadVisible
        retailPlotBuild.prompt.Enabled = stage == "Complete"
            and floorExpansionPurchased
            and warehousePurchased
            and freezerPurchased
            and not retailPlotState.purchased
        retailPlotBuild.pad.Transparency = retailPlotBuild.prompt.Enabled and 0 or 1
        retailPlotBuild.pad.CanCollide = retailPlotBuild.prompt.Enabled
        local bakeryStockAllowed = cinnamonTwistStockAvailable
            and bakeryPurchased
            and stage ~= "Cart"
            and stage ~= "Upgrade"
            and stage ~= "Loading"
            and stage ~= "OwnerOffline"
            and stage ~= "PowerOutage"
            and stage ~= "Spill"
            and stage ~= "CloseShift"
            and stage ~= "Complete"
        if cinnamonTwistStockPrompt then
            cinnamonTwistStockPrompt.Enabled = bakeryStockAllowed
        end
        local freezerStockAllowed = frozenMealStockAvailable
            and freezerPurchased
            and stage ~= "Cart"
            and stage ~= "Upgrade"
            and stage ~= "Loading"
            and stage ~= "OwnerOffline"
            and stage ~= "PowerOutage"
            and stage ~= "Spill"
            and stage ~= "CloseShift"
            and stage ~= "Complete"
        if frozenMealStockPrompt then
            frozenMealStockPrompt.Enabled = freezerStockAllowed
        end
        local signSurface = upgradeSign:FindFirstChildOfClass("SurfaceGui")
        local signText = signSurface and signSurface:FindFirstChildOfClass("TextLabel")
        if signText then
            signText.Text = aisleExpansionPurchased and "HOUSEHOLD AISLE\nINSTALLED"
                or (aisleExpansionPrompt.Enabled and "HOUSEHOLD AISLE\n$220")
                or (stage == "Upgrade" and "ADD SHELF BAY\n$45" or "STORE UPGRADE")
        end
        stylePrompt.Enabled = stage == "Complete" and not marketStylePurchased
        if stage ~= "Complete" and marketStylePreviewId then
            setMarketStylePreview(nil)
        else
            stylePreviewPrompt.Enabled = stage == "Complete" and not marketStylePurchased
        end
        restartPrompt.Enabled = stage == "Complete"
        upgradeMarker.Enabled = stage == "Upgrade" or aisleExpansionPrompt.Enabled
        markerText.Text = aisleExpansionPrompt.Enabled and "AISLE  $220" or "UPGRADE  $45"
        cashierHirePrompt.Enabled = stage == "Complete" and not cashierHired
        stockerHirePrompt.Enabled = stage == "Complete" and not stockerHired
        cleanerHirePrompt.Enabled = stage == "Complete" and not cleanerHired
        deliveryWorkerHirePrompt.Enabled = stage == "Complete"
            and warehousePurchased
            and not deliveryWorkerHired
        deliveryFleetPrompt.Enabled = stage == "Complete"
            and warehousePurchased
            and deliveryWorkerHired
            and not deliveryFleetPurchased
        distributionCenterPrompt.Enabled = stage == "Complete"
            and deliveryFleetPurchased
            and not distributionCenterPurchased
        distributionCenterPad.Transparency = (
            deliveryFleetPurchased and not distributionCenterPurchased
        )
                and 0
            or 1
        supplierPartnershipPrompt.Enabled = stage == "Complete"
            and distributionCenterPurchased
            and not supplierPartnershipPurchased
        supplierPartnershipPad.Transparency = (
            distributionCenterPurchased and not supplierPartnershipPurchased
        )
                and 0
            or 1
        deliveryFleetPad.Transparency = (
            deliveryFleetPurchased
            or not warehousePurchased
            or not deliveryWorkerHired
        )
                and 1
            or 0
        customerAssistantHirePrompt.Enabled = stage == "Complete" and not customerAssistantHired
        cashierAutomationPrompt.Enabled = stage ~= "Loading"
            and stage ~= "OwnerOffline"
            and cashierHired
        stockerAutomationPrompt.Enabled = stage ~= "Loading"
            and stage ~= "OwnerOffline"
            and stockerHired
        cleanerAutomationPrompt.Enabled = stage ~= "Loading"
            and stage ~= "OwnerOffline"
            and cleanerHired
        deliveryWorkerAutomationPrompt.Enabled = stage ~= "Loading"
            and stage ~= "OwnerOffline"
            and deliveryWorkerHired
        warehousePrompt.Enabled = stage == "Complete" and not warehousePurchased
        goldenAppleStockPrompt.Enabled = goldenAppleStockAvailable
            and warehousePurchased
            and stage ~= "Cart"
            and stage ~= "Upgrade"
            and stage ~= "Loading"
            and stage ~= "OwnerOffline"
            and stage ~= "PowerOutage"
            and stage ~= "Spill"
            and stage ~= "CloseShift"
            and stage ~= "Complete"
        cerealStockPrompt.Enabled = cerealStockAvailable
            and warehousePurchased
            and stage ~= "Cart"
            and stage ~= "Upgrade"
            and stage ~= "Loading"
            and stage ~= "OwnerOffline"
            and stage ~= "PowerOutage"
            and stage ~= "Spill"
            and stage ~= "CloseShift"
            and stage ~= "Complete"
        if orderDeliveryPrompt then
            orderDeliveryPrompt.Enabled = warehousePurchased and deliveryQuantity == 0
        end
        if berryDeliveryOrderPrompt then
            berryDeliveryOrderPrompt.Enabled = warehousePurchased and deliveryQuantity == 0
        end
        if appleDeliveryOrderPrompt then
            appleDeliveryOrderPrompt.Enabled = warehousePurchased and deliveryQuantity == 0
        end
        if cerealDeliveryOrderPrompt then
            cerealDeliveryOrderPrompt.Enabled = warehousePurchased and deliveryQuantity == 0
        end
        if cinnamonTwistDeliveryOrderPrompt then
            cinnamonTwistDeliveryOrderPrompt.Enabled = warehousePurchased
                and bakeryPurchased
                and deliveryQuantity == 0
        end
        if deliveryPrompt then
            deliveryPrompt.Enabled = warehousePurchased
                and deliveryQuantity > 0
                and os.time() >= deliveryReadyAt
        end
        updatePlazaPrompts()
        updateLocationPrompts()
        setSpillVisible(stage == "Spill")
        setPowerOutage(stage == "PowerOutage")
    end

    world:PivotTo(origin)
    return {
        root = world,
        locationId = locationId,
        locationTravelPrompt = locationTravelPrompt,
        travelDestination = travelDestination,
        uptownPurchasePrompt = uptownPurchasePrompt,
        setUptownStorePurchased = function(purchased, unlocked)
            uptownStorePurchased = purchased == true
            uptownPurchaseUnlocked = unlocked == true
            updateLocationPrompts()
        end,
        cartPrompt = cartPrompt,
        cartModel = cart,
        cartTween = function()
            return cartTween
        end,
        setCartTween = function(value)
            cartTween = value
        end,
        stockPrompt = stockPrompt,
        setStockVisual = setStockVisual,
        setStockAvailable = function(available)
            citrusStockAvailable = available == true
            updateCitrusStockPrompt()
        end,
        berryStockPrompt = berryStockPrompt,
        setBerryStockVisual = setBerryStockVisual,
        goldenAppleStockPrompt = goldenAppleStockPrompt,
        setGoldenAppleStockVisual = setGoldenAppleStockVisual,
        cerealStockPrompt = cerealStockPrompt,
        setCerealStockVisual = setCerealStockVisual,
        cinnamonTwistStockPrompt = function()
            return cinnamonTwistStockPrompt
        end,
        setCinnamonTwistStockVisual = setCinnamonTwistStockVisual,
        setCinnamonTwistStockAvailable = setCinnamonTwistStockAvailable,
        bakeryDepartmentPrompt = bakeryDepartmentPrompt,
        addBakeryDepartment = addBakeryDepartment,
        freezerDepartmentPrompt = freezerDepartmentPrompt,
        addFreezerDepartment = addFreezerDepartment,
        frozenMealStockPrompt = function()
            return frozenMealStockPrompt
        end,
        setFrozenMealStockVisual = setFrozenMealStockVisual,
        setFrozenMealStockAvailable = setFrozenMealStockAvailable,
        pricePrompt = function(productId)
            return pricePrompts[productId]
        end,
        setProductPrice = function(productId, value)
            local tag = priceTags[productId]
            local changePrompt = pricePrompts[productId]
            if tag then
                local surface = tag:FindFirstChildOfClass("SurfaceGui")
                local textLabel = surface and surface:FindFirstChildOfClass("TextLabel")
                if textLabel then
                    textLabel.Text = string.format("$%d", value)
                end
            end
            if changePrompt then
                changePrompt.ActionText = string.format("Change Price ($%d)", value)
            end
        end,
        setCerealStockAvailable = function(available)
            cerealStockAvailable = available == true
            cerealStockPrompt.Enabled = cerealStockAvailable
                and warehousePurchased
                and currentStage ~= "Cart"
                and currentStage ~= "Upgrade"
                and currentStage ~= "Loading"
                and currentStage ~= "OwnerOffline"
                and currentStage ~= "PowerOutage"
                and currentStage ~= "Spill"
                and currentStage ~= "CloseShift"
                and currentStage ~= "Complete"
        end,
        setGoldenAppleStockAvailable = function(available)
            goldenAppleStockAvailable = available == true
            goldenAppleStockPrompt.Enabled = goldenAppleStockAvailable
                and warehousePurchased
                and currentStage ~= "Cart"
                and currentStage ~= "Upgrade"
                and currentStage ~= "Loading"
                and currentStage ~= "OwnerOffline"
                and currentStage ~= "PowerOutage"
                and currentStage ~= "Spill"
                and currentStage ~= "CloseShift"
                and currentStage ~= "Complete"
        end,
        setBerryStockAvailable = function(available)
            berryStockAvailable = available == true
            berryStockPrompt.Enabled = berryStockAvailable
                and warehousePurchased
                and currentStage ~= "Cart"
                and currentStage ~= "Upgrade"
                and currentStage ~= "Loading"
                and currentStage ~= "OwnerOffline"
                and currentStage ~= "PowerOutage"
                and currentStage ~= "Spill"
                and currentStage ~= "CloseShift"
                and currentStage ~= "Complete"
        end,
        cerealDeliveryPrompt = function()
            return cerealDeliveryOrderPrompt
        end,
        cinnamonTwistDeliveryPrompt = function()
            return cinnamonTwistDeliveryOrderPrompt
        end,
        frozenMealDeliveryPrompt = function()
            return frozenMealDeliveryOrderPrompt
        end,
        setCustomerProduct = function(displayName)
            customerProductName = displayName or "Citrus Pop"
            local productId = customerProductName == "Berry Bites" and "berryBites"
                or (
                    customerProductName == "Golden Apples" and "goldenApples"
                    or (
                        customerProductName == "Sunrise Cereal" and "sunriseCereal"
                        or (
                            customerProductName == "Cinnamon Twists" and "cinnamonTwists"
                            or "citrusPop"
                        )
                    )
                )
            customerProductPositions = { customerBrowsePosition(productId) }
        end,
        setCustomerBasket = function(displayName, preferenceName, items)
            customerBasketName = displayName or "Citrus Pop x1"
            customerPreferenceName = preferenceName or "Everyday"
            customerBasketItems = type(items) == "table" and items or {}
            updateCustomerBasketPositions()
        end,
        setCustomerVisible = setCustomerVisible,
        setCustomerCount = setCustomerCount,
        registerPrompt = register,
        selfCheckoutPrompt = selfCheckoutPrompt,
        selfCheckoutBuildPrompt = selfCheckoutBuildPrompt,
        setSelfCheckoutPurchased = function(purchased)
            selfCheckoutPurchased = purchased == true
            for _, item in ipairs(selfCheckoutModel:GetDescendants()) do
                if item:IsA("BasePart") then
                    item.Transparency = selfCheckoutPurchased and 0 or 1
                elseif item:IsA("SurfaceGui") then
                    item.Enabled = selfCheckoutPurchased
                end
            end
            updateCheckoutPrompts()
        end,
        isCheckoutReady = function()
            return checkoutReady
        end,
        getCheckoutWaitSeconds = function()
            if
                not checkoutReady
                or checkoutReadyAt <= 0
                or (currentStage ~= "Checkout" and currentStage ~= "CustomerRush")
            then
                return 0
            end
            return math.max(0, math.floor(os.clock() - checkoutReadyAt))
        end,
        recoverCustomerQueue = recoverCustomerQueue,
        spillPrompt = spillPrompt,
        powerPrompt = powerPrompt,
        setSpillVisible = setSpillVisible,
        closePrompt = closePrompt,
        restartPrompt = restartPrompt,
        cashierHirePrompt = cashierHirePrompt,
        stockerHirePrompt = stockerHirePrompt,
        cashierAutomationPrompt = cashierAutomationPrompt,
        stockerAutomationPrompt = stockerAutomationPrompt,
        cleanerAutomationPrompt = cleanerAutomationPrompt,
        deliveryWorkerHirePrompt = deliveryWorkerHirePrompt,
        customerAssistantHirePrompt = customerAssistantHirePrompt,
        setCustomerAssistantHired = function(hired)
            customerAssistantHired = hired == true
            customerAssistantHirePrompt.Enabled = currentStage == "Complete"
                and not customerAssistantHired
            for _, item in ipairs(customerAssistantModel:GetDescendants()) do
                if item:IsA("BasePart") then
                    item.Transparency = customerAssistantHired and 0 or 1
                end
            end
        end,
        deliveryWorkerAutomationPrompt = deliveryWorkerAutomationPrompt,
        warehousePrompt = warehousePrompt,
        layoutPrompt = layoutPrompt,
        retailLayoutPrompt = retailLayoutPrompt,
        layoutAnchor = layoutAnchor,
        setStorageLayout = function(layout)
            if not warehousePurchased or not layoutFixtureFolder then
                return
            end
            layoutFixtureFolder:ClearAllChildren()
            for _, item in ipairs(layout.items) do
                local placedShelfModel = createShelf(
                    layoutFixtureFolder,
                    "Placed Warehouse Shelf",
                    item.x,
                    item.z,
                    6,
                    "STORAGE",
                    item.rotation
                )
                placedShelfModel:SetAttribute("LayoutId", item.id)
                placedShelfModel:SetAttribute("PlayerPurchased", true)
            end
        end,
        setRetailLayout = function(layout, stockCounts)
            if type(layout) ~= "table" or type(layout.shelves) ~= "table" then
                return
            end
            local checkout = layout.checkout
            if type(checkout) == "table" then
                refreshCheckoutPositions(checkout.x, checkout.z, checkout.rotation, true)
            end
            local allPositions = {}
            for productId, shelfPosition in pairs(layout.shelves) do
                allPositions[productId] = shelfPosition
            end
            for productId, shelfPosition in pairs(layout.departments or {}) do
                allPositions[productId] = shelfPosition
            end
            for productId, shelfPosition in pairs(allPositions) do
                local model = retailDepartmentShelves[productId]
                if model and type(shelfPosition) == "table" then
                    local x = shelfPosition.x
                    local z = shelfPosition.z
                    local rotation = shelfPosition.rotation
                    if
                        type(x) == "number"
                        and type(z) == "number"
                        and (rotation == 0 or rotation == 90)
                    then
                        local pivotHeight = retailShelfPivotHeights[productId] or 1.2
                        model:PivotTo(
                            CFrame.new(x, pivotHeight, z) * CFrame.Angles(0, math.rad(rotation), 0)
                        )
                        retailShelfPositions[productId] = { x = x, z = z, rotation = rotation }
                    end
                end
            end
            for fixtureId, fixturePosition in pairs(layout.fixtures or {}) do
                local model = retailBuildFixtures[fixtureId]
                if model and type(fixturePosition) == "table" then
                    local x = fixturePosition.x
                    local z = fixturePosition.z
                    local rotation = fixturePosition.rotation
                    if
                        type(x) == "number"
                        and type(z) == "number"
                        and (rotation == 0 or rotation == 90)
                    then
                        local pivotHeight = retailFixturePivotHeights[fixtureId] or 1.2
                        model:PivotTo(
                            CFrame.new(x, pivotHeight, z) * CFrame.Angles(0, math.rad(rotation), 0)
                        )
                    end
                end
            end
            retailConstructionFolder:ClearAllChildren()
            local constructedAisles = {}
            local aisleIdsByProduct = {}
            constructedAisleBrowsePositions = {}
            local colorByProduct = {
                citrusPop = COLORS.coral,
                berryBites = COLORS.orange,
                goldenApples = COLORS.gold,
                sunriseCereal = COLORS.green,
                cinnamonTwists = COLORS.paleGreen,
                frozenMeals = COLORS.blue,
            }
            for aisleId, placement in pairs(layout.aisles or {}) do
                local productId = placement.productId or "citrusPop"
                local product = Economy.PRODUCTS[productId]
                local aisle = createShelf(
                    retailConstructionFolder,
                    product.displayName .. " Merchandising Aisle",
                    placement.x,
                    placement.z,
                    8,
                    string.upper(product.displayName),
                    placement.rotation
                )
                aisle:SetAttribute("ConstructedRetailAisleId", aisleId)
                aisle:SetAttribute("RetailProductId", productId)
                aisle:SetAttribute("PlayerPurchased", true)
                tagRetailShelfPalette(aisle)
                for _, item in ipairs(aisle:GetDescendants()) do
                    if item:GetAttribute("ProductDisplay") == true then
                        item.Transparency = 1
                    end
                end
                aisle:SetAttribute("MerchandisingName", product.displayName)
                constructedAisles[aisleId] = { model = aisle, placement = placement }
                aisleIdsByProduct[productId] = aisleIdsByProduct[productId] or {}
                table.insert(aisleIdsByProduct[productId], aisleId)
            end
            local stockVisualSetters = {
                citrusPop = setStockVisual,
                berryBites = setBerryStockVisual,
                goldenApples = setGoldenAppleStockVisual,
                sunriseCereal = setCerealStockVisual,
                cinnamonTwists = setCinnamonTwistStockVisual,
                frozenMeals = setFrozenMealStockVisual,
            }
            for productId, aisleIds in pairs(aisleIdsByProduct) do
                table.sort(aisleIds)
                local product = Economy.PRODUCTS[productId]
                local totalStock = math.max(0, math.floor((stockCounts or {})[productId] or 0))
                local faceCount = #aisleIds + 1
                local perFace = math.floor(totalStock / faceCount)
                local remainder = totalStock % faceCount
                local primaryCount = perFace + (remainder > 0 and 1 or 0)
                stockVisualSetters[productId](primaryCount)
                local packageColor = colorByProduct[productId]
                constructedAisleBrowsePositions[productId] = {}
                for index, aisleId in ipairs(aisleIds) do
                    local aisleCount = perFace + (index < remainder and 1 or 0)
                    local aisleRecord = constructedAisles[aisleId]
                    local aisleModel = aisleRecord.model
                    table.insert(constructedAisleBrowsePositions[productId], {
                        x = aisleRecord.placement.x,
                        z = aisleRecord.placement.z,
                        rotation = aisleRecord.placement.rotation,
                        stock = aisleCount,
                    })
                    for itemIndex = 1, aisleCount do
                        local column = (itemIndex - 1) % 8
                        local row = math.floor((itemIndex - 1) / 8)
                        local localFrame =
                            CFrame.new(-3.1 + column * 0.88, 3.35 + row * 1.35, -0.82)
                        local package = part(
                            aisleModel,
                            product.displayName .. " Stock Display",
                            Vector3.new(0.66, 0.82, 0.46),
                            aisleModel:GetPivot() * localFrame,
                            packageColor,
                            Enum.Material.SmoothPlastic
                        )
                        package:SetAttribute("ProductDisplay", true)
                        local faceLabel = part(
                            aisleModel,
                            product.displayName .. " Package Label",
                            Vector3.new(0.42, 0.24, 0.025),
                            aisleModel:GetPivot()
                                * CFrame.new(-3.1 + column * 0.88, 3.35 + row * 1.35, -0.57),
                            COLORS.warmWhite,
                            Enum.Material.SmoothPlastic
                        )
                        faceLabel:SetAttribute("ProductDisplay", true)
                    end
                end
            end
            updateCustomerBasketPositions()
            applyMarketStyle(marketStylePurchased and marketStyleId or marketStylePreviewId)
        end,
        marketStylePrompt = stylePrompt,
        marketStylePreviewPrompt = stylePreviewPrompt,
        setMarketStyle = setMarketStyle,
        setMarketStylePreview = setMarketStylePreview,
        getMarketStyleName = getMarketStyleName,
        plazaStylePrompt = plazaStylePrompt,
        plazaStylePreviewPrompt = plazaStylePreviewPrompt,
        setPlazaStyle = setPlazaStyle,
        setPlazaStylePreview = setPlazaStylePreview,
        getPlazaStyleName = getPlazaStyleName,
        cafeBuildPrompt = cafeBuildPrompt,
        cafeRestockPrompt = cafeRestockPrompt,
        cafeServePrompt = cafeServePrompt,
        setCafeState = function(purchased, stock, sales)
            cafePurchased = purchased == true
            cafeStock = math.max(0, math.min(math.floor(stock or 0), 24))
            cafeSales = math.max(0, math.floor(sales or 0))
            if cafePurchased then
                addCafe()
            end
            for index, cup in ipairs(cafeCupVisuals) do
                cup.Transparency = cafeStock >= index * 4 - 3 and 0 or 1
            end
            if cafeMenuLabel then
                cafeMenuLabel.Text = string.format(
                    "CORNER CAFÉ\nCOFFEE $%d\nSTOCK %d  •  SALES %d",
                    Economy.CAFE_COFFEE_PRICE,
                    cafeStock,
                    cafeSales
                )
            end
            updatePlazaPrompts()
        end,
        restaurantBuildPrompt = restaurantBuildPrompt,
        restaurantRestockPrompt = restaurantRestockPrompt,
        restaurantServePrompt = restaurantServePrompt,
        setRestaurantState = function(purchased, stock, sales)
            restaurantPurchased = purchased == true
            restaurantStock = math.max(0, math.min(math.floor(stock or 0), 16))
            restaurantSales = math.max(0, math.floor(sales or 0))
            if restaurantPurchased then
                addRestaurant()
            end
            for index, meal in ipairs(restaurantMealVisuals) do
                meal.Transparency = restaurantStock >= index * 4 - 3 and 0 or 1
            end
            if restaurantMenuLabel then
                restaurantMenuLabel.Text = string.format(
                    "MARKET TABLE\nGARDEN BOWL $%d\nSTOCK %d  •  SALES %d",
                    Economy.RESTAURANT_MEAL_PRICE,
                    restaurantStock,
                    restaurantSales
                )
            end
            updatePlazaPrompts()
        end,
        electronicsBuildPrompt = electronicsBuildPrompt,
        electronicsRestockPrompt = electronicsRestockPrompt,
        electronicsSalePrompt = electronicsSalePrompt,
        setElectronicsStoreState = function(purchased, stock, sales)
            electronicsStorePurchased = purchased == true
            electronicsStock = math.max(0, math.min(math.floor(stock or 0), 8))
            electronicsSales = math.max(0, math.floor(sales or 0))
            if electronicsStorePurchased then
                addElectronicsStore()
            end
            for index, item in ipairs(electronicsItemVisuals) do
                item.Transparency = electronicsStock >= index * 2 - 1 and 0 or 1
            end
            if electronicsMenuLabel then
                electronicsMenuLabel.Text = string.format(
                    "PIXEL & PLUG\nWIRELESS HEADPHONES $%d\nSTOCK %d  •  SALES %d",
                    Economy.ELECTRONICS_ITEM_PRICE,
                    electronicsStock,
                    electronicsSales
                )
            end
            updatePlazaPrompts()
        end,
        gardenBuildPrompt = gardenBuildPrompt,
        gardenRestockPrompt = gardenRestockPrompt,
        gardenSalePrompt = gardenSalePrompt,
        setGardenStoreState = function(purchased, stock, sales)
            gardenStorePurchased = purchased == true
            gardenStock = math.max(0, math.min(math.floor(stock or 0), 12))
            gardenSales = math.max(0, math.floor(sales or 0))
            if gardenStorePurchased then
                addGardenStore()
            end
            for index, plant in ipairs(gardenItemVisuals) do
                plant.Transparency = gardenStock >= index * 3 - 2 and 0 or 1
            end
            if gardenMenuLabel then
                gardenMenuLabel.Text = string.format(
                    "LITTLE SPROUT GARDEN\nPOTTED HERBS $%d\nSTOCK %d  •  SALES %d",
                    Economy.GARDEN_ITEM_PRICE,
                    gardenStock,
                    gardenSales
                )
            end
            updatePlazaPrompts()
        end,
        floristBuildPrompt = floristBuildPrompt,
        floristRestockPrompt = floristRestockPrompt,
        floristSalePrompt = floristSalePrompt,
        setFloristState = function(purchased, stock, sales)
            floristStorePurchased = purchased == true
            floristStock =
                math.max(0, math.min(math.floor(stock or 0), Economy.FLORIST_SHELF_CAPACITY))
            floristSales = math.max(0, math.floor(sales or 0))
            for index, bouquet in ipairs(floristItemVisuals) do
                bouquet.Transparency = floristStock >= index and 0 or 1
            end
            if floristMenuLabel then
                floristMenuLabel.Text = string.format(
                    "MAPLE CORNER FLORIST\nFRESH BOUQUETS $%d\nSTOCK %d  •  SALES %d",
                    Economy.FLORIST_BOUQUET_PRICE,
                    floristStock,
                    floristSales
                )
            end
            floristBuildPad.Transparency = floristStorePurchased and 1 or 0
            updatePlazaPrompts()
        end,
        bookshopBuildPrompt = bookshopBuildPrompt,
        bookshopRestockPrompt = bookshopRestockPrompt,
        bookshopSalePrompt = bookshopSalePrompt,
        setBookshopState = function(purchased, stock, sales)
            bookshopPurchased = purchased == true
            bookshopStock =
                math.max(0, math.min(math.floor(stock or 0), Economy.BOOKSHOP_SHELF_CAPACITY))
            bookshopSales = math.max(0, math.floor(sales or 0))
            for index, paperback in ipairs(bookshopItemVisuals) do
                paperback.Transparency = bookshopStock >= index and 0 or 1
            end
            if bookshopMenuLabel then
                bookshopMenuLabel.Text = string.format(
                    "RIVERSIDE BOOKSHOP\nPAPERBACKS $%d\nSTOCK %d  •  SALES %d",
                    Economy.BOOKSHOP_BOOK_PRICE,
                    bookshopStock,
                    bookshopSales
                )
            end
            bookshopBuildPad.Transparency = bookshopPurchased and 1 or 0
            updatePlazaPrompts()
        end,
        plazaVisitEvent = plazaVisitEvent,
        orderDeliveryPrompt = function()
            return orderDeliveryPrompt
        end,
        berryDeliveryPrompt = function()
            return berryDeliveryOrderPrompt
        end,
        appleDeliveryPrompt = function()
            return appleDeliveryOrderPrompt
        end,
        deliveryPrompt = function()
            return deliveryPrompt
        end,
        setDeliveryState = setDeliveryState,
        upgradePrompt = upgradePrompt,
        aisleExpansionPrompt = aisleExpansionPrompt,
        floorExpansionPrompt = floorExpansionPrompt,
        retailPlotPrompt = retailPlotBuild.prompt,
        setStage = setStage,
        setUpgradeReady = function(ready)
            upgradeMarker.Enabled = ready
        end,
        addUpgrade = function()
            if interior:FindFirstChild("Purchased Shelf Bay") then
                return
            end
            local newShelf = createShelf(interior, "Purchased Shelf Bay", -16, -8, 6)
            tagRetailShelfPalette(newShelf)
            newShelf:SetAttribute("PlayerPurchased", true)
            newShelf:SetAttribute("RetailFixtureId", "shelfBay")
            retailBuildFixtures.shelfBay = newShelf
            retailFixturePivotHeights.shelfBay = 1.2
            local sign = label(
                newShelf,
                "New Department Sign",
                "MORE TO CHOOSE",
                Vector3.new(8, 1.2, 0.35),
                CFrame.new(-16, 7.8, -5.2),
                COLORS.green
            )
            sign:SetAttribute("PlayerPurchased", true)
            sign:SetAttribute("MarketPaletteRole", "DepartmentSign")
            applyMarketStyle(marketStylePurchased and marketStyleId or marketStylePreviewId)
        end,
        addAisleExpansion = function()
            if aisleExpansionPurchased then
                return
            end
            -- A fixed, allow-listed bay inside the current floor footprint; no client placement data is used.
            local aisleExpansionModel =
                createShelf(interior, "Purchased Household Aisle", 16, -8, 6, "HOUSEHOLD")
            tagRetailShelfPalette(aisleExpansionModel)
            aisleExpansionModel:SetAttribute("PlayerPurchased", true)
            aisleExpansionModel:SetAttribute("RetailFixtureId", "householdAisle")
            retailBuildFixtures.householdAisle = aisleExpansionModel
            retailFixturePivotHeights.householdAisle = 1.2
            local sign = label(
                aisleExpansionModel,
                "Household Aisle Department Sign",
                "HOME & EVERYDAY",
                Vector3.new(7, 1.1, 0.3),
                CFrame.new(16, 7.35, -9.18),
                COLORS.green,
                COLORS.warmWhite
            )
            sign:SetAttribute("PlayerPurchased", true)
            sign:SetAttribute("MarketPaletteRole", "DepartmentSign")
            aisleExpansionPurchased = true
            aisleExpansionPrompt.Enabled = false
            aisleExpansionPad.Transparency = 0
            applyMarketStyle(marketStylePurchased and marketStyleId or marketStylePreviewId)
        end,
        addFloorExpansion = function()
            if floorExpansionModel then
                floorExpansionPurchased = true
                return
            end
            floorExpansionPurchased = true
            if mainBackWall and mainBackWall.Parent then
                mainBackWall:Destroy()
            end
            if mainBackWainscot and mainBackWainscot.Parent then
                mainBackWainscot:Destroy()
            end
            if neighborhoodMarketMural and neighborhoodMarketMural.Parent then
                neighborhoodMarketMural:Destroy()
            end
            floorExpansionModel = Instance.new("Model")
            floorExpansionModel.Name = "Purchased Rear Department Wing"
            floorExpansionModel.Parent = interior
            local function wingPart(name, size, cframe, color, material)
                local item = part(floorExpansionModel, name, size, cframe, color, material)
                item:SetAttribute("PlayerPurchased", true)
                if name == "Rear Department Floor" then
                    item:SetAttribute("MarketPaletteRole", "Floor")
                elseif string.find(name, "Wall") or string.find(name, "Pier") then
                    item:SetAttribute("MarketPaletteRole", "Wall")
                end
                return item
            end
            -- Rebuild the former rear wall with a wide, walkable opening into the new wing.
            wingPart(
                "Rear Opening Left Pier",
                Vector3.new(15, 12, 1),
                CFrame.new(-14.5, 6, -19),
                COLORS.cream
            )
            wingPart(
                "Rear Opening Right Pier",
                Vector3.new(15, 12, 1),
                CFrame.new(14.5, 6, -19),
                COLORS.cream
            )
            wingPart(
                "Rear Opening Header",
                Vector3.new(14, 3, 1),
                CFrame.new(0, 10.5, -19),
                COLORS.cream
            )
            wingPart(
                "Rear Department Floor",
                Vector3.new(44, 0.45, 21),
                CFrame.new(0, 0.24, -29.5),
                COLORS.cream,
                Enum.Material.CeramicTiles
            )
            wingPart(
                "Rear Department Left Wall",
                Vector3.new(1, 12, 22),
                CFrame.new(-22, 6, -30),
                COLORS.cream
            )
            wingPart(
                "Rear Department Right Wall",
                Vector3.new(1, 12, 22),
                CFrame.new(22, 6, -30),
                COLORS.cream
            )
            wingPart(
                "Rear Department Back Wall",
                Vector3.new(44, 12, 1),
                CFrame.new(0, 6, -41),
                COLORS.cream
            )
            local rearCeiling = wingPart(
                "Rear Department Ceiling",
                Vector3.new(44, 0.6, 22),
                CFrame.new(0, 12.1, -30),
                COLORS.warmWhite
            )
            rearCeiling.CanQuery = false
            for _, lightX in ipairs({ -14, -7, 0, 7, 14 }) do
                local ceilingLight = wingPart(
                    "Rear Department Light",
                    Vector3.new(3, 0.12, 0.7),
                    CFrame.new(lightX, 11.72, -24 - ((lightX / 7) % 2) * 7),
                    COLORS.warmWhite,
                    Enum.Material.Neon
                )
                ceilingLight.CanCollide = false
                ceilingLight.CanQuery = false
            end
            local departmentSign = label(
                floorExpansionModel,
                "Rear Wing Department Sign",
                "FRESH MARKET  •  MORE ROOM TO GROW",
                Vector3.new(12, 1.3, 0.35),
                CFrame.new(0, 8.2, -19.55),
                COLORS.green,
                COLORS.warmWhite
            )
            departmentSign:SetAttribute("PlayerPurchased", true)
            floorExpansionPad.Transparency = 1
            floorExpansionPad.CanCollide = false
            floorExpansionPrompt.Enabled = false
            applyMarketStyle(marketStylePurchased and marketStyleId or marketStylePreviewId)
        end,
        addRetailPlot = function()
            if retailPlotState.model then
                retailPlotState.purchased = true
                retailPlotBuild.prompt.Enabled = false
                retailPlotBuild.pad.Transparency = 1
                retailPlotBuild.pad.CanCollide = false
                return
            end
            retailPlotState.purchased = true
            retailPlotBuild.prompt.Enabled = false
            retailPlotBuild.pad.Transparency = 1
            retailPlotBuild.pad.CanCollide = false
            if floorExpansionModel then
                local oldBackWall = floorExpansionModel:FindFirstChild("Rear Department Back Wall")
                if oldBackWall then
                    oldBackWall:Destroy()
                end
            end
            retailPlotState.model = Instance.new("Model")
            retailPlotState.model.Name = "Purchased Retail Expansion Plot"
            retailPlotState.model.Parent = interior
            local function plotPart(name, size, cframe, color, material)
                local item = part(retailPlotState.model, name, size, cframe, color, material)
                item:SetAttribute("PlayerPurchased", true)
                item:SetAttribute(
                    "MarketPaletteRole",
                    name == "Retail Plot Floor" and "Floor" or "Wall"
                )
                return item
            end
            plotPart(
                "Retail Plot Opening Left Pier",
                Vector3.new(15, 12, 1),
                CFrame.new(-14.5, 6, -41),
                COLORS.cream
            )
            plotPart(
                "Retail Plot Opening Right Pier",
                Vector3.new(15, 12, 1),
                CFrame.new(14.5, 6, -41),
                COLORS.cream
            )
            plotPart(
                "Retail Plot Opening Header",
                Vector3.new(14, 3, 1),
                CFrame.new(0, 10.5, -41),
                COLORS.cream
            )
            plotPart(
                "Retail Plot Floor",
                Vector3.new(44, 0.45, 22),
                CFrame.new(0, 0.24, -52.5),
                COLORS.cream,
                Enum.Material.CeramicTiles
            )
            plotPart(
                "Retail Plot Left Wall",
                Vector3.new(1, 12, 23),
                CFrame.new(-22, 6, -52.5),
                COLORS.cream
            )
            plotPart(
                "Retail Plot Right Wall",
                Vector3.new(1, 12, 23),
                CFrame.new(22, 6, -52.5),
                COLORS.cream
            )
            plotPart(
                "Retail Plot Back Wall",
                Vector3.new(44, 12, 1),
                CFrame.new(0, 6, -64),
                COLORS.cream
            )
            local ceiling = plotPart(
                "Retail Plot Ceiling",
                Vector3.new(44, 0.6, 23),
                CFrame.new(0, 12.1, -52.5),
                COLORS.warmWhite
            )
            ceiling.CanQuery = false
            for _, lightX in ipairs({ -14, -7, 0, 7, 14 }) do
                local light = plotPart(
                    "Retail Plot Ceiling Light",
                    Vector3.new(3, 0.12, 0.7),
                    CFrame.new(lightX, 11.72, -48 - ((lightX / 7) % 2) * 7),
                    COLORS.warmWhite,
                    Enum.Material.Neon
                )
                light.CanCollide = false
                light.CanQuery = false
            end
            local sign = label(
                retailPlotState.model,
                "Retail Plot Department Sign",
                "GROCERY AISLES  •  EXPANSION",
                Vector3.new(12, 1.3, 0.35),
                CFrame.new(0, 8.2, -41.55),
                COLORS.green,
                COLORS.warmWhite
            )
            sign:SetAttribute("PlayerPurchased", true)
            applyMarketStyle(marketStylePurchased and marketStyleId or marketStylePreviewId)
        end,
        setCashierHired = function(hired)
            cashierHired = hired == true
            cashierHirePrompt.Enabled = not cashierHired and currentStage == "Complete"
            for _, item in ipairs(cashierModel:GetDescendants()) do
                if item:IsA("BasePart") then
                    item.Transparency = cashierHired and 0 or 1
                end
            end
        end,
        setCashierAutomationEnabled = function(enabled)
            cashierAutomationPrompt.ActionText = enabled and "Pause Automation"
                or "Resume Automation"
        end,
        setStockerHired = function(hired)
            stockerHired = hired == true
            stockerHirePrompt.Enabled = not stockerHired and currentStage == "Complete"
            for _, item in ipairs(stockerModel:GetDescendants()) do
                if item:IsA("BasePart") then
                    item.Transparency = stockerHired and 0 or 1
                end
            end
        end,
        setStockerAutomationEnabled = function(enabled)
            stockerAutomationPrompt.ActionText = enabled and "Pause Automation"
                or "Resume Automation"
        end,
        cleanerHirePrompt = cleanerHirePrompt,
        setCleanerHired = function(hired)
            cleanerHired = hired == true
            cleanerHirePrompt.Enabled = not cleanerHired and currentStage == "Complete"
            for _, item in ipairs(cleanerModel:GetDescendants()) do
                if item:IsA("BasePart") then
                    item.Transparency = cleanerHired and 0 or 1
                end
            end
        end,
        setCleanerAutomationEnabled = function(enabled)
            cleanerAutomationPrompt.ActionText = enabled and "Pause Automation"
                or "Resume Automation"
        end,
        setDeliveryWorkerHired = function(hired)
            deliveryWorkerHired = hired == true
            deliveryWorkerHirePrompt.Enabled = currentStage == "Complete"
                and warehousePurchased
                and not deliveryWorkerHired
            deliveryFleetPrompt.Enabled = currentStage == "Complete"
                and warehousePurchased
                and deliveryWorkerHired
                and not deliveryFleetPurchased
            deliveryFleetPad.Transparency = (
                deliveryFleetPurchased
                or not warehousePurchased
                or not deliveryWorkerHired
            )
                    and 1
                or 0
            for _, item in ipairs(deliveryWorkerModel:GetDescendants()) do
                if item:IsA("BasePart") then
                    item.Transparency = deliveryWorkerHired and 0 or 1
                end
            end
        end,
        setDeliveryWorkerAutomationEnabled = function(enabled)
            deliveryWorkerAutomationPrompt.ActionText = enabled and "Pause Automation"
                or "Resume Automation"
        end,
        deliveryFleetPrompt = deliveryFleetPrompt,
        supplierPartnershipPrompt = supplierPartnershipPrompt,
        setSupplierPartnershipPurchased = function(purchased)
            supplierPartnershipPurchased = purchased == true
            local deliveryPrompts = {
                { orderDeliveryPrompt, "Citrus Pop", "citrusPop" },
                { berryDeliveryOrderPrompt, "Berry Bites", "berryBites" },
                { appleDeliveryOrderPrompt, "Apples", "goldenApples" },
                { cerealDeliveryOrderPrompt, "Cereal", "sunriseCereal" },
                { cinnamonTwistDeliveryOrderPrompt, "Cinnamon Twists", "cinnamonTwists" },
                { frozenMealDeliveryOrderPrompt, "Freezer Meals", "frozenMeals" },
            }
            for _, entry in ipairs(deliveryPrompts) do
                if entry[1] then
                    local baseCost = Economy.PRODUCTS[entry[3]].deliveryCost
                    local cost = purchased and math.floor(baseCost * 0.8) or baseCost
                    entry[1].ActionText = string.format("Order %s ($%d)", entry[2], cost)
                end
            end
            supplierPartnershipPrompt.Enabled = currentStage == "Complete"
                and distributionCenterPurchased
                and not supplierPartnershipPurchased
            supplierPartnershipPad.Transparency = (
                distributionCenterPurchased and not supplierPartnershipPurchased
            )
                    and 0
                or 1
        end,
        distributionCenterPrompt = distributionCenterPrompt,
        setDistributionCenterPurchased = function(purchased)
            distributionCenterPurchased = purchased == true
            if distributionCenterPurchased then
                addDistributionCenter()
            end
            distributionCenterPrompt.Enabled = currentStage == "Complete"
                and deliveryFleetPurchased
                and not distributionCenterPurchased
            distributionCenterPad.Transparency = (
                deliveryFleetPurchased and not distributionCenterPurchased
            )
                    and 0
                or 1
            supplierPartnershipPrompt.Enabled = currentStage == "Complete"
                and distributionCenterPurchased
                and not supplierPartnershipPurchased
            supplierPartnershipPad.Transparency = (
                distributionCenterPurchased and not supplierPartnershipPurchased
            )
                    and 0
                or 1
        end,
        setDeliveryFleetPurchased = function(purchased)
            deliveryFleetPurchased = purchased == true
            if deliveryFleetPurchased then
                addDeliveryFleet()
            end
            deliveryFleetPrompt.Enabled = currentStage == "Complete"
                and warehousePurchased
                and deliveryWorkerHired
                and not deliveryFleetPurchased
            deliveryFleetPad.Transparency = (
                deliveryFleetPurchased
                or not warehousePurchased
                or not deliveryWorkerHired
            )
                    and 1
                or 0
            distributionCenterPrompt.Enabled = currentStage == "Complete"
                and deliveryFleetPurchased
                and not distributionCenterPurchased
            distributionCenterPad.Transparency = (
                deliveryFleetPurchased and not distributionCenterPurchased
            )
                    and 0
                or 1
        end,
        addWarehouse = addWarehouse,
        setWarehousePurchased = function(purchased)
            warehousePurchased = purchased == true
            if warehousePurchased then
                addWarehouse()
            else
                warehousePrompt.Enabled = currentStage == "Complete"
            end
            deliveryFleetPrompt.Enabled = currentStage == "Complete"
                and warehousePurchased
                and deliveryWorkerHired
                and not deliveryFleetPurchased
            deliveryFleetPad.Transparency = (
                deliveryFleetPurchased
                or not warehousePurchased
                or not deliveryWorkerHired
            )
                    and 1
                or 0
            distributionCenterPrompt.Enabled = currentStage == "Complete"
                and deliveryFleetPurchased
                and not distributionCenterPurchased
            distributionCenterPad.Transparency = (
                deliveryFleetPurchased and not distributionCenterPurchased
            )
                    and 0
                or 1
        end,
        onlineOrderPrompt = function()
            return onlineOrderPrompt
        end,
        setOnlineOrderState = function(order)
            if not order or not onlineOrderBoardLabel then
                return
            end
            onlineOrderReady = order.ready == true
            local lines = {}
            for _, item in ipairs(order.items or {}) do
                table.insert(lines, string.format("%s x%d", item.displayName, item.quantity))
            end
            onlineOrderBoardLabel.Text = string.format(
                "ONLINE ORDER #%d\n%s\n%s  •  PACK VALUE $%d",
                order.number or 1,
                table.concat(lines, "  •  "),
                order.ready and "READY TO PACK" or "BACKROOM STOCK NEEDED",
                order.total or 0
            )
            if onlineOrderPrompt then
                onlineOrderPrompt.Enabled = warehousePurchased
                    and currentStage == "Complete"
                    and order.ready == true
            end
        end,
    }
end

return WorldBuilder
