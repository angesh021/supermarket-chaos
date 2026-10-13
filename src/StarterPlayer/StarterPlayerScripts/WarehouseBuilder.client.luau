local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local network = ReplicatedStorage:WaitForChild("SupermarketChaosNetwork")
local stateEvent = network:WaitForChild("ShiftState")
local layoutEvent = network:WaitForChild("WarehouseLayoutRequest")

local gui = Instance.new("ScreenGui")
gui.Name = "WarehouseBuilder"
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.9, 0, 0, 250)
panel.BackgroundColor3 = Color3.fromRGB(249, 239, 216)
panel.BorderSizePixel = 0
panel.Parent = gui
local panelSizeConstraint = Instance.new("UISizeConstraint")
panelSizeConstraint.MinSize = Vector2.new(210, 250)
panelSizeConstraint.MaxSize = Vector2.new(300, 250)
panelSizeConstraint.Parent = panel
local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel
local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(22, 79, 82)
panelStroke.Thickness = 2
panelStroke.Parent = panel

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(12, 8)
title.Size = UDim2.new(1, -24, 0, 27)
title.BackgroundTransparency = 1
title.Text = "WAREHOUSE LAYOUT"
title.TextColor3 = Color3.fromRGB(17, 57, 61)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local instructions = Instance.new("TextLabel")
instructions.Position = UDim2.fromOffset(12, 36)
instructions.Size = UDim2.new(1, -24, 0, 38)
instructions.BackgroundTransparency = 1
instructions.Text =
    "Select a tool, then tap a point in the marked floor zone. Shelves snap to a grid."
instructions.TextColor3 = Color3.fromRGB(48, 57, 54)
instructions.Font = Enum.Font.Gotham
instructions.TextSize = 12
instructions.TextWrapped = true
instructions.TextXAlignment = Enum.TextXAlignment.Left
instructions.Parent = panel

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(12, 213)
status.Size = UDim2.new(1, -24, 0, 27)
status.BackgroundTransparency = 1
status.Text = "Choose a tool."
status.TextColor3 = Color3.fromRGB(22, 79, 82)
status.Font = Enum.Font.GothamMedium
status.TextSize = 12
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = panel

local function makeButton(text, xScale, y, widthScale)
    local button = Instance.new("TextButton")
    button.Position = UDim2.new(xScale, 0, 0, y)
    button.Size = UDim2.new(widthScale, 0, 0, 38)
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

local placeButton = makeButton("Place Shelf · $50", 0.04, 80, 0.44)
local moveButton = makeButton("Move Selected", 0.52, 80, 0.44)
local rotateButton = makeButton("Rotate 90°", 0.04, 126, 0.28)
local removeButton = makeButton("Remove · +$25", 0.34, 126, 0.33)
local closeButton = makeButton("Close", 0.70, 126, 0.26)

local currentLayout = { version = 1, items = {} }
local mode
local selectedId
local rotation = 0
local pointerPosition
local ghost

local function destroyGhost()
    if ghost then
        ghost:Destroy()
        ghost = nil
    end
end

local function createGhost()
    if ghost then
        return
    end
    ghost = Instance.new("Part")
    ghost.Name = "Local Warehouse Shelf Preview"
    ghost.Anchored = true
    ghost.CanCollide = false
    ghost.CanTouch = false
    ghost.CanQuery = false
    ghost.Material = Enum.Material.ForceField
    ghost.Transparency = 0.48
    ghost.Size = Vector3.new(6, 7, 2.2)
    ghost.Parent = workspace
end

local function clearMode()
    mode = nil
    destroyGhost()
    status.Text = selectedId and "Shelf selected. Choose Move, Rotate or Remove."
        or "Choose a tool."
end

local function findLayoutId(instance)
    local current = instance
    while current and current ~= workspace do
        local id = current:GetAttribute("LayoutId")
        if type(id) == "string" then
            return id
        end
        current = current.Parent
    end
    return nil
end

local function snapPosition(worldPosition)
    local x = 53 + math.floor((worldPosition.X - 53) / 2 + 0.5) * 2
    local z = -6 + math.floor((worldPosition.Z + 6) / 2 + 0.5) * 2
    return x, z, x >= 53 and x <= 65 and z >= -6 and z <= 2
end

local function previewFitsFloor(x, z)
    local halfX = rotation == 0 and 3 or 1.1
    local halfZ = rotation == 0 and 1.1 or 3
    return x - halfX >= 49.95 and x + halfX <= 68.05 and z - halfZ >= -8.2 and z + halfZ <= 4.2
end

local function raycastPointer()
    local camera = workspace.CurrentCamera
    if not camera or not pointerPosition then
        return nil
    end
    local ray = camera:ScreenPointToRay(pointerPosition.X, pointerPosition.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local exclude = {}
    if player.Character then
        table.insert(exclude, player.Character)
    end
    if ghost then
        table.insert(exclude, ghost)
    end
    if mode then
        local world = workspace:FindFirstChild("SupermarketChaosWorld")
        local exterior = world and world:FindFirstChild("Exterior")
        local warehouse = exterior and exterior:FindFirstChild("Purchased Warehouse Annex")
        local fixtures = warehouse and warehouse:FindFirstChild("Custom Warehouse Fixtures")
        if fixtures then
            table.insert(exclude, fixtures)
        end
    end
    params.FilterDescendantsInstances = exclude
    return workspace:Raycast(ray.Origin, ray.Direction * 500, params)
end

local function selectShelf(hit)
    local id = findLayoutId(hit.Instance)
    selectedId = id
    if id then
        for _, item in ipairs(currentLayout.items) do
            if item.id == id then
                rotation = item.rotation
                break
            end
        end
        status.Text = "Shelf selected. Choose Move, Rotate or Remove."
    else
        status.Text = "Tap one of your placed shelves to select it."
    end
end

placeButton.Activated:Connect(function()
    selectedId = nil
    mode = "Place"
    rotation = 0
    createGhost()
    status.Text = "Move the preview into the warehouse zone and tap to place ($50)."
end)

moveButton.Activated:Connect(function()
    if not selectedId then
        status.Text = "Tap one of your shelves first."
        return
    end
    mode = "Move"
    createGhost()
    status.Text = "Move the preview and tap to save the new position."
end)

rotateButton.Activated:Connect(function()
    rotation = rotation == 0 and 90 or 0
    rotateButton.Text = rotation == 0 and "Rotate 90°" or "Rotate 0°"
end)

removeButton.Activated:Connect(function()
    if not selectedId then
        status.Text = "Tap one of your shelves first."
        return
    end
    layoutEvent:FireServer(
        { action = "RemoveShelf", id = selectedId },
        player:GetAttribute("ActiveStoreLocation") or "neighborhood"
    )
    status.Text = "Removing shelf…"
end)

closeButton.Activated:Connect(function()
    clearMode()
    gui.Enabled = false
end)

local function onPointerDown(input, processed)
    if processed or not gui.Enabled or not panel.Visible then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        pointerPosition = UserInputService:GetMouseLocation()
    elseif input.UserInputType == Enum.UserInputType.Touch then
        pointerPosition = input.Position
    else
        return
    end
    local hit = raycastPointer()
    if not hit then
        status.Text = "Aim at the warehouse floor."
        return
    end
    if mode == "Place" or mode == "Move" then
        local x, z, inBounds = snapPosition(hit.Position)
        if not inBounds then
            status.Text = "That point is outside the marked build zone."
            return
        end
        if mode == "Place" then
            layoutEvent:FireServer(
                { action = "PlaceShelf", x = x, z = z, rotation = rotation },
                player:GetAttribute("ActiveStoreLocation") or "neighborhood"
            )
            status.Text = "Checking shelf position…"
        else
            layoutEvent:FireServer({
                action = "MoveShelf",
                id = selectedId,
                x = x,
                z = z,
                rotation = rotation,
            }, player:GetAttribute("ActiveStoreLocation") or "neighborhood")
            clearMode()
        end
    else
        selectShelf(hit)
    end
end

UserInputService.InputBegan:Connect(onPointerDown)

RunService.RenderStepped:Connect(function()
    if not gui.Enabled or not mode then
        return
    end
    if UserInputService.MouseEnabled then
        pointerPosition = UserInputService:GetMouseLocation()
    end
    createGhost()
    local hit = raycastPointer()
    if not hit then
        ghost.Transparency = 1
        return
    end
    local x, z, inBounds = snapPosition(hit.Position)
    inBounds = inBounds and previewFitsFloor(x, z)
    ghost.CFrame = CFrame.new(x, 3.7, z) * CFrame.Angles(0, math.rad(rotation), 0)
    ghost.Transparency = 0.48
    ghost.Color = inBounds and Color3.fromRGB(115, 200, 130) or Color3.fromRGB(230, 100, 90)
end)

layoutEvent.OnClientEvent:Connect(function(message)
    if type(message) ~= "table" then
        return
    end
    if message.locationId ~= (player:GetAttribute("ActiveStoreLocation") or "neighborhood") then
        return
    end
    if message.action == "Open" then
        currentLayout = type(message.layout) == "table" and message.layout
            or { version = 1, items = {} }
        selectedId = nil
        mode = nil
        destroyGhost()
        gui.Enabled = true
        status.Text = string.format("%d of 6 warehouse shelves placed.", #currentLayout.items)
    elseif message.action == "Updated" then
        currentLayout = type(message.layout) == "table" and message.layout
            or { version = 1, items = {} }
        if selectedId then
            local found = false
            for _, item in ipairs(currentLayout.items) do
                if item.id == selectedId then
                    found = true
                    break
                end
            end
            if not found then
                selectedId = nil
            end
        end
        status.Text = tostring(message.message or "Layout saved.")
    elseif message.action == "Rejected" then
        status.Text = tostring(message.message or "That layout change was rejected.")
    end
end)

stateEvent.OnClientEvent:Connect(function(state)
    if
        gui.Enabled
        and type(state) == "table"
        and state.locationId == (player:GetAttribute("ActiveStoreLocation") or "neighborhood")
    then
        if state.stage ~= "Complete" or not state.warehousePurchased then
            clearMode()
            gui.Enabled = false
        end
    end
end)
