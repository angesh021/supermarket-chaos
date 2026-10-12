local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local network = ReplicatedStorage:WaitForChild("SupermarketChaosNetwork")
local stateEvent = network:WaitForChild("ShiftState")
local joinRequestEvent = network:WaitForChild("JoinStoreRequest")
local memberActionEvent = network:WaitForChild("StoreMemberAction")
local memberStateEvent = network:WaitForChild("StoreMemberState")

local COLORS = {
    deepTeal = Color3.fromRGB(17, 57, 61),
    teal = Color3.fromRGB(22, 79, 82),
    cream = Color3.fromRGB(249, 239, 216),
    green = Color3.fromRGB(221, 242, 216),
    blue = Color3.fromRGB(215, 237, 244),
    gold = Color3.fromRGB(250, 231, 186),
    coral = Color3.fromRGB(174, 88, 76),
    ink = Color3.fromRGB(48, 57, 54),
}

local gui = Instance.new("ScreenGui")
gui.Name = "FirstShiftHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 10
gui.Parent = playerGui

-- Desktop uses the lower-left HUD; touch layout moves the collapsed card to top center.
local card = Instance.new("Frame")
card.Name = "ObjectiveCard"
card.AnchorPoint = Vector2.new(0, 1)
card.Position = UDim2.new(0, 14, 1, -14)
card.Size = UDim2.fromOffset(280, 145)
card.BackgroundColor3 = COLORS.cream
card.BackgroundTransparency = 0.03
card.BorderSizePixel = 0
card.Parent = gui

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(235, 40)
sizeConstraint.MaxSize = Vector2.new(280, 145)
sizeConstraint.Parent = card

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = card

local stroke = Instance.new("UIStroke")
stroke.Color = COLORS.teal
stroke.Thickness = 2
stroke.Parent = card

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = card

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -160, 0, 22)
title.BackgroundTransparency = 1
title.Text = "FIRST SHIFT"
title.TextColor3 = COLORS.teal
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = card

local saveStatus = Instance.new("TextLabel")
saveStatus.Name = "SaveStatus"
saveStatus.AnchorPoint = Vector2.new(1, 0)
saveStatus.Position = UDim2.new(1, -75, 0, 0)
saveStatus.Size = UDim2.fromOffset(76, 22)
saveStatus.BackgroundTransparency = 1
saveStatus.Text = "LOADING"
saveStatus.TextColor3 = COLORS.teal
saveStatus.Font = Enum.Font.GothamBold
saveStatus.TextSize = 9
saveStatus.TextXAlignment = Enum.TextXAlignment.Right
saveStatus.Parent = card

local toggle = Instance.new("TextButton")
toggle.Name = "CollapseButton"
toggle.AnchorPoint = Vector2.new(1, 0)
toggle.Position = UDim2.fromScale(1, 0)
toggle.Size = UDim2.fromOffset(24, 22)
toggle.BackgroundColor3 = COLORS.teal
toggle.TextColor3 = COLORS.cream
toggle.Text = "−"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 18
toggle.AutoButtonColor = true
toggle.Parent = card
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggle

local teamToggle = Instance.new("TextButton")
teamToggle.Name = "TeamButton"
teamToggle.AnchorPoint = Vector2.new(1, 0)
teamToggle.Position = UDim2.new(1, -27, 0, 0)
teamToggle.Size = UDim2.fromOffset(43, 22)
teamToggle.BackgroundColor3 = COLORS.gold
teamToggle.TextColor3 = COLORS.deepTeal
teamToggle.Text = "TEAM"
teamToggle.Font = Enum.Font.GothamBold
teamToggle.TextSize = 9
teamToggle.Parent = card
local teamCorner = Instance.new("UICorner")
teamCorner.CornerRadius = UDim.new(0, 6)
teamCorner.Parent = teamToggle

local objective = Instance.new("TextLabel")
objective.Name = "Objective"
objective.Position = UDim2.fromOffset(0, 24)
objective.Size = UDim2.new(1, 0, 0, 42)
objective.BackgroundTransparency = 1
objective.Text = "Loading your first task…"
objective.TextColor3 = COLORS.ink
objective.Font = Enum.Font.GothamSemibold
objective.TextSize = 14
objective.TextWrapped = true
objective.TextXAlignment = Enum.TextXAlignment.Left
objective.TextYAlignment = Enum.TextYAlignment.Top
objective.Parent = card

local stats = Instance.new("Frame")
stats.Name = "Stats"
stats.Position = UDim2.fromOffset(0, 69)
stats.Size = UDim2.new(1, 0, 0, 40)
stats.BackgroundTransparency = 1
stats.Parent = card

local function makeStat(name, heading, value, x, background, accent)
    local tile = Instance.new("Frame")
    tile.Name = name
    tile.Position = UDim2.fromScale(x, 0)
    tile.Size = UDim2.fromScale(0.315, 1)
    tile.BackgroundColor3 = background
    tile.BorderSizePixel = 0
    tile.Parent = stats
    local tileCorner = Instance.new("UICorner")
    tileCorner.CornerRadius = UDim.new(0, 7)
    tileCorner.Parent = tile
    local headingLabel = Instance.new("TextLabel")
    headingLabel.Name = "Heading"
    headingLabel.Position = UDim2.fromOffset(7, 3)
    headingLabel.Size = UDim2.new(1, -14, 0, 13)
    headingLabel.BackgroundTransparency = 1
    headingLabel.Text = heading
    headingLabel.TextColor3 = accent
    headingLabel.Font = Enum.Font.GothamBold
    headingLabel.TextSize = 9
    headingLabel.TextXAlignment = Enum.TextXAlignment.Left
    headingLabel.Parent = tile
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Position = UDim2.fromOffset(7, 16)
    valueLabel.Size = UDim2.new(1, -14, 0, 21)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = value
    valueLabel.TextColor3 = COLORS.deepTeal
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 16
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = tile
    return valueLabel
end

local cashValue = makeStat("CashStat", "CASH", "$0", 0, COLORS.green, Color3.fromRGB(48, 112, 61))
local stockValue = makeStat("StockStat", "STOCK", "0", 0.342, COLORS.blue, COLORS.teal)
local salesValue = makeStat("SalesStat", "SALES", "0", 0.684, COLORS.gold, COLORS.coral)

local feedback = Instance.new("TextLabel")
feedback.Name = "Feedback"
feedback.Position = UDim2.fromOffset(0, 113)
feedback.Size = UDim2.new(1, 0, 0, 18)
feedback.BackgroundTransparency = 1
feedback.Text = ""
feedback.TextColor3 = COLORS.coral
feedback.Font = Enum.Font.GothamMedium
feedback.TextSize = 11
feedback.TextXAlignment = Enum.TextXAlignment.Left
feedback.TextYAlignment = Enum.TextYAlignment.Center
feedback.TextTruncate = Enum.TextTruncate.AtEnd
feedback.Parent = card

local teamPanel = Instance.new("Frame")
teamPanel.Name = "TeamPanel"
teamPanel.AnchorPoint = Vector2.new(0, 1)
teamPanel.Position = UDim2.new(0, 14, 1, -169)
teamPanel.Size = UDim2.fromOffset(300, 270)
teamPanel.BackgroundColor3 = COLORS.cream
teamPanel.BorderSizePixel = 0
teamPanel.Visible = false
teamPanel.Parent = gui
local teamPanelCorner = Instance.new("UICorner")
teamPanelCorner.CornerRadius = UDim.new(0, 12)
teamPanelCorner.Parent = teamPanel
local teamPanelStroke = Instance.new("UIStroke")
teamPanelStroke.Color = COLORS.teal
teamPanelStroke.Thickness = 2
teamPanelStroke.Parent = teamPanel
local teamHeading = Instance.new("TextLabel")
teamHeading.Size = UDim2.new(1, -64, 0, 30)
teamHeading.Position = UDim2.fromOffset(10, 7)
teamHeading.BackgroundTransparency = 1
teamHeading.Text = "STORE TEAM"
teamHeading.TextColor3 = COLORS.teal
teamHeading.Font = Enum.Font.GothamBold
teamHeading.TextSize = 15
teamHeading.TextXAlignment = Enum.TextXAlignment.Left
teamHeading.Parent = teamPanel
local teamClose = Instance.new("TextButton")
teamClose.Name = "CloseTeam"
teamClose.AnchorPoint = Vector2.new(1, 0)
teamClose.Position = UDim2.new(1, -6, 0, 4)
teamClose.Size = UDim2.fromOffset(44, 40)
teamClose.BackgroundColor3 = COLORS.teal
teamClose.TextColor3 = COLORS.cream
teamClose.Text = "X"
teamClose.Font = Enum.Font.GothamBold
teamClose.TextSize = 14
teamClose.Parent = teamPanel
local teamCloseCorner = Instance.new("UICorner")
teamCloseCorner.CornerRadius = UDim.new(0, 6)
teamCloseCorner.Parent = teamClose
local teamScroll = Instance.new("ScrollingFrame")
teamScroll.Name = "TeamList"
teamScroll.Position = UDim2.fromOffset(8, 50)
teamScroll.Size = UDim2.new(1, -16, 1, -58)
teamScroll.BackgroundTransparency = 1
teamScroll.BorderSizePixel = 0
teamScroll.ScrollBarThickness = 5
teamScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
teamScroll.CanvasSize = UDim2.new()
teamScroll.Parent = teamPanel
local teamLayout = Instance.new("UIListLayout")
teamLayout.Padding = UDim.new(0, 5)
teamLayout.SortOrder = Enum.SortOrder.LayoutOrder
teamLayout.Parent = teamScroll

local function clearTeamRows()
    for _, child in ipairs(teamScroll:GetChildren()) do
        if child ~= teamLayout then
            child:Destroy()
        end
    end
end

local function addTeamLabel(text, height)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, height or 32)
    label.BackgroundColor3 = COLORS.blue
    label.TextColor3 = COLORS.deepTeal
    label.Text = text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextWrapped = true
    label.Parent = teamScroll
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = label
    return label
end

local function addTeamButton(parent, text, width, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, width, 1, -4)
    button.BackgroundColor3 = COLORS.teal
    button.TextColor3 = COLORS.cream
    button.Text = text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button.TextWrapped = true
    button.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button
    button.Activated:Connect(callback)
    return button
end

local teamData
local function renderTeam(data)
    teamData = data
    clearTeamRows()
    if not data then
        addTeamLabel("Loading store membership…", 38)
        return
    end
    if data.ownRole == "Owner" then
        addTeamLabel("You own this store. Assign manager, cashier, stocker or maintenance.", 38)
        local contentWidth = math.max(220, teamScroll.AbsoluteSize.X - 4)
        local columns = contentWidth < 280 and 3 or 5
        local roleButtonWidth = math.floor((contentWidth - 8 - (columns - 1) * 4) / columns)
        local roleButtonHeight = UserInputService.TouchEnabled and 40 or 34
        local roleButtonSpacing = roleButtonWidth + 4
        for _, request in ipairs(data.requests or {}) do
            local row = Instance.new("Frame")
            local roleRows = math.ceil(5 / columns)
            row.Size = UDim2.new(1, -4, 0, 26 + roleRows * (roleButtonHeight + 4))
            row.BackgroundColor3 = COLORS.gold
            row.Parent = teamScroll
            local name = Instance.new("TextLabel")
            name.Size = UDim2.new(1, -8, 0, 20)
            name.Position = UDim2.fromOffset(4, 1)
            name.BackgroundTransparency = 1
            name.Text = request.name .. " wants to help"
            name.TextColor3 = COLORS.deepTeal
            name.Font = Enum.Font.GothamBold
            name.TextSize = 11
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = row
            local roles = { "Cashier", "Stocker", "Maintenance", "Manager", "Decline" }
            for index, role in ipairs(roles) do
                local roleButton = addTeamButton(row, role, roleButtonWidth, function()
                    if role == "Decline" then
                        memberActionEvent:FireServer("decline", request.userId)
                    else
                        memberActionEvent:FireServer("approve", request.userId, role)
                    end
                end)
                local column = (index - 1) % columns
                local roleRow = math.floor((index - 1) / columns)
                roleButton.Size = UDim2.fromOffset(roleButtonWidth, roleButtonHeight)
                roleButton.Position = UDim2.new(
                    0,
                    4 + column * roleButtonSpacing,
                    0,
                    24 + roleRow * (roleButtonHeight + 4)
                )
            end
        end
        for _, member in ipairs(data.members or {}) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -4, 0, 46)
            row.BackgroundColor3 = COLORS.blue
            row.Parent = teamScroll
            local name = Instance.new("TextLabel")
            name.Size = UDim2.new(1, -74, 1, 0)
            name.Position = UDim2.fromOffset(6, 0)
            name.BackgroundTransparency = 1
            name.Text = member.name .. " · " .. member.role
            name.TextColor3 = COLORS.deepTeal
            name.Font = Enum.Font.GothamSemibold
            name.TextSize = 11
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = row
            local removeButton = addTeamButton(row, "REMOVE", 74, function()
                memberActionEvent:FireServer("remove", member.userId)
            end)
            removeButton.Size = UDim2.fromOffset(74, 40)
            removeButton.Position = UDim2.new(1, -78, 0, 3)
        end
    elseif data.ownRole == "Visitor" then
        addTeamLabel(data.ownerName .. " owns this store. Request a role to help with the shift.", 62)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -4, 0, 48)
        row.BackgroundTransparency = 1
        row.Parent = teamScroll
        local requestButton = addTeamButton(
            row,
            data.requestPending and "REQUEST SENT" or "REQUEST TO HELP",
            170,
            function()
            joinRequestEvent:FireServer()
            end
        )
        requestButton.Size = UDim2.fromOffset(170, 44)
        requestButton.Position = UDim2.fromOffset(0, 2)
        requestButton.Active = not data.requestPending
        requestButton.AutoButtonColor = not data.requestPending
        for _, member in ipairs(data.members or {}) do
            addTeamLabel(member.name .. " · " .. member.role, 30)
        end
    else
        addTeamLabel("You are helping " .. data.ownerName .. " as " .. tostring(data.ownRole) .. ".", 48)
        for _, member in ipairs(data.members or {}) do
            addTeamLabel(member.name .. " · " .. member.role, 30)
        end
    end
end

teamToggle.Activated:Connect(function()
    teamPanel.Visible = not teamPanel.Visible
    if teamPanel.Visible then
        renderTeam(teamData)
    end
end)
teamClose.Activated:Connect(function()
    teamPanel.Visible = false
end)
memberStateEvent.OnClientEvent:Connect(renderTeam)

local collapsed = false
local ownerView = true
local function setCollapsed(value)
    collapsed = value
    objective.Visible = not collapsed
    stats.Visible = not collapsed and ownerView
    feedback.Visible = not collapsed
    card.Size = UDim2.fromOffset(280, collapsed and 40 or 145)
    toggle.Text = collapsed and "+" or "−"
end

toggle.Activated:Connect(function()
    setCollapsed(not collapsed)
end)

local function applyResponsiveLayout()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize
    if not viewport then
        return
    end

    local cardWidth = math.max(220, math.min(280, viewport.X - 24))
    sizeConstraint.MinSize = Vector2.new(math.min(235, cardWidth), 40)
    sizeConstraint.MaxSize = Vector2.new(cardWidth, 145)
    if UserInputService.TouchEnabled then
        teamToggle.Size = UDim2.fromOffset(48, 32)
        teamToggle.Position = UDim2.new(1, -27, 0, 4)
        card.AnchorPoint = Vector2.new(0.5, 0)
        card.Position = UDim2.new(0.5, 0, 0, 8)
        teamPanel.AnchorPoint = Vector2.new(0.5, 0.5)
        teamPanel.Position = UDim2.new(0.5, 0, 0.52, 0)
        teamPanel.Size = UDim2.fromOffset(
            math.max(220, math.min(300, viewport.X - 24)),
            math.max(220, math.min(340, viewport.Y - 130))
        )
        if not collapsed then
            setCollapsed(true)
        end
    else
        teamToggle.Size = UDim2.fromOffset(43, 22)
        teamToggle.Position = UDim2.new(1, -27, 0, 0)
        card.AnchorPoint = Vector2.new(0, 1)
        card.Position = UDim2.new(0, 14, 1, -14)
        teamPanel.AnchorPoint = Vector2.new(0, 1)
        teamPanel.Position = UDim2.new(0, 14, 1, -169)
        teamPanel.Size = UDim2.fromOffset(300, 270)
    end

    if teamPanel.Visible then
        renderTeam(teamData)
    end
end

local function watchCamera(camera)
    if camera then
        camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveLayout)
    end
    applyResponsiveLayout()
end

watchCamera(workspace.CurrentCamera)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    watchCamera(workspace.CurrentCamera)
end)

local messageRevision = 0
local function update(state)
    if typeof(state) ~= "table" then
        return
    end
    objective.Text = tostring(state.objective or "Keep the store running.")
    ownerView = state.hasStoreAccess == true or state.isOwner ~= false
    stats.Visible = not collapsed and ownerView
    local saveText = tostring(state.saveStatus or "loading")
    if saveText == "saved" then
        saveStatus.Text = "SAVE ON"
        saveStatus.TextColor3 = Color3.fromRGB(48, 112, 61)
    elseif saveText == "session only" then
        saveStatus.Text = "SESSION ONLY"
        saveStatus.TextColor3 = COLORS.coral
    elseif saveText == "save pending" then
        saveStatus.Text = "SAVE PENDING"
        saveStatus.TextColor3 = COLORS.coral
    elseif saveText == "lock lost" then
        saveStatus.Text = "SAVE LOCK LOST"
        saveStatus.TextColor3 = COLORS.coral
    elseif saveText == "view only" then
        saveStatus.Text = "VISITOR"
        saveStatus.TextColor3 = COLORS.teal
    else
        saveStatus.Text = "LOADING"
        saveStatus.TextColor3 = COLORS.teal
    end
    cashValue.Text = string.format("$%d", state.cash or 0)
    stockValue.Text = tostring(state.stock or 0)
    salesValue.Text = tostring(state.sales or 0)
    feedback.Text = tostring(state.message or "")
    messageRevision += 1
    local thisRevision = messageRevision
    if feedback.Text ~= "" then
        task.delay(5, function()
            if messageRevision == thisRevision then
                feedback.Text = ""
            end
        end)
    end
end

stateEvent.OnClientEvent:Connect(update)
