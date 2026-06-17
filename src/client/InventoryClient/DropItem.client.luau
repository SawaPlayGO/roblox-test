local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")
local ClientState = require(StarterPlayer.StarterPlayerScripts.Client.ClientState)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Events = Shared:WaitForChild("Events")

local DropItem: RemoteEvent = Events:WaitForChild("DropItem")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed then
		if input.KeyCode == Enum.KeyCode.Q then
            local activeSlot = ClientState.activeSlot
            DropItem:FireServer(activeSlot)
        end
    end
end)