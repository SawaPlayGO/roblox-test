local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local React = require(ReplicatedStorage.Packages.React)
local HotbarSlot = require(StarterPlayer.StarterPlayerScripts.Client.UI.Templates.Hotbar.HotbarSlot)
local ItemRegistry = require(ReplicatedStorage.Shared.ItemRegistry)

return function(props)
    local inventory = props.Inventory or {}
    local activeSlot = props.ActiveSlot or 1
    local onSlotClick = props.OnSlotClick or function() end

    -- собираем стаки: { [itemId] = count }
    local stacks = {}
    for _, itemId in inventory do
        stacks[itemId] = (stacks[itemId] or 0) + 1
    end

    -- уникальные слоты по порядку
    local slots = {}
    local seen = {}
    for _, itemId in inventory do
        if not seen[itemId] then
            seen[itemId] = true
            local data = ItemRegistry[itemId]
            table.insert(slots, {
                itemId = itemId,
                name = data.name,
                icon = data.icon,
                count = stacks[itemId],
            })
        end
    end

    -- строим children как словарь
    local children = {
        Layout = React.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 10),
        }),
    }

    for i, item in slots do
        children["Slot_" .. i] = React.createElement(HotbarSlot, {
            Index = i,
            Item = item,
            IsActive = i == activeSlot,
            OnClick = function()
                onSlotClick(i)
            end,
        })
    end

    -- Если инвентарь пуст, показываем пустой фрейм
    local frameSize = #slots > 0 and (#slots * 90) or 90

    return React.createElement("Frame", {
        Size = UDim2.new(0, frameSize, 0, 90),
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -20),
        BackgroundTransparency = 1,
    }, children)
end