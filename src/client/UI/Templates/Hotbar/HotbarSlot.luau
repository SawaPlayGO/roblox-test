local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

return function(props)
    local item = props.Item -- { name, icon, count, itemId }
    local isActive = props.IsActive or false
    local onClick = props.OnClick or function() end
    local transparency = props.Transparency or 0 -- 0 = opaque, 1 = fully transparent
    

    return React.createElement("Frame", {
        Size = UDim2.fromOffset(80, 80),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        BackgroundTransparency = transparency,
        BorderSizePixel = 0,
    }, {
        Corner = React.createElement("UICorner", {
            CornerRadius = UDim.new(0, 16),
        }),

        -- белая обводка если слот активен
        Stroke = React.createElement("UIStroke", {
            Enabled = isActive,
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 2,
            Transparency = transparency,
        }),

        -- иконка предмета
        Icon = React.createElement("ImageLabel", {
            Size = UDim2.fromScale(0.7, 0.55),
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.fromScale(0.5, 0.05),
            BackgroundTransparency = 1,
            Image = item and item.icon or "",
            ImageTransparency = transparency,
        }),

        -- название предмета (одна строка, без фона)
        ItemName = item and React.createElement("TextLabel", {
            Size = UDim2.new(1, -4, 0, 20),
            Position = UDim2.new(0.5, 0, 0.65, -10),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Text = item.name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 10,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextWrapped = false,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            BorderSizePixel = 0,
        }) or nil,

        -- количество
        Count = React.createElement("TextLabel", {
            Size = UDim2.new(0.45, 0, 0, 18),
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -10, 1, -2),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = (item and item.count > 1) and "x" .. tostring(item.count) or "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextYAlignment = Enum.TextYAlignment.Center,
        }),

        -- номер слота
        SlotNumber = React.createElement("TextLabel", {
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.fromOffset(6, 4),
            BackgroundTransparency = 1,
            Text = tostring(props.Index),
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextScaled = true,
        }),

        -- Clickable button для переключения слота
        ClickButton = React.createElement("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            [React.Event.Activated] = onClick,
        }),
    })
end