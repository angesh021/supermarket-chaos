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

-- Anchor the HUD at the upper-right so it stays clear of Roblox's left-side chat.
local card = Instance.new("Frame")
card.Name = "ObjectiveCard"
card.AnchorPoint = Vector2.new(1, 0)
card.Position = UDim2.new(1, -14, 0, 58)
card.Size = UDim2.new(0.44, 0, 0, 210)
card.BackgroundColor3 = COLORS.cream
card.BackgroundTransparency = 0.02
card.BorderSizePixel = 0
card.Parent = gui

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(250, 210)
sizeConstraint.MaxSize = Vector2.new(340, 210)
sizeConstraint.Parent = card

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = card

local stroke = Instance.new("UIStroke")
stroke.Color = COLORS.teal
stroke.Thickness = 2
stroke.Parent = card

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent = card

local function makeText(name, text, position, size, textColor, font, textSize)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Position = position
    label.Size = size
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = textColor
    label.Font = font
    label.TextSize = textSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextWrapped = true
    label.Parent = card
    return label
end

makeText(
    "Title",
    "YOUR FIRST SHIFT",
    UDim2.fromOffset(0, 0),
    UDim2.new(1, 0, 0, 24),
    COLORS.teal,
    Enum.Font.GothamBold,
    17
)

local objective = makeText(
    "Objective",
    "Loading your first task…",
    UDim2.fromOffset(0, 29),
    UDim2.new(1, 0, 0, 57),
    COLORS.ink,
    Enum.Font.GothamSemibold,
    16
)
objective.TextYAlignment = Enum.TextYAlignment.Top

local stats = Instance.new("Frame")
stats.Name = "Stats"
stats.Position = UDim2.fromOffset(0, 91)
stats.Size = UDim2.new(1, 0, 0, 62)
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
    tileCorner.CornerRadius = UDim.new(0, 9)
    tileCorner.Parent = tile
    local headingLabel = Instance.new("TextLabel")
    headingLabel.Name = "Heading"
    headingLabel.Position = UDim2.fromOffset(8, 5)
    headingLabel.Size = UDim2.new(1, -16, 0, 18)
    headingLabel.BackgroundTransparency = 1
    headingLabel.Text = heading
    headingLabel.TextColor3 = accent
    headingLabel.Font = Enum.Font.GothamBold
    headingLabel.TextSize = 11
    headingLabel.TextXAlignment = Enum.TextXAlignment.Left
    headingLabel.Parent = tile
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Position = UDim2.fromOffset(8, 23)
    valueLabel.Size = UDim2.new(1, -16, 0, 30)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = value
    valueLabel.TextColor3 = COLORS.deepTeal
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 19
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = tile
    return valueLabel
end

local cashValue = makeStat("CashStat", "CASH", "$0", 0, COLORS.green, Color3.fromRGB(48, 112, 61))
local stockValue = makeStat("StockStat", "STOCK", "0", 0.342, COLORS.blue, COLORS.teal)
local salesValue = makeStat("SalesStat", "SALES", "0", 0.684, COLORS.gold, COLORS.coral)

local feedback = makeText(
    "Feedback",
    "",
    UDim2.fromOffset(0, 160),
    UDim2.new(1, 0, 0, 38),
    COLORS.coral,
    Enum.Font.GothamMedium,
    13
)

local function update(state)
    if typeof(state) ~= "table" then
        return
    end
    objective.Text = tostring(state.objective or "Keep the store running.")
    cashValue.Text = string.format("$%d", state.cash or 0)
    stockValue.Text = tostring(state.stock or 0)
    salesValue.Text = tostring(state.sales or 0)
    feedback.Text = tostring(state.message or "")
end

stateEvent.OnClientEvent:Connect(update)
