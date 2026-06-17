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

return InventoryManager

