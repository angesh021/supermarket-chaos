local WorldBuilder = {}
local TweenService = game:GetService("TweenService")

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

local function createShelf(parent, name, x, z, width, department)
    local shelf = Instance.new("Model")
    shelf.Name = name
    shelf.Parent = parent
    local function fixture(partName, size, offset, color, material)
        return part(
            shelf,
            partName,
            size,
            CFrame.new(x, 0, z) * CFrame.new(offset),
            color,
            material
        )
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
            )
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
    shelf.PrimaryPart = shelf:FindFirstChild("Wooden Kick Plate")
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

local function createLowPolyPerson(parent, name, position, shirtColor, pantsColor, hairColor)
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
    return person
end

function WorldBuilder.build()
    local customerAssistantHired = false
    local previous = workspace:FindFirstChild("SupermarketChaosWorld")
    if previous then
        previous:Destroy()
    end

    local world = Instance.new("Folder")
    world.Name = "SupermarketChaosWorld"
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
        Vector3.new(180, 1, 150),
        CFrame.new(0, -0.6, 2),
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

    -- 44 x 36 storefront; entry opening remains visible from the parking approach.
    part(
        interior,
        "Tile Floor",
        Vector3.new(44, 0.45, 36),
        CFrame.new(0, 0.24, -1),
        COLORS.cream,
        Enum.Material.CeramicTiles
    )
    part(interior, "Back Wall", Vector3.new(44, 12, 1), CFrame.new(0, 6, -19), COLORS.cream)
    part(interior, "Left Wall", Vector3.new(1, 12, 36), CFrame.new(-22, 6, -1), COLORS.cream)
    part(interior, "Right Wall", Vector3.new(1, 12, 36), CFrame.new(22, 6, -1), COLORS.cream)
    part(interior, "Front Left Pier", Vector3.new(1, 12, 1), CFrame.new(-22, 6, 17), COLORS.cream)
    part(interior, "Front Right Pier", Vector3.new(1, 12, 1), CFrame.new(22, 6, 17), COLORS.cream)
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
    -- Fixed-open automatic sliding glass panels frame a clear walk-in entrance.
    for _, x in ipairs({ -5.05, 5.05 }) do
        local doorPanel = part(
            exterior,
            "Automatic Entrance Glass Door",
            Vector3.new(5.7, 7.7, 0.16),
            CFrame.new(x, 4.4, 16.78),
            COLORS.blue,
            Enum.Material.Glass,
            0.58
        )
        doorPanel.CanCollide = false
    end
    for _, x in ipairs({ -2.35, 2.35 }) do
        part(
            exterior,
            "Automatic Door Pull",
            Vector3.new(0.12, 1.3, 0.1),
            CFrame.new(x, 4.35, 16.62),
            COLORS.gold,
            Enum.Material.Metal
        )
    end
    part(
        exterior,
        "Automatic Door Track",
        Vector3.new(12, 0.22, 0.3),
        CFrame.new(0, 8.42, 16.8),
        COLORS.gray,
        Enum.Material.Metal
    )
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
    label(
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
    part(
        interior,
        "Back Wall Teal Wainscot",
        Vector3.new(43, 1.1, 0.22),
        CFrame.new(0, 0.95, -18.43),
        COLORS.teal,
        Enum.Material.SmoothPlastic
    )

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

    local shelf = createShelf(interior, "Citrus Pop Shelf", -10, -1, 6, "CITRUS POP")
    local berryShelf = createShelf(interior, "Berry Bites Shelf", 10, -1, 6, "BERRY BITES")
    local goldenAppleShelf =
        createShelf(interior, "Golden Apples Produce Shelf", -17, 0, 4, "GOLDEN APPLES")
    createShelf(interior, "Pantry Shelf", 0, -1, 6, "SNACKS")
    createShelf(interior, "Breakfast and Pantry Shelf", -10, -9, 6, "PANTRY")
    local cerealShelf = createShelf(interior, "Sunrise Cereal Shelf", 0, -9, 6, "SUNRISE CEREAL")
    local priceTags = {}
    local pricePrompts = {}
    local initialPrices = {
        citrusPop = 25,
        berryBites = 18,
        goldenApples = 12,
        sunriseCereal = 16,
    }
    local function createPriceTag(productId, displayName, shelfModel, x, z)
        local tag = label(
            interior,
            displayName .. " Shelf Price Tag",
            string.format("$%d", initialPrices[productId]),
            Vector3.new(1.45, 0.58, 0.12),
            CFrame.new(x, 1.95, z - 1.17),
            COLORS.gold,
            COLORS.ink
        )
        local changePrompt =
            prompt(shelfModel.PrimaryPart, "Change Price", displayName, "ChangePrice", 9)
        priceTags[productId] = tag
        pricePrompts[productId] = changePrompt
        changePrompt.ActionText = string.format("Change Price ($%d)", initialPrices[productId])
    end
    createPriceTag("citrusPop", "Citrus Pop", shelf, -10, -1)
    createPriceTag("berryBites", "Berry Bites", berryShelf, 10, -1)
    createPriceTag("goldenApples", "Golden Apples", goldenAppleShelf, -17, 0)
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

    -- A staffed register has a distinct conveyor, scanner, POS screen, and impulse-buy rack.
    local counter = part(
        interior,
        "Checkout Counter",
        Vector3.new(8, 2.5, 3.5),
        CFrame.new(14, 1.7, 8),
        COLORS.deepTeal,
        Enum.Material.Metal
    )
    part(
        interior,
        "Checkout Counter Front Panel",
        Vector3.new(7.5, 1.55, 0.18),
        CFrame.new(14, 1.65, 9.78),
        COLORS.wood,
        Enum.Material.WoodPlanks
    )
    part(
        interior,
        "Checkout Conveyor Belt",
        Vector3.new(4.1, 0.18, 2.5),
        CFrame.new(13.2, 3.05, 8.05),
        COLORS.ink,
        Enum.Material.SmoothPlastic
    )
    part(
        interior,
        "Checkout Bagging Counter",
        Vector3.new(3.5, 0.22, 2.7),
        CFrame.new(16.7, 3.05, 8.05),
        COLORS.warmWhite,
        Enum.Material.Marble
    )
    part(
        interior,
        "Checkout Scanner",
        Vector3.new(0.9, 0.12, 0.8),
        CFrame.new(15.25, 3.2, 7.45),
        COLORS.coral,
        Enum.Material.Neon
    )
    part(
        interior,
        "Checkout Screen",
        Vector3.new(1.15, 0.85, 0.18),
        CFrame.new(12.2, 3.8, 6.65),
        COLORS.ink,
        Enum.Material.SmoothPlastic
    )
    local checkoutDisplay = part(
        interior,
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
    label(
        interior,
        "Checkout Overhead Sign",
        "CHECKOUT  •  LANE 01",
        Vector3.new(7, 1.15, 0.3),
        CFrame.new(14, 6.25, 6.1),
        COLORS.deepTeal,
        COLORS.warmWhite
    )
    local impulseRack = part(
        interior,
        "Checkout Candy Rack",
        Vector3.new(1.2, 2.1, 1.25),
        CFrame.new(19.2, 1.55, 4.5),
        COLORS.gray,
        Enum.Material.Metal
    )
    impulseRack.CanCollide = false
    for row = 1, 3 do
        for column = 1, 2 do
            part(
                interior,
                "Checkout Treat Pack",
                Vector3.new(0.42, 0.42, 0.4),
                CFrame.new(18.9 + column * 0.36, 1.0 + row * 0.42, 3.9),
                ({ COLORS.coral, COLORS.gold, COLORS.green })[row],
                Enum.Material.SmoothPlastic
            )
        end
    end
    local currentStage = "Loading"
    local aisleExpansionPurchased = false
    local customerModels = {}
    local customerColors = {
        { COLORS.blue, COLORS.deepTeal, COLORS.orange },
        { COLORS.coral, COLORS.gray, COLORS.deepTeal },
        { COLORS.green, COLORS.blue, COLORS.gold },
        { COLORS.orange, COLORS.deepTeal, COLORS.cream },
        { COLORS.paleGreen, COLORS.wood, COLORS.coral },
    }
    local customerPositions = {
        Vector3.new(17.5, 0.45, 4),
        Vector3.new(17.5, 0.45, 8),
        Vector3.new(17.5, 0.45, 12),
        Vector3.new(17.5, 0.45, 15),
        Vector3.new(14, 0.45, 15),
    }
    for index, position in ipairs(customerPositions) do
        local colors = customerColors[index]
        local customer = createLowPolyPerson(
            interior,
            index == 1 and "Checkout Customer" or ("Queue Customer " .. index),
            position,
            colors[1],
            colors[2],
            colors[3]
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
    local customerProductPosition = Vector3.new(-10, 0.45, 4)
    local customerProductPositions = { customerProductPosition }
    local function customerQueueStatus(queueNumber)
        if currentStage == "Spill" then
            return "WAITING • SPILL"
        elseif currentStage == "PowerOutage" then
            return "WAITING • POWER OUT"
        elseif currentStage == "CustomerRush" then
            return "RUSH CUSTOMER"
        end
        return queueNumber == 1 and "NEXT CUSTOMER" or "IN QUEUE"
    end

    local function browseCustomerBasket(entry, speed, flowVersion)
        local browseSpeed = customerAssistantHired and speed * 0.7 or speed
        for _, position in ipairs(customerProductPositions) do
            if not moveCustomer(entry, position, browseSpeed, flowVersion) then
                return false
            end
        end
        return true
    end

    local function runCustomerVisit(entry, queuePosition, queueNumber, flowVersion)
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
            if not moveCustomer(entry, waypoint[1], waypoint[2], flowVersion) then
                return
            end
        end
        entry.label.Text = "BROWSING"
        if not browseCustomerBasket(entry, 0.7, flowVersion) then
            return
        end
        entry.label.Text = "BASKET: " .. string.upper(customerBasketName)
        task.wait(0.55)
        if not moveCustomer(entry, Vector3.new(5, 0.45, 4), 0.75, flowVersion) then
            return
        end
        if not moveCustomer(entry, queuePosition, 0.65, flowVersion) then
            return
        end
        entry.label.Text = customerQueueStatus(queueNumber)
        if queueNumber == 1 then
            checkoutReady = true
            register.Enabled = currentStage == "Checkout" or currentStage == "CustomerRush"
        end
    end

    local function runCustomerAdvance(entry, queuePosition, queueNumber, flowVersion)
        entry.label.Text = "BASKET: " .. string.upper(customerBasketName)
        if not browseCustomerBasket(entry, 0.55, flowVersion) then
            return
        end
        task.wait(0.35)
        entry.label.Text = "MOVING TO CHECKOUT"
        local waypoints = {
            Vector3.new(5, 0.45, 8),
            Vector3.new(5, 0.45, 4),
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
            register.Enabled = currentStage == "Checkout" or currentStage == "CustomerRush"
        end
    end

    local function runCustomerExit(entry, flowVersion)
        entry.label.Text = "THANK YOU!"
        local waypoints = {
            Vector3.new(5, 0.45, 4),
            Vector3.new(0, 0.45, 13),
            Vector3.new(0, 0.45, 22),
        }
        for _, waypoint in ipairs(waypoints) do
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
                local targetPosition = customerPositions[queueNumber]
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
        register.Enabled = (currentStage == "Checkout" or currentStage == "CustomerRush")
            and checkoutReady
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
            register.Enabled = false
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
        register.Enabled = false
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
                task.spawn(runCustomerExit, servedEntry, flowVersion)
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
            local homePosition = customerPositions[index]
            if previousRemaining == nil or index > previousTotal then
                local spawnPosition = Vector3.new((index - 2) * 1.7, 0.45, 22)
                entry.model:PivotTo(entry.homePivot + (spawnPosition - entry.homePosition))
            end
            local queuePosition = customerPositions[queueNumber] or homePosition
            if previousRemaining == nil or index > previousTotal then
                task.spawn(runCustomerVisit, entry, queuePosition, queueNumber, flowVersion)
            else
                task.spawn(runCustomerAdvance, entry, queuePosition, queueNumber, flowVersion)
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
                interior,
                "Stocked Citrus Pop Can",
                Vector3.new(0.62, 0.8, 0.62),
                CFrame.new(x, y, -0.54) * CFrame.Angles(0, 0, math.rad(90)),
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
                interior,
                "Stocked Berry Bites Pack",
                Vector3.new(0.5, 0.65, 0.5),
                CFrame.new(x, 3.73, -0.62),
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
                interior,
                "Stocked Golden Apple",
                Vector3.new(0.48, 0.48, 0.48),
                CFrame.new(-18.5 + column * 0.42, 3.55 + row * 1.3, -0.57),
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
                interior,
                "Stocked Sunrise Cereal Box",
                Vector3.new(0.56, 0.82, 0.44),
                CFrame.new(x, y, -9.55),
                ({ COLORS.orange, COLORS.gold, COLORS.green, COLORS.blue })[((index - 1) % 4) + 1],
                Enum.Material.SmoothPlastic
            )
            local labelPlate = part(
                interior,
                "Sunrise Cereal Package Label",
                Vector3.new(0.4, 0.24, 0.03),
                CFrame.new(x, y, -9.32),
                COLORS.warmWhite,
                Enum.Material.SmoothPlastic
            )
            box:SetAttribute("ProductDisplay", true)
            labelPlate:SetAttribute("ProductDisplay", true)
            table.insert(stockedCerealBoxes, box)
            table.insert(stockedCerealBoxes, labelPlate)
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
    local cashierModel = createLowPolyPerson(
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
        "HIRE DELIVERY WORKER  $140",
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
        prompt(stylePad, "Install Coastal Style ($180)", "Storefront Refresh", "MarketStyle", 10)
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
        "Preview Coastal Style",
        "Storefront Preview",
        "PreviewMarketStyle",
        10
    )
    stylePreviewPrompt.Enabled = false
    local styleSign = label(
        interior,
        "Storefront Style Sign",
        "COASTAL MARKET\n$180",
        Vector3.new(5, 2.7, 0.4),
        CFrame.new(-17.5, 4.3, 9.4),
        COLORS.green
    )
    local marketStylePurchased = false
    local marketStylePreviewing = false
    local function applyMarketStyle(isActive)
        stylePad.Color = isActive and COLORS.deepTeal or COLORS.green
        styleSign.Color = isActive and COLORS.teal or COLORS.green
        storefrontFascia.Color = isActive and COLORS.green or COLORS.teal
        storefrontSign.Color = isActive and COLORS.green or COLORS.teal
        entryCanopy.Color = isActive and COLORS.gold or COLORS.coral
        canopyValance.Color = isActive and COLORS.teal or COLORS.deepTeal
        frontHeader.Color = isActive and COLORS.green or COLORS.teal
        local surface = styleSign:FindFirstChildOfClass("SurfaceGui")
        local signText = surface and surface:FindFirstChildOfClass("TextLabel")
        if signText then
            signText.Text = marketStylePurchased and "COASTAL MARKET\nINSTALLED"
                or (marketStylePreviewing and "COASTAL MARKET\nPREVIEW" or "COASTAL MARKET\n$180")
        end
        stylePrompt.Enabled = not marketStylePurchased and currentStage == "Complete"
        stylePreviewPrompt.Enabled = not marketStylePurchased and currentStage == "Complete"
        stylePreviewPrompt.ActionText = marketStylePreviewing and "Cancel Preview"
            or "Preview Coastal Style"
    end
    local function setMarketStyle(purchased)
        marketStylePurchased = purchased == true
        marketStylePreviewing = false
        applyMarketStyle(marketStylePurchased)
    end
    local function setMarketStylePreview(previewing)
        marketStylePreviewing = previewing == true and not marketStylePurchased
        applyMarketStyle(marketStylePurchased or marketStylePreviewing)
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
    local warehouseModel
    local warehousePurchased = false
    local deliveryBoardLabel
    local deliveryCrateSurface
    local deliveryCrate
    local deliveryPrompt
    local orderDeliveryPrompt
    local berryDeliveryOrderPrompt
    local appleDeliveryOrderPrompt
    local cerealDeliveryOrderPrompt
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

    local function addWarehouse()
        if warehouseModel then
            return
        end
        warehousePurchased = true
        warehouseModel = Instance.new("Model")
        warehouseModel.Name = "Purchased Warehouse Annex"
        warehouseModel.Parent = exterior
        local center = Vector3.new(59, 0, -2)
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
        warehousePrompt.Enabled = false
    end

    local function setDeliveryState(readyAt, quantity, productId)
        deliveryReadyAt = readyAt or 0
        deliveryQuantity = quantity or 0
        deliveryProductId = productId == "sunriseCereal" and "sunriseCereal"
            or (
                productId == "goldenApples" and "goldenApples"
                or (productId == "berryBites" and "berryBites" or "citrusPop")
            )
        local productInfoById = {
            citrusPop = { name = "CITRUS POP", units = "CANS" },
            berryBites = { name = "BERRY BITES", units = "PACKS" },
            goldenApples = { name = "GOLDEN APPLES", units = "APPLES" },
            sunriseCereal = { name = "SUNRISE CEREAL", units = "BOXES" },
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
            deliveryBoardLabel.Text = "CITRUS $60 • BERRY $45\nAPPLES $35 • CEREAL $45"
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
    end

    local function setStage(stage)
        currentStage = stage
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
        register.Enabled = (stage == "Checkout" or stage == "CustomerRush") and checkoutReady
        closePrompt.Enabled = stage == "CloseShift"
        spillPrompt.Enabled = stage == "Spill"
        powerPrompt.Enabled = stage == "PowerOutage"
        upgradePrompt.Enabled = stage == "Upgrade"
        aisleExpansionPrompt.Enabled = stage == "Complete"
            and not aisleExpansionPurchased
            and interior:FindFirstChild("Purchased Shelf Bay") ~= nil
        aisleExpansionPad.Transparency = 0
        local signSurface = upgradeSign:FindFirstChildOfClass("SurfaceGui")
        local signText = signSurface and signSurface:FindFirstChildOfClass("TextLabel")
        if signText then
            signText.Text = aisleExpansionPurchased and "HOUSEHOLD AISLE\nINSTALLED"
                or (aisleExpansionPrompt.Enabled and "HOUSEHOLD AISLE\n$220")
                or (stage == "Upgrade" and "ADD SHELF BAY\n$45" or "STORE UPGRADE")
        end
        stylePrompt.Enabled = stage == "Complete" and not marketStylePurchased
        if stage ~= "Complete" and marketStylePreviewing then
            setMarketStylePreview(false)
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
        if deliveryPrompt then
            deliveryPrompt.Enabled = warehousePurchased
                and deliveryQuantity > 0
                and os.time() >= deliveryReadyAt
        end
        setSpillVisible(stage == "Spill")
        setPowerOutage(stage == "PowerOutage")
    end

    return {
        root = world,
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
        setCustomerProduct = function(displayName)
            customerProductName = displayName or "Citrus Pop"
            customerProductPosition = customerProductName == "Berry Bites"
                    and Vector3.new(10, 0.45, 4)
                or (
                    customerProductName == "Sunrise Cereal" and Vector3.new(0, 0.45, -9)
                    or Vector3.new(-10, 0.45, 4)
                )
        end,
        setCustomerBasket = function(displayName)
            customerBasketName = displayName or "Citrus Pop x1"
            customerProductPositions = {}
            if string.find(customerBasketName, "Berry Bites", 1, true) then
                table.insert(customerProductPositions, Vector3.new(10, 0.45, 4))
            end
            if string.find(customerBasketName, "Citrus Pop", 1, true) then
                table.insert(customerProductPositions, Vector3.new(-10, 0.45, 4))
            end
            if string.find(customerBasketName, "Golden Apples", 1, true) then
                table.insert(customerProductPositions, Vector3.new(-17, 0.45, -3))
            end
            if string.find(customerBasketName, "Sunrise Cereal", 1, true) then
                table.insert(customerProductPositions, Vector3.new(0, 0.45, -9))
            end
            if #customerProductPositions == 0 then
                table.insert(customerProductPositions, customerProductPosition)
            end
        end,
        setCustomerVisible = setCustomerVisible,
        setCustomerCount = setCustomerCount,
        registerPrompt = register,
        isCheckoutReady = function()
            return checkoutReady
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
        marketStylePrompt = stylePrompt,
        marketStylePreviewPrompt = stylePreviewPrompt,
        setMarketStyle = setMarketStyle,
        setMarketStylePreview = setMarketStylePreview,
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
        setStage = setStage,
        setUpgradeReady = function(ready)
            upgradeMarker.Enabled = ready
        end,
        addUpgrade = function()
            if interior:FindFirstChild("Purchased Shelf Bay") then
                return
            end
            local newShelf = createShelf(interior, "Purchased Shelf Bay", -16, -8, 6)
            newShelf:SetAttribute("PlayerPurchased", true)
            local sign = label(
                interior,
                "New Department Sign",
                "MORE TO CHOOSE",
                Vector3.new(8, 1.2, 0.35),
                CFrame.new(-16, 7.8, -5.2),
                COLORS.green
            )
            sign:SetAttribute("PlayerPurchased", true)
        end,
        addAisleExpansion = function()
            if aisleExpansionPurchased then
                return
            end
            -- A fixed, allow-listed bay inside the current floor footprint; no client placement data is used.
            local aisleExpansionModel =
                createShelf(interior, "Purchased Household Aisle", 16, -8, 6, "HOUSEHOLD")
            aisleExpansionModel:SetAttribute("PlayerPurchased", true)
            local sign = label(
                interior,
                "Household Aisle Department Sign",
                "HOME & EVERYDAY",
                Vector3.new(7, 1.1, 0.3),
                CFrame.new(16, 7.35, -9.18),
                COLORS.green,
                COLORS.warmWhite
            )
            sign:SetAttribute("PlayerPurchased", true)
            aisleExpansionPurchased = true
            aisleExpansionPrompt.Enabled = false
            aisleExpansionPad.Transparency = 0
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
        addWarehouse = addWarehouse,
        setWarehousePurchased = function(purchased)
            warehousePurchased = purchased == true
            if warehousePurchased then
                addWarehouse()
            else
                warehousePrompt.Enabled = currentStage == "Complete"
            end
        end,
    }
end

return WorldBuilder
