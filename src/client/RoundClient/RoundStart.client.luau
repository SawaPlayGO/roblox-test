local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local LeaveRoundPlatform = require(StarterPlayer.StarterPlayerScripts.Client.UI.Templates.Round.LeaveRoundPlatform)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Events = Shared:WaitForChild("Events")

local RoundStart: RemoteEvent = Events:WaitForChild("RoundStart")

RoundStart.OnClientEvent:Connect(function(isJoin: boolean)
    if not isJoin then end
    LeaveRoundPlatform.setVisible(isJoin)
end)


