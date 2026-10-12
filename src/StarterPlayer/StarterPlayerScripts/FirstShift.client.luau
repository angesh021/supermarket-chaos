local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local network = ReplicatedStorage:WaitForChild("SupermarketChaosNetwork")
local stateEvent = network:WaitForChild("ShiftState")

local gui = Instance.new("ScreenGui")
gui.Name = "FirstShiftHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 10
gui.Parent = playerGui

local card = Instance.new("Frame")
card.Name = "ObjectiveCard"
card.AnchorPoint = Vector2.new(0, 0)
card.Position = UDim2.fromOffset(20, 20)
card.Size = UDim2.new(0.38, 0, 0, 142)
card.BackgroundColor3 = Color3.fromRGB(249, 239, 216)
card.BackgroundTransparency = 0.04
card.BorderSizePixel = 0
card.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = card

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(22, 79, 82)
stroke.Thickness = 2
stroke.Parent = card

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 14)
padding.PaddingRight = UDim.new(0, 14)
padding.Parent = card

local function textLabel(name, y, height, color, font, size)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Position = UDim2.fromOffset(0, y)
    label.Size = UDim2.new(1, 0, 0, height)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.Font = font
    label.TextSize = size
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextWrapped = true
    label.Parent = card
    return label
end

local title = textLabel("Title", 0, 24, Color3.fromRGB(22, 79, 82), Enum.Font.GothamBold, 18)
title.Text = "FIRST SHIFT  •  WELCOME TO CHAOS"

local objective =
    textLabel("Objective", 29, 57, Color3.fromRGB(48, 57, 54), Enum.Font.GothamMedium, 17)
objective.Text = "Loading your first task…"

local status = textLabel("Status", 89, 27, Color3.fromRGB(17, 57, 61), Enum.Font.GothamBold, 16)
status.Text = "$0   •   Stock: 0   •   Sales: 0"

local feedback =
    textLabel("Feedback", 116, 26, Color3.fromRGB(174, 88, 76), Enum.Font.GothamMedium, 14)
feedback.Text = ""

local function update(state)
    if typeof(state) ~= "table" then
        return
    end
    objective.Text = tostring(state.objective or "Keep the store running.")
    status.Text = string.format(
        "$%d   •   Stock: %d   •   Sales: %d",
        state.cash or 0,
        state.stock or 0,
        state.sales or 0
    )
    feedback.Text = tostring(state.message or "")
    card.Size = UDim2.new(0.38, 0, 0, feedback.Text == "" and 116 or 142)
end

stateEvent.OnClientEvent:Connect(update)
