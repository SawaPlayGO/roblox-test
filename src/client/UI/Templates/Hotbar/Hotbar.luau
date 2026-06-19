local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local React = require(ReplicatedStorage.Packages.React)
local HotbarSlot = require(StarterPlayer.StarterPlayerScripts.Client.UI.Templates.Hotbar.HotbarSlot)
local ItemRegistry = require(ReplicatedStorage.Shared.ItemRegistry)

local equipSlot: RemoteEvent = ReplicatedStorage:FindFirstChild("Shared"):FindFirstChild("Events"):FindFirstChild("EquipSlot")

local SLOT_SIZE = 80
local SLOT_PADDING = 10

local function AnimatedSlot(props)
    -- Изначально масштаб всегда 1.0
    local scaleBinding, setScale = React.useBinding(1.0)

    React.useEffect(function()
        -- Анимация срабатывает ТОЛЬКО когда слот становится активным (true)
        if props.IsActive then
            local numberValue = Instance.new("NumberValue")
            numberValue.Value = 1.0
            
            local connection = numberValue.Changed:Connect(function(latestValue)
                setScale(latestValue)
            end)
            
            -- Настройка "пульса":
            local tweenInfo = TweenInfo.new(
                0.12,                      -- Время увеличения (очень быстро)
                Enum.EasingStyle.Quad,     -- Плавный стиль
                Enum.EasingDirection.Out,  -- Затухание к пику
                0,                         -- Кол-во повторов (0 = сыграть 1 раз)
                true,                      -- REVERSES = TRUE! Автоматически уменьшает назад к 1.0
                0                          -- Задержка
            )
            
            -- Увеличиваем до 1.25 (на 25%) и благодаря Reverses возвращаем в 1.0
            local tween = TweenService:Create(numberValue, tweenInfo, {Value = 1.25})
            tween:Play()
            
            return function()
                tween:Cancel()
                connection:Disconnect()
                numberValue:Destroy()
            end
        else
            -- Если слот стал неактивным, просто держим его базовый размер
            setScale(1.0)
        end
    end, {props.IsActive})

    -- Контейнер ЖЕСТКО зафиксирован на 80x80. UIListLayout больше никогда не дернется.
    return React.createElement("Frame", {
        Size = UDim2.fromOffset(SLOT_SIZE, SLOT_SIZE),
        BackgroundTransparency = 1,
    }, {
        AnimatedContainer = React.createElement("Frame", {
            Size = UDim2.fromScale(1, 1),
            AnchorPoint = Vector2.new(0.5, 0.5), -- Центрирование, чтобы расширялся во все стороны равномерно
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 1,
        }, {
            Scale = React.createElement("UIScale", {
                Scale = scaleBinding,
            }),
            ActualSlot = React.createElement(HotbarSlot, props)
        })
    })
end


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
        children[string.format("Slot_%02d", item.slot)] = React.createElement(AnimatedSlot, {
            Index = item.slot,
            Item = item,
            IsActive = item.slot == activeSlot,
            Transparency = 0.5,
            OnClick = function()
                props.OnSlotClick(item.slot)
                equipSlot:FireServer(item.slot)
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