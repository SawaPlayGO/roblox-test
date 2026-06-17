local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRegistry = require(ReplicatedStorage.Shared.ItemRegistry)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Events = Shared:WaitForChild("Events")

local DropItem: RemoteEvent = Events:WaitForChild("DropItem")

local function _SpawnDroppedItem(player: Player, itemId: number, position: Vector3)
    local itemData = ItemRegistry[itemId]
    if not itemData then return end
    local templateModel = ReplicatedStorage:WaitForChild("Models"):WaitForChild(itemData.modelName)
    local droppedItem = templateModel:Clone()
    droppedItem.Name = "DroppedItem_" .. itemId
    droppedItem.Position = position

    local rootPart = player.Character
	local playerCFrame = rootPart.CFrame
	local forwardVector = playerCFrame.LookVector
	
	-- НАСТРОЙКИ:
	local distanceInFront = 5
	local heightOffset = 0
	
	local spawnCFrame = playerCFrame + (forwardVector * distanceInFront) + Vector3.new(0, heightOffset, 0)
	droppedItem:PivotTo(CFrame.new(spawnCFrame.Position) * playerCFrame.Rotation)
	droppedItem.Parent = workspace
end

DropItem.OnServerEvent:Connect(function(player: Player, slotNumber: number)
    print("Получен запрос на выброс предмета из слота:", slotNumber)
    -- Обращаемся к папке Inventory у игрока, затем к папке нужного слота
    local inventory = player:FindFirstChild("Inventory")
    if not inventory then
        warn("Inventory not found for player", player.Name)
        return
    end

    local slotName = tostring(slotNumber)
    local slotFolder = inventory:FindFirstChild("Slot_" .. slotName)
    if not slotFolder then
        warn("Slot folder not found:" .. " Slot_" ..  slotName)
        return
    end

    -- Также поддерживаем IntValue, который может хранить ID предмета
    local intVal = slotFolder:FindFirstChildWhichIsA("IntValue")
    if intVal then
        print("Найден IntValue в слоте:", slotName, "Value:", intVal.Value)
        local itemId = intVal.Value
        intVal:Destroy()
        _SpawnDroppedItem(player, itemId, slotFolder.Position)
        return
    end
end)