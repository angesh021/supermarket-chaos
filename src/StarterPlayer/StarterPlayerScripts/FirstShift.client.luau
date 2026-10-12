local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local network = ReplicatedStorage:WaitForChild("SupermarketChaosNetwork")
local stateEvent = network:WaitForChild("ShiftState")

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

-- Keep the compact HUD in the lower-left, away from chat and the player list.
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
title.Size = UDim2.new(1, -28, 0, 22)
title.BackgroundTransparency = 1
title.Text = "FIRST SHIFT"
title.TextColor3 = COLORS.teal
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = card

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

local collapsed = false
local function setCollapsed(value)
    collapsed = value
    objective.Visible = not collapsed
    stats.Visible = not collapsed
    feedback.Visible = not collapsed
    card.Size = UDim2.fromOffset(280, collapsed and 40 or 145)
    toggle.Text = collapsed and "+" or "−"
end

toggle.Activated:Connect(function()
    setCollapsed(not collapsed)
end)

local messageRevision = 0
local function update(state)
    if typeof(state) ~= "table" then
        return
    end
    objective.Text = tostring(state.objective or "Keep the store running.")
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
