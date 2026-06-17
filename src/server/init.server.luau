local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- создаём RemoteEvents при старте сервера
local pickupEvent = Instance.new("RemoteEvent")
pickupEvent.Name = "PickupItem"
pickupEvent.Parent = ReplicatedStorage

local updateEvent = Instance.new("RemoteEvent")
updateEvent.Name = "UpdateInventory"
updateEvent.Parent = ReplicatedStorage