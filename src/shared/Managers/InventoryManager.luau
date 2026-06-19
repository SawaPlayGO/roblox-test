local Players = game:GetService("Players")
-- Внутри ModuleScript (InventoryManager)
local InventoryManager = {}

-- Добавляем функцию в таблицу
function InventoryManager.SendInventoryToClient(player: Player)
    local inventory = player:FindFirstChild("Inventory")
    if not inventory then return end

    local data = {}
    for _, slot in ipairs(inventory:GetChildren()) do
        local itemId = slot:FindFirstChild("ItemId")
        local count = slot:FindFirstChild("Count")
        if itemId and count then
            table.insert(data, {
                slot = tonumber(slot.Name),
                itemId = itemId.Value,
                count = count.Value,
            })
        end
    end
    
    local inventoryUpdated = game:GetService("ReplicatedStorage").Shared.Events.InventoryUpdated
    inventoryUpdated:FireClient(player, data)
end

function InventoryManager.ReorganizeInventory(inventory: Folder)
    local items = {}
    
    for _, slot in ipairs(inventory:GetChildren()) do
        local itemId = slot:FindFirstChild("ItemId")
        local count = slot:FindFirstChild("Count")
        if itemId and count then
            table.insert(items, {id = itemId.Value, count = count.Value})
            slot:Destroy()
        end
    end
    
    for i, itemData in ipairs(items) do
        local slot = Instance.new("Folder")
        slot.Name = tostring(i)
        slot.Parent = inventory
        
        local idVal = Instance.new("IntValue")
        idVal.Name = "ItemId"
        idVal.Value = itemData.id
        idVal.Parent = slot
        
        local countVal = Instance.new("IntValue")
        countVal.Name = "Count"
        countVal.Value = itemData.count
        countVal.Parent = slot
    end
end

function InventoryManager.GetHandOffset()
	local localPlayer = Players.LocalPlayer
	if not localPlayer then return CFrame.new() end -- Защита, если вызвано на сервере

	local character = localPlayer.Character
	if not character then return CFrame.new() end

	local realHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	local customHand = character:FindFirstChild("Hand") -- Твоя локальная рука из камеры

	-- Если какой-то из рук нет, возвращаем пустое смещение (башня заспавнится в дефолтном плече)
	if not realHand or not customHand then
		return CFrame.new()
	end

	-- Считаем и возвращаем разницу между реальным телом и твоей клиентской рукой
	return realHand.CFrame:ToObjectSpace(customHand.CFrame)
end

return InventoryManager

