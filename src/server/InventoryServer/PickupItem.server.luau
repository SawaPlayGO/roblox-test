local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRegistry = require(ReplicatedStorage.Shared.ItemRegistry)
local InventoryManager = require(ReplicatedStorage.Shared.Managers.InventoryManager)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Events = Shared:WaitForChild("Events")

local pickupEvent: RemoteEvent = Events:WaitForChild("PickupEvent")

local function _CreateSlot(inventory: Folder, itemId: number): Folder?
    -- проверяем что слотов меньше 10
    local children = inventory:GetChildren()
    if #children >= 10 then
        warn("Inventory is full")
        return nil
    end

    -- находим первый свободный номер от 1 до 10
    local usedSlots = {}
    for _, child in ipairs(children) do
        usedSlots[tonumber(child.Name)] = true
    end

    local slotNumber = nil
    for i = 1, 10 do
        if not usedSlots[i] then
            slotNumber = i
            break
        end
    end

    -- создаём папку слота
    local slot = Instance.new("Folder")
    slot.Name = tostring(slotNumber)
    slot.Parent = inventory

    local itemIdValue = Instance.new("IntValue")
    itemIdValue.Name = "ItemId"
    itemIdValue.Value = itemId
    itemIdValue.Parent = slot

    local countValue = Instance.new("IntValue")
    countValue.Name = "Count"
    countValue.Value = 1
    countValue.Parent = slot

    return slot
end

local function _UpdateSlotCount(inventory: Folder, slotNumber: number, add: boolean): boolean
    local slot = inventory:FindFirstChild(tostring(slotNumber))
    if not slot then
        warn("Slot", slotNumber, "not found")
        return false
    end

    local countValue = slot:FindFirstChild("Count")
    if not countValue then
        warn("Count not found in slot", slotNumber)
        return false
    end

    if add then
        countValue.Value += 1
    else
        countValue.Value -= 1
    end

    return true
end

pickupEvent.OnServerEvent:Connect(function(player: Player, item: BasePart)
    print(`[Pickup] {player.Name} пытается подобрать {item and item.Name or "nil"}`)

    local character = player.Character
    local inventory = player:FindFirstChild("Inventory")

    if not item or not item.Parent then
        print("[Pickup] Предмет не существует или нет Parent")
        return
    end
    if not character then
        print("[Pickup] Нет персонажа")
        return
    end
    if not inventory then
        print("[Pickup] Нет инвентаря")
        return
    end

    local distance = (character.HumanoidRootPart.Position - item.Position).Magnitude
    if distance > 15 then
        print(`[Pickup] Слишком далеко: {distance}`)
        return
    end

    local itemId = item:GetAttribute("ItemId")
    if not itemId then
        print("[Pickup] У предмета нет атрибута ItemId")
        return
    end
    print(`[Pickup] ItemId: {itemId}`)

    local itemData = ItemRegistry[itemId]
    local targetSlot = nil

    for _, slot in ipairs(inventory:GetChildren()) do
        local slotItemId = slot:FindFirstChild("ItemId")
        local slotCount  = slot:FindFirstChild("Count")
        if slotItemId and slotCount then
            if slotItemId.Value == itemId and slotCount.Value < itemData.maxStack then
                targetSlot = tonumber(slot.Name)
                print(`[Pickup] Найден стак в слоте {targetSlot}, count: {slotCount.Value}/{itemData.maxStack}`)
                break
            end
        end
    end

    if targetSlot then
        print(`[Pickup] Добавляем в существующий слот {targetSlot}`)
        _UpdateSlotCount(inventory, targetSlot, true)
    else
        print("[Pickup] Создаём новый слот")
        if not _CreateSlot(inventory, itemId) then
            print("[Pickup] Инвентарь полон!")
            return
        end
    end

    item:Destroy()
    InventoryManager.ReorganizeInventory(inventory)
    InventoryManager.SendInventoryToClient(player)
end)

Players.PlayerAdded:Connect(function(player)
    local inventory = Instance.new("Folder")
    inventory.Name = "Inventory"
    inventory.Parent = player
end)