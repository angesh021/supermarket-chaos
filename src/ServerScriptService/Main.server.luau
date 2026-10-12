local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modules = script.Parent:WaitForChild("Modules")
local ShiftService = require(modules:WaitForChild("ShiftService"))

local network = ReplicatedStorage:FindFirstChild("SupermarketChaosNetwork")
if not network then
    network = Instance.new("Folder")
    network.Name = "SupermarketChaosNetwork"
    network.Parent = ReplicatedStorage
end

local stateEvent = network:FindFirstChild("ShiftState")
if not stateEvent then
    stateEvent = Instance.new("RemoteEvent")
    stateEvent.Name = "ShiftState"
    stateEvent.Parent = network
end

ShiftService.init(stateEvent)
