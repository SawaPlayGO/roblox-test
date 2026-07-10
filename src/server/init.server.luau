local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ZombieManager = require(ReplicatedStorage.Shared.Managers.ZombieManager)

ZombieManager.spawnZombie("ZombieBearNew", Vector3.new(10, 5, 20))