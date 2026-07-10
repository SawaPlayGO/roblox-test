local Players = game:GetService("Players")
local RoundPlatform = game.Workspace:WaitForChild("RoundPlatform") :: BasePart
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Events = Shared:WaitForChild("Events")

local RoundStart: RemoteEvent = Events:WaitForChild("RoundStart")
local RoundLeave: RemoteEvent = Events:WaitForChild("RoundLeave")


RoundPlatform.Touched:Connect(function(hit: BasePart)
    local character = hit.Parent
    if not character then return end
    local player: Player = Players:GetPlayerFromCharacter(character)
    if not player then return end

    local playerStart = RoundPlatform:FindFirstChild("PlayerStart")
    if not playerStart then return end

    if playerStart:FindFirstChild(player.Name) then return end
    local countSlots: number = RoundPlatform:GetAttribute("RoundCountSlots")
    local playersInPlatform = #playerStart:GetChildren()
    if playersInPlatform >= countSlots then return end

    local playerString = Instance.new("IntValue")
    playerString.Name = player.Name
    playerString.Value = 0
    playerString.Parent = playerStart

    RoundStart:FireClient(player, true)
end)

RoundLeave.OnServerEvent:Connect(function(player: Player)
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.CFrame = RoundPlatform.CFrame + Vector3.new(8, 3, 0)

    local playerStart: Folder = RoundPlatform:FindFirstChild("PlayerStart")
    if not playerStart then return end

    local playerString = playerStart:FindFirstChild(player.Name)
    if not playerString then return end
    playerString:Destroy()
    end
end)

-- RoundPlatform.TouchEnded:Connect(function(hit: BasePart)
--     local character = hit.Parent
--     if not character then return end
--     local player: Player = Players:GetPlayerFromCharacter(character)
--     if not player then return end

--     local playerStart: Folder = RoundPlatform:FindFirstChild("PlayerStart")
--     if not playerStart then return end

--     local playerString = playerStart:FindFirstChild(player.Name)
--     if not playerString then return end
--     playerString:Destroy()
-- end)