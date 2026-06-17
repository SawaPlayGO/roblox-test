local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRegistry = require(ReplicatedStorage.Shared.ItemRegistry)
local InventoryManager = require(ReplicatedStorage.Shared.Managers.InventoryManager)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Events = Shared:WaitForChild("Events")

local DropItem: RemoteEvent = Events:WaitForChild("DropItem")

local function _SpawnDroppedItem(player: Player, itemId: number)
    local itemData = ItemRegistry[itemId]
    if not itemData then return end
    
    local templateModel = ReplicatedStorage:WaitForChild("Models"):WaitForChild(itemData.modelName)
    local droppedItem = templateModel:Clone()
    droppedItem.Name = itemData.modelName

    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- НАСТРОЙКИ:
    local distanceInFront = 5
    local heightOffset = 0
    
    -- Вычисляем CFrame перед игроком
    local playerCFrame = rootPart.CFrame
    local spawnCFrame = playerCFrame * CFrame.new(0, heightOffset, -distanceInFront)
    
    -- Перемещаем модель целиком
    droppedItem:PivotTo(spawnCFrame)
    droppedItem.Parent = workspace
end

local function _RemoveSlot(inventory: Folder, slotNumber: number): boolean
    local slot = inventory:FindFirstChild(tostring(slotNumber))
    if not slot then
        warn("Slot", slotNumber, "not found")
        return false
    end

    slot:Destroy()
    return true
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
    local slotFolder = inventory:FindFirstChild(slotName)
    if not slotFolder then
        warn("Slot folder not found: " ..  slotName)
        return
    end

    -- Также поддерживаем IntValue, который может хранить ID предмета
    local itemId: IntValue = slotFolder:FindFirstChild("ItemId")
    local count: IntValue = slotFolder:FindFirstChild("Count")
    if count.Value <= 0 then
        warn("No items left in slot:", slotName)
        return
    end
    if count.Value == 1 then
        -- Если это последний предмет в слоте, удаляем слот целиком
        if not _RemoveSlot(inventory, slotNumber) then
            warn("Failed to remove slot:", slotName)
            return
        end
    else
        count.Value -= 1
    end
    if itemId then
        print("Найден IntValue в слоте:", slotName, "Value:", itemId.Value)
        _SpawnDroppedItem(player, itemId.Value)
        InventoryManager.ReorganizeInventory(inventory)
        InventoryManager.SendInventoryToClient(player)
        return
    end
end)