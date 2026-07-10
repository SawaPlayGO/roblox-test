local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Zombies = ReplicatedStorage:FindFirstChild("Models"):FindFirstChild("Zombies")
local workspace = game:GetService("Workspace")
local zombieWorkspace = workspace:FindFirstChild("ZombieWorkspace")

local ZombieManager = {}

function ZombieManager.spawnZombie(type: string, position: Vector3)
    local zombieModel = Zombies:FindFirstChild(type)

    if zombieModel then
        local newZombie = zombieModel:Clone()
        newZombie:PivotTo(CFrame.new(position))
        newZombie.Parent = zombieWorkspace
    end
end

return ZombieManager