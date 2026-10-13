local Players = game:GetService("Players")

local ProfileService = require(script.Parent.ProfileService)
local WorldBuilder = require(script.Parent.WorldBuilder)

local BranchRuntimeService = {}

function BranchRuntimeService.create(stateEvent, sharedRemotes)
    local runtimes = {}

    local function openUptown(ownerPlayer)
        if not ownerPlayer or ownerPlayer.Parent ~= Players then
            return false
        end
        if runtimes[ownerPlayer.UserId] then
            return true
        end
        local profile = ProfileService.get(ownerPlayer)
        if not profile or not profile.locations or not profile.locations.uptown then
            return false
        end

        local sourceModule = script.Parent:WaitForChild("ShiftService")
        local runtimeModule = sourceModule:Clone()
        runtimeModule.Name = string.format("UptownShiftRuntime_%d", ownerPlayer.UserId)
        runtimeModule.Parent = script.Parent
        local runtime = require(runtimeModule)
        runtimes[ownerPlayer.UserId] = {
            module = runtimeModule,
            service = runtime,
        }
        runtime.init(stateEvent, sharedRemotes, {
            locationId = "uptown",
            ownerUserId = ownerPlayer.UserId,
            origin = WorldBuilder.UPTOWN_ORIGIN,
        })
        return true
    end

    return {
        openUptown = openUptown,
    }
end

return BranchRuntimeService
