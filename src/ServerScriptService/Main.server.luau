local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modules = script.Parent:WaitForChild("Modules")
local ShiftService = require(modules:WaitForChild("ShiftService"))
local BranchRuntimeService = require(modules:WaitForChild("BranchRuntimeService"))

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

local function remote(name, className)
    local result = network:FindFirstChild(name)
    if not result then
        result = Instance.new(className)
        result.Name = name
        result.Parent = network
    end
    return result
end

local sharedRemotes = {
    joinRequest = remote("JoinStoreRequest", "RemoteEvent"),
    memberAction = remote("StoreMemberAction", "RemoteEvent"),
    memberState = remote("StoreMemberState", "RemoteEvent"),
    layoutRequest = remote("WarehouseLayoutRequest", "RemoteEvent"),
    retailLayoutRequest = remote("RetailLayoutRequest", "RemoteEvent"),
}
local branchRuntime = BranchRuntimeService.create(stateEvent, sharedRemotes)

ShiftService.init(stateEvent, sharedRemotes, {
    locationId = "neighborhood",
    onUptownOpened = branchRuntime.openUptown,
})
