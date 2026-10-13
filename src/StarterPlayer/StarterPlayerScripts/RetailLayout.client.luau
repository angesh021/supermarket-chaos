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
panel.Size = UDim2.new(0.9, 0, 0, 350)
panel.BackgroundColor3 = Color3.fromRGB(249, 239, 216)
panel.BorderSizePixel = 0
panel.Parent = gui
local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(250, 350)
sizeConstraint.MaxSize = Vector2.new(330, 350)
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
    "Choose a department, then move it to an open floor tile. Shelves snap to a 2-stud grid.",
    UDim2.fromOffset(14, 40),
    UDim2.new(1, -28, 0, 42),
    12,
    false
)
instructions.TextWrapped = true
local status = makeLabel(
    "Choose a department shelf.",
    UDim2.fromOffset(14, 309),
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
for index, product in ipairs(products) do
    local button = makeButton(
        product.name,
        UDim2.new(0.06, 0, 0, 91 + (index - 1) * 43),
        UDim2.new(0.88, 0, 0, 36)
    )
    productButtons[product.id] = button
end
local moveButton =
    makeButton("Move selected shelf", UDim2.new(0.06, 0, 0, 270), UDim2.new(0.47, 0, 0, 34))
local rotateButton =
    makeButton("Rotate 90°", UDim2.new(0.55, 0, 0, 270), UDim2.new(0.39, 0, 0, 34))
local closeButton = makeButton("Close", UDim2.new(0.78, 0, 0, 10), UDim2.new(0.16, 0, 0, 28))

local selectedProductId
local rotation = 0
local moveMode = false
local pointerPosition
local ghost

local function destroyGhost()
    if ghost then
        ghost:Destroy()
        ghost = nil
    end
end

local function setMoveMode(enabled)
    moveMode = enabled
    if enabled then
        if not selectedProductId then
            moveMode = false
            status.Text = "Choose a department shelf first."
            return
        end
        status.Text = "Tap an open floor tile to move this shelf."
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
    ghost.Size = Vector3.new(selectedProductId == "goldenApples" and 4 or 6, 7, 2.2)
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
        local world = workspace:FindFirstChild("SupermarketChaosWorld")
        local interior = world and world:FindFirstChild("StoreInterior")
        local departmentShelves = interior and interior:FindFirstChild("Retail Department Shelves")
        if departmentShelves then
            table.insert(exclude, departmentShelves)
        end
    end
    params.FilterDescendantsInstances = exclude
    local ray = camera:ScreenPointToRay(pointerPosition.X, pointerPosition.Y)
    return workspace:Raycast(ray.Origin, ray.Direction * 500, params)
end

for productId, button in pairs(productButtons) do
    button.Activated:Connect(function()
        selectedProductId = productId
        rotation = 0
        rotateButton.Text = "Rotate 90°"
        ensureGhost()
        ghost.Size = Vector3.new(productId == "goldenApples" and 4 or 6, 7, 2.2)
        status.Text = "Selected " .. button.Text .. ". Choose Move selected shelf."
    end)
end

moveButton.Activated:Connect(function()
    setMoveMode(true)
end)

rotateButton.Activated:Connect(function()
    rotation = rotation == 0 and 90 or 0
    rotateButton.Text = rotation == 0 and "Rotate 90°" or "Rotate 0°"
    if ghost and selectedProductId then
        local width = selectedProductId == "goldenApples" and 4 or 6
        ghost.Size = rotation == 0 and Vector3.new(width, 7, 2.2) or Vector3.new(2.2, 7, width)
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
        local x, validX = snap(hit.Position.X, -12, 12)
        local z, validZ = snap(hit.Position.Z, -9, -1)
        if not validX or not validZ then
            status.Text = "That point is outside the marked retail layout zone."
            return
        end
        layoutEvent:FireServer({
            action = "MoveShelf",
            productId = selectedProductId,
            x = x,
            z = z,
            rotation = rotation,
        })
        setMoveMode(false)
        status.Text = "Checking shelf bounds and aisle clearance…"
    else
        local productId = findRetailProductId(hit.Instance)
        if productId and productButtons[productId] then
            selectedProductId = productId
            status.Text = "Selected "
                .. productButtons[productId].Text
                .. ". Choose Move selected shelf."
        else
            status.Text = "Tap a product department shelf to select it."
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
    local x, validX = snap(hit.Position.X, -12, 12)
    local z, validZ = snap(hit.Position.Z, -9, -1)
    local width = selectedProductId == "goldenApples" and 4 or 6
    local halfX = rotation == 0 and width / 2 or 1.1
    local halfZ = rotation == 0 and 1.1 or width / 2
    local inside = validX
        and validZ
        and x - halfX >= -20.5
        and x + halfX <= 20.5
        and z - halfZ >= -18.5
        and z + halfZ <= 16.5
    ghost.CFrame = CFrame.new(x, 3.5, z) * CFrame.Angles(0, math.rad(rotation), 0)
    ghost.Transparency = 0.48
    ghost.Color = inside and Color3.fromRGB(115, 200, 130) or Color3.fromRGB(230, 100, 90)
end)

layoutEvent.OnClientEvent:Connect(function(message)
    if type(message) ~= "table" then
        return
    end
    if message.action == "Open" then
        selectedProductId = nil
        rotation = 0
        setMoveMode(false)
        gui.Enabled = true
        status.Text = "Select a department shelf or tap it in the store."
    elseif message.action == "Updated" then
        status.Text = tostring(message.message or "Retail layout saved.")
    elseif message.action == "Rejected" then
        status.Text = tostring(message.message or "That shelf position was rejected.")
    end
end)

stateEvent.OnClientEvent:Connect(function(state)
    if gui.Enabled and type(state) == "table" and state.stage ~= "Complete" then
        setMoveMode(false)
        gui.Enabled = false
    end
end)
