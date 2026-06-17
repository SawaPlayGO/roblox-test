local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local React = require(ReplicatedStorage.Packages.React)
local HotbarSlot = require(StarterPlayer.StarterPlayerScripts.Client.UI.Templates.Hotbar.HotbarSlot)
local ItemRegistry = require(ReplicatedStorage.Shared.ItemRegistry)

local SLOT_SIZE = 80
local SLOT_PADDING = 10

return function(props)
    local inventory = props.Inventory or {}
    local activeSlot = props.ActiveSlot or 1

    -- сортируем по номеру слота
    local slots = {}
    for _, entry in ipairs(inventory) do
        local data = ItemRegistry[entry.itemId]
        if data then
            table.insert(slots, {
                slot   = entry.slot,
                itemId = entry.itemId,
                name   = data.name,
                icon   = data.icon,
                count  = entry.count,
            })
        end
    end
    table.sort(slots, function(a, b) return a.slot < b.slot end)

    -- считаем размеры
    local slotCount = math.max(#slots, 1)
    local totalWidth = slotCount * SLOT_SIZE + (slotCount - 1) * SLOT_PADDING
    local screenWidth = workspace.CurrentCamera.ViewportSize.X * 0.95
    local scale = math.min(1, screenWidth / totalWidth)

    -- строим children
    local children = {
        Layout = React.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, SLOT_PADDING),
            SortOrder = Enum.SortOrder.Name,
        }),
        Scale = React.createElement("UIScale", {
            Scale = scale,
        }),
    }

    for _, item in ipairs(slots) do
        children[string.format("Slot_%02d", item.slot)] = React.createElement(HotbarSlot, {
            Index = item.slot,
            Item = item,
            IsActive = item.slot == activeSlot,
            OnClick = function()
                props.OnSlotClick(item.slot)
            end,
        })
    end

    return React.createElement("Frame", {
        Size = UDim2.fromOffset(totalWidth, SLOT_SIZE),
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -20),
        BackgroundTransparency = 1,
    }, children)
end