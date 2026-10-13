local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local network = ReplicatedStorage:WaitForChild("SupermarketChaosNetwork")
local stateEvent = network:WaitForChild("ShiftState")
local layoutEvent = network:WaitForChild("RetailLayoutRequest")

local products = {
    { id = "citrusPop", name = "Citrus Pop" },
    { id = "berryBites", name = "Berry Bites" },
    { id = "goldenApples", name = "Golden Apples" },
    { id = "sunriseCereal", name = "Sunrise Cereal" },
    { id = "cinnamonTwists", name = "Bakery" },
    { id = "frozenMeals", name = "Freezer" },
}

local gui = Instance.new("ScreenGui")
gui.Name = "RetailLayoutEditor"
gui.ResetOnSpawn = false
gui.DisplayOrder = 21
gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.9, 0, 0, 540)
panel.BackgroundColor3 = Color3.fromRGB(249, 239, 216)
panel.BorderSizePixel = 0
panel.Parent = gui
local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(250, 540)
sizeConstraint.MaxSize = Vector2.new(330, 540)
sizeConstraint.Parent = panel
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(22, 79, 82)
stroke.Thickness = 2
stroke.Parent = panel

local function makeLabel(text, position, size, fontSize, bold)
    local object = Instance.new("TextLabel")
    object.Position = position
    object.Size = size
    object.BackgroundTransparency = 1
    object.Text = text
    object.TextColor3 = Color3.fromRGB(17, 57, 61)
    object.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    object.TextSize = fontSize
    object.TextXAlignment = Enum.TextXAlignment.Left
    object.Parent = panel
    return object
end

makeLabel("STORE LAYOUT", UDim2.fromOffset(14, 10), UDim2.new(1, -28, 0, 28), 18, true)
local instructions = makeLabel(
    "Move a department shelf or checkout lane. The customer queue moves with checkout.",
    UDim2.fromOffset(14, 40),
    UDim2.new(1, -28, 0, 42),
    12,
    false
)
instructions.TextWrapped = true
local status = makeLabel(
    "Choose a department shelf.",
    UDim2.fromOffset(14, 500),
    UDim2.new(1, -28, 0, 28),
    12,
    true
)
status.TextWrapped = true

local function makeButton(text, position, size)
    local button = Instance.new("TextButton")
    button.Position = position
    button.Size = size
    button.BackgroundColor3 = Color3.fromRGB(215, 237, 244)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(17, 57, 61)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.AutoButtonColor = true
    button.Parent = panel
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    return button
end

local productButtons = {}
local checkoutButton =
    makeButton("Checkout lane + queue", UDim2.new(0.06, 0, 0, 86), UDim2.new(0.88, 0, 0, 32))
for index = 1, 4 do
    local product = products[index]
    local button = makeButton(
        product.name,
        UDim2.new(0.06, 0, 0, 125 + (index - 1) * 36),
        UDim2.new(0.88, 0, 0, 32)
    )
    productButtons[product.id] = button
end
local expansionButtons = {}
for index, product in ipairs({ products[5], products[6] }) do
    local button = makeButton(
        product.name .. " Department",
        UDim2.new(0.06, 0, 0, 269 + (index - 1) * 36),
        UDim2.new(0.88, 0, 0, 32)
    )
    button.Visible = false
    productButtons[product.id] = button
    expansionButtons[product.id] = button
end
local fixtureButtons = {}
for index, fixture in ipairs({
    { id = "shelfBay", name = "Extra Shelf Bay" },
    { id = "householdAisle", name = "Household Aisle" },
}) do
    local button = makeButton(
        fixture.name,
        UDim2.new(0.06, 0, 0, 341 + (index - 1) * 36),
        UDim2.new(0.88, 0, 0, 32)
    )
    button.Visible = false
    fixtureButtons[fixture.id] = button
end
local buildAisleButton =
    makeButton("Build grocery aisle ($250)", UDim2.new(0.06, 0, 0, 416), UDim2.new(0.88, 0, 0, 34))
local moveButton =
    makeButton("Move selected fixture", UDim2.new(0.06, 0, 0, 460), UDim2.new(0.47, 0, 0, 34))
local rotateButton =
    makeButton("Rotate 90°", UDim2.new(0.55, 0, 0, 460), UDim2.new(0.39, 0, 0, 34))
local closeButton = makeButton("Close", UDim2.new(0.78, 0, 0, 10), UDim2.new(0.16, 0, 0, 28))

local selectedProductId
local selectedFixtureId
local selectedConstructedAisleId
local selectedCheckout = false
local floorExpansionOwned = false
local shelfBayOwned = false
local rotation = 0
local moveMode = false
local buildingAisle = false
local pointerPosition
local ghost

local function fixtureSize(productId, rotationValue)
    local width, depth, height
    if productId == "cinnamonTwists" then
        width, depth, height = 8, 8.6, 7
    elseif productId == "frozenMeals" then
        width, depth, height = 8.4, 7.6, 7
    elseif
        productId == "shelfBay"
        or productId == "householdAisle"
        or productId == "constructedAisle"
    then
        width, depth, height = 8, 2.4, 7
    else
        width = productId == "goldenApples" and 4 or 6
        depth, height = 2.2, 7
    end
    if rotationValue == 90 then
        width, depth = depth, width
    end
    return Vector3.new(width, height, depth)
end

local function destroyGhost()
    if ghost then
        ghost:Destroy()
        ghost = nil
    end
end

local function setMoveMode(enabled)
    moveMode = enabled
    if enabled then
        if
            not selectedProductId
            and not selectedFixtureId
            and not selectedConstructedAisleId
            and not selectedCheckout
            and not buildingAisle
        then
            moveMode = false
            status.Text = "Choose a department shelf or checkout lane first."
            return
        end
        if selectedCheckout then
            status.Text = "Tap an open front-floor tile to move checkout and its queue."
        elseif buildingAisle then
            status.Text = "Tap an open floor tile to build a grocery aisle for $250."
        else
            status.Text = "Tap an open floor tile to move this fixture."
        end
    else
        destroyGhost()
        status.Text = "Choose a department shelf."
    end
end

local function ensureGhost()
    if ghost then
        return
    end
    ghost = Instance.new("Part")
    ghost.Name = "Local Retail Shelf Preview"
    ghost.Anchored = true
    ghost.CanCollide = false
    ghost.CanTouch = false
    ghost.CanQuery = false
    ghost.Material = Enum.Material.ForceField
    ghost.Transparency = 0.48
    ghost.Size = selectedCheckout and Vector3.new(8, 7, 11.5)
        or fixtureSize(
            selectedConstructedAisleId and "constructedAisle"
                or selectedFixtureId
                or selectedProductId,
            rotation
        )
    ghost.Parent = workspace
end

local function snap(value, minimum, maximum)
    local snapped = minimum + math.floor((value - minimum) / 2 + 0.5) * 2
    return snapped, snapped >= minimum and snapped <= maximum
end

local function findRetailProductId(instance)
    local current = instance
    while current and current ~= workspace do
        local productId = current:GetAttribute("RetailProductId")
        if type(productId) == "string" then
            return productId
        end
        current = current.Parent
    end
    return nil
end

local function findRetailFixtureId(instance)
    local current = instance
    while current and current ~= workspace do
        local fixtureId = current:GetAttribute("RetailFixtureId")
        if type(fixtureId) == "string" then
            return fixtureId
        end
        current = current.Parent
    end
    return nil
end

local function findConstructedAisleId(instance)
    local current = instance
    while current and current ~= workspace do
        local aisleId = current:GetAttribute("ConstructedRetailAisleId")
        if type(aisleId) == "string" then
            return aisleId
        end
        current = current.Parent
    end
    return nil
end

local function isCheckoutFixture(instance)
    local current = instance
    while current and current ~= workspace do
        if current.Name == "Checkout Lane" then
            return true
        end
        current = current.Parent
    end
    return false
end

local function raycastPointer(excludeShelves)
    local camera = workspace.CurrentCamera
    if not camera or not pointerPosition then
        return nil
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local exclude = {}
    if player.Character then
        table.insert(exclude, player.Character)
    end
    if ghost then
        table.insert(exclude, ghost)
    end
    if excludeShelves then
        local locationId = player:GetAttribute("ActiveStoreLocation") or "neighborhood"
        local worldName = locationId == "neighborhood" and "SupermarketChaosWorld"
            or "SupermarketChaosWorld_" .. locationId
        local world = workspace:FindFirstChild(worldName)
        local interior = world and world:FindFirstChild("StoreInterior")
        local departmentShelves = interior and interior:FindFirstChild("Retail Department Shelves")
        if departmentShelves then
            table.insert(exclude, departmentShelves)
        end
        local checkoutLane = interior and interior:FindFirstChild("Checkout Lane")
        if checkoutLane then
            table.insert(exclude, checkoutLane)
        end
        local bakery = interior and interior:FindFirstChild("Bakery Department")
        if bakery then
            table.insert(exclude, bakery)
        end
        local freezer = interior and interior:FindFirstChild("Frozen Foods Department")
        if freezer then
            table.insert(exclude, freezer)
        end
        for _, fixtureId in ipairs({ "shelfBay", "householdAisle" }) do
            for _, candidate in ipairs(interior and interior:GetChildren() or {}) do
                if candidate:GetAttribute("RetailFixtureId") == fixtureId then
                    table.insert(exclude, candidate)
                end
            end
        end
        local constructedAisles = interior
            and interior:FindFirstChild("Player Constructed Retail Aisles")
        if constructedAisles then
            table.insert(exclude, constructedAisles)
        end
    end
    params.FilterDescendantsInstances = exclude
    local ray = camera:ScreenPointToRay(pointerPosition.X, pointerPosition.Y)
    return workspace:Raycast(ray.Origin, ray.Direction * 500, params)
end

for productId, button in pairs(productButtons) do
    button.Activated:Connect(function()
        selectedCheckout = false
        selectedFixtureId = nil
        selectedConstructedAisleId = nil
        buildingAisle = false
        selectedProductId = productId
        rotation = 0
        rotateButton.Text = "Rotate 90°"
        ensureGhost()
        ghost.Size = fixtureSize(productId, rotation)
        status.Text = "Selected " .. button.Text .. ". Choose Move selected shelf."
    end)
end

for fixtureId, button in pairs(fixtureButtons) do
    button.Activated:Connect(function()
        selectedCheckout = false
        selectedProductId = nil
        selectedConstructedAisleId = nil
        buildingAisle = false
        selectedFixtureId = fixtureId
        rotation = 0
        rotateButton.Text = "Rotate 90°"
        ensureGhost()
        ghost.Size = fixtureSize(fixtureId, rotation)
        status.Text = "Selected " .. button.Text .. ". Choose Move selected fixture."
    end)
end

buildAisleButton.Activated:Connect(function()
    if not shelfBayOwned then
        status.Text = "Build the first shelf bay before adding grocery aisles."
        return
    end
    selectedCheckout = false
    selectedProductId = nil
    selectedFixtureId = nil
    selectedConstructedAisleId = nil
    buildingAisle = true
    rotation = 0
    rotateButton.Text = "Rotate 90°"
    ensureGhost()
    ghost.Size = fixtureSize("constructedAisle", rotation)
    setMoveMode(true)
end)

checkoutButton.Activated:Connect(function()
    selectedProductId = nil
    selectedFixtureId = nil
    selectedConstructedAisleId = nil
    buildingAisle = false
    selectedCheckout = true
    rotation = 0
    rotateButton.Text = "Rotate 90°"
    ensureGhost()
    ghost.Size = Vector3.new(8, 7, 11.5)
    status.Text = "Selected checkout and queue. Choose Move selected fixture."
end)

moveButton.Activated:Connect(function()
    setMoveMode(true)
end)

rotateButton.Activated:Connect(function()
    rotation = rotation == 0 and 90 or 0
    rotateButton.Text = rotation == 0 and "Rotate 90°" or "Rotate 0°"
    if ghost and (selectedProductId or selectedFixtureId) then
        ghost.Size = fixtureSize(selectedFixtureId or selectedProductId, rotation)
    end
    if ghost and (selectedConstructedAisleId or buildingAisle) then
        ghost.Size = fixtureSize("constructedAisle", rotation)
    end
    if ghost and selectedCheckout then
        ghost.Size = rotation == 0 and Vector3.new(8, 7, 11.5) or Vector3.new(11.5, 7, 8)
    end
end)

closeButton.Activated:Connect(function()
    setMoveMode(false)
    gui.Enabled = false
end)

local function onPointerDown(input, processed)
    if processed or not gui.Enabled then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        pointerPosition = UserInputService:GetMouseLocation()
    elseif input.UserInputType == Enum.UserInputType.Touch then
        pointerPosition = input.Position
    else
        return
    end
    local hit = raycastPointer(moveMode)
    if not hit then
        status.Text = moveMode and "Tap the retail floor inside the store."
            or "Select a shelf to move."
        return
    end
    if moveMode then
        local expansionDepartment = selectedProductId == "cinnamonTwists"
            or selectedProductId == "frozenMeals"
        local movableFixture = selectedFixtureId ~= nil
        local constructedAisle = selectedConstructedAisleId ~= nil or buildingAisle
        local minX = (selectedCheckout or constructedAisle) and -14
            or (expansionDepartment and -16 or (movableFixture and -18 or -12))
        local maxX = (selectedCheckout or constructedAisle) and 14
            or (expansionDepartment and 16 or (movableFixture and 18 or 12))
        local minZ, maxZ
        if selectedCheckout then
            minZ, maxZ = 6, 12
        elseif constructedAisle and floorExpansionOwned and hit.Position.Z < -17 then
            minZ, maxZ = -34, -20
        elseif constructedAisle then
            minZ, maxZ = -16, 14
        elseif movableFixture then
            minZ, maxZ = -16, -2
        elseif floorExpansionOwned and hit.Position.Z < -17 then
            minZ, maxZ = -33, -21
        else
            minZ, maxZ = -9, -1
        end
        local x, validX = snap(hit.Position.X, minX, maxX)
        local z, validZ = snap(hit.Position.Z, minZ, maxZ)
        if not validX or not validZ then
            status.Text = "That point is outside the marked retail layout zone."
            return
        end
        local action = if selectedCheckout
            then "MoveCheckout"
            elseif buildingAisle then "BuildAisle"
            elseif selectedConstructedAisleId then "MoveAisle"
            elseif movableFixture then "MoveFixture"
            else "MoveShelf"
        layoutEvent:FireServer({
            action = action,
            productId = selectedProductId,
            fixtureId = selectedFixtureId,
            id = selectedConstructedAisleId,
            x = x,
            z = z,
            rotation = rotation,
        }, player:GetAttribute("ActiveStoreLocation") or "neighborhood")
        buildingAisle = false
        setMoveMode(false)
        status.Text = "Checking fixture bounds and aisle clearance…"
    else
        local productId = findRetailProductId(hit.Instance)
        local constructedAisleId = findConstructedAisleId(hit.Instance)
        if constructedAisleId then
            selectedProductId = nil
            selectedFixtureId = nil
            selectedConstructedAisleId = constructedAisleId
            selectedCheckout = false
            buildingAisle = false
            ensureGhost()
            ghost.Size = fixtureSize("constructedAisle", rotation)
            status.Text = "Selected grocery aisle. Choose Move selected fixture."
        elseif isCheckoutFixture(hit.Instance) then
            selectedProductId = nil
            selectedFixtureId = nil
            selectedConstructedAisleId = nil
            buildingAisle = false
            selectedCheckout = true
            ensureGhost()
            ghost.Size = rotation == 0 and Vector3.new(8, 7, 11.5) or Vector3.new(11.5, 7, 8)
            status.Text = "Selected checkout and queue. Choose Move selected fixture."
        elseif findRetailFixtureId(hit.Instance) then
            local fixtureId = findRetailFixtureId(hit.Instance)
            if fixtureButtons[fixtureId] and fixtureButtons[fixtureId].Visible then
                selectedProductId = nil
                selectedFixtureId = fixtureId
                selectedConstructedAisleId = nil
                buildingAisle = false
                selectedCheckout = false
                ensureGhost()
                ghost.Size = fixtureSize(fixtureId, rotation)
                status.Text = "Selected "
                    .. fixtureButtons[fixtureId].Text
                    .. ". Choose Move selected fixture."
            end
        elseif productId and productButtons[productId] then
            selectedProductId = productId
            selectedFixtureId = nil
            selectedConstructedAisleId = nil
            buildingAisle = false
            selectedCheckout = false
            ensureGhost()
            local width = productId == "goldenApples" and 4 or 6
            ghost.Size = rotation == 0 and Vector3.new(width, 7, 2.2) or Vector3.new(2.2, 7, width)
            status.Text = "Selected "
                .. productButtons[productId].Text
                .. ". Choose Move selected shelf."
        else
            status.Text = "Tap the checkout lane or a product department shelf to select it."
        end
    end
end
UserInputService.InputBegan:Connect(onPointerDown)

RunService.RenderStepped:Connect(function()
    if not gui.Enabled or not moveMode then
        return
    end
    if UserInputService.MouseEnabled then
        pointerPosition = UserInputService:GetMouseLocation()
    end
    ensureGhost()
    local hit = raycastPointer(true)
    if not hit then
        ghost.Transparency = 1
        return
    end
    local movableFixture = selectedFixtureId ~= nil
    local constructedAisle = selectedConstructedAisleId ~= nil or buildingAisle
    local minX = (selectedCheckout or constructedAisle) and -14 or (movableFixture and -18 or -12)
    local maxX = (selectedCheckout or constructedAisle) and 14 or (movableFixture and 18 or 12)
    local width = selectedProductId == "goldenApples" and 4 or 6
    if selectedProductId == "cinnamonTwists" or selectedProductId == "frozenMeals" then
        minX, maxX = -16, 16
    end
    local zMinimum, zMaximum = movableFixture and -16 or -9, -1
    if constructedAisle then
        zMinimum, zMaximum = -16, 14
        if floorExpansionOwned and hit.Position.Z < -17 then
            zMinimum, zMaximum = -34, -20
        end
    end
    local x, validX = snap(hit.Position.X, minX, maxX)
    local z, validZ = snap(hit.Position.Z, zMinimum, zMaximum)
    if selectedCheckout then
        x, validX = snap(hit.Position.X, -14, 14)
        z, validZ = snap(hit.Position.Z, 6, 12)
    elseif constructedAisle and floorExpansionOwned and hit.Position.Z < -17 then
        z, validZ = snap(hit.Position.Z, -34, -20)
    elseif
        not movableFixture
        and not constructedAisle
        and floorExpansionOwned
        and hit.Position.Z < -17
    then
        z, validZ = snap(hit.Position.Z, -33, -21)
    end
    if selectedFixtureId or constructedAisle then
        width = 8
    end
    local depth = constructedAisle and 2.4 or 2.2
    local halfX = selectedCheckout and (rotation == 0 and 4.5 or 5.75)
        or (rotation == 0 and width / 2 or depth / 2)
    local halfZ = selectedCheckout and (rotation == 0 and 5.75 or 4.5)
        or (rotation == 0 and depth / 2 or width / 2)
    local minimumFloorZ = z < -17 and -39.5 or -18.5
    local inside = validX
        and validZ
        and x - halfX >= -20.5
        and x + halfX <= 20.5
        and z - halfZ >= minimumFloorZ
        and z + halfZ <= 16.5
    if selectedCheckout then
        inside = inside and x >= -14 and x <= 14 and z >= 6 and z <= 12
    elseif constructedAisle and z < -17 then
        inside = inside and floorExpansionOwned and z >= -34 and z <= -20
    elseif constructedAisle then
        inside = inside and z >= -16 and z <= 14
    elseif z < -17 then
        inside = inside and floorExpansionOwned and z >= -33 and z <= -21
    end
    ghost.CFrame = CFrame.new(x, 3.5, z) * CFrame.Angles(0, math.rad(rotation), 0)
    ghost.Transparency = 0.48
    ghost.Color = inside and Color3.fromRGB(115, 200, 130) or Color3.fromRGB(230, 100, 90)
end)

layoutEvent.OnClientEvent:Connect(function(message)
    if type(message) ~= "table" then
        return
    end
    if message.locationId ~= (player:GetAttribute("ActiveStoreLocation") or "neighborhood") then
        return
    end
    if message.action == "Open" then
        selectedProductId = nil
        selectedFixtureId = nil
        selectedConstructedAisleId = nil
        selectedCheckout = false
        buildingAisle = false
        floorExpansionOwned = message.floorExpansionOwned == true
        shelfBayOwned = message.shelfBayPurchased == true
        buildAisleButton.Visible = shelfBayOwned
        expansionButtons.cinnamonTwists.Visible = message.bakeryPurchased == true
        expansionButtons.frozenMeals.Visible = message.freezerPurchased == true
        fixtureButtons.shelfBay.Visible = message.shelfBayPurchased == true
        fixtureButtons.householdAisle.Visible = message.householdAislePurchased == true
        rotation = 0
        setMoveMode(false)
        gui.Enabled = true
        status.Text = "Select checkout and its queue, or a department shelf."
    elseif message.action == "Updated" then
        status.Text = tostring(message.message or "Retail layout saved.")
    elseif message.action == "Rejected" then
        status.Text = tostring(message.message or "That shelf position was rejected.")
    end
end)

stateEvent.OnClientEvent:Connect(function(state)
    if
        gui.Enabled
        and type(state) == "table"
        and state.locationId == (player:GetAttribute("ActiveStoreLocation") or "neighborhood")
        and state.stage ~= "Complete"
    then
        setMoveMode(false)
        gui.Enabled = false
    end
end)
