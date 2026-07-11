local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")

local parent = workspace:WaitForChild("RoundPlatform") :: BasePart
local Dome = parent:WaitForChild("Dome")
local playerStart = parent:WaitForChild("PlayerStart")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Events = Shared:WaitForChild("Events")
local player = Players.LocalPlayer
local RoundLeave: RemoteEvent = Events:WaitForChild("RoundLeave")
local RoundStart: RemoteEvent = Events:WaitForChild("RoundStart")

isTeleporting = false

local function check()
	if playerStart:FindFirstChild(player.Name) then
		Dome.CanCollide = true
        if not isTeleporting then
            local roundPlatformPosition = parent.Position
            local positionTeleport = Vector3.new(roundPlatformPosition.X, roundPlatformPosition.Y+3, roundPlatformPosition.Z)
            RoundStart:FireServer(positionTeleport)
            isTeleporting = true
        end
	end
	task.delay(0.5, check)
end
check()

RoundLeave.OnClientEvent:Connect(function(player: Player)
	Dome.CanCollide = false
    isTeleporting = false
end)