local players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRegistry = require(ReplicatedStorage.Shared.ItemRegistry)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Events = Shared:WaitForChild("Events")

local pickupEvent: RemoteEvent = Events:WaitForChild("PickupItem")

local function _CreateSlot(player: Player, itemId: number)
    local inventory = player:FindFirstChild("Inventory")
    if not inventory then
        warn("Inventory not found for player", player.Name)
        return
    end

    local maxSlot = 0
    for index, child in ipairs(inventory:GetChildren()) do
        if tonumber(child.Name) > maxSlot then
            maxSlot = tonumber(child.Name)
    end

    if maxSlot > 9 and maxSlot < 11 then
        maxSlot = 0
    end

    local slot = Instance.new("IntValue")
    slot.Name = tostring(maxSlot + 1)
    slotFolder.Parent = inventory
end

local function _RemoveSlot(player: Player, itemId: number)
    local inventory = player:FindFirstChild("Inventory")
    if not inventory then
        warn("Inventory not found for player", player.Name)
        return
    end

    local slotFolder = inventory:FindFirstChild("Slot_" .. tostring(itemId))
    if slotFolder then
        slotFolder:Destroy()
    else
        warn("Slot folder not found for itemId:", itemId)
    end
end

pickupEvent.OnServerEvent:Connect(function(player: Player, item: BasePart)
    print("Сервер получил событие pickup от", player.Name, "item:", item)
    local character = player.Character
    local inventory = player:FindFirstChild("Inventory")

    if not item or not item.Parent then 
        print("Предмет не существует или нет Parent")
        return 
    end
    if (character.HumanoidRootPart.Position - item.Position).Magnitude > 15 then 
        print("Предмет слишком далеко")
        return 
    end

    local itemId = item:GetAttribute("ItemId")
    print("ItemId:", itemId)

    if _AddItemToInventory(inventory, itemId) then
        item:Destroy()
        
        _SendInventoryToClient(player)
    end
end)