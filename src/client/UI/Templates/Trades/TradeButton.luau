local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TradeMenu = require(script.Parent.TradeMenu)
local React = require(ReplicatedStorage.Packages.React)

return function()
    local isMenuOpen, setIsMenuOpen = React.useState(false)
    local function onButtonClicked()
        setIsMenuOpen(not isMenuOpen) -- заставляет перерисовать экран
    end

    return React.createElement(React.Fragment, {}, {
        TradeButton = React.createElement("ImageButton", {
            Image = "rbxassetid://100744381633319",
            BackgroundTransparency = 1,
            
            -- Точка привязки в правом верхнем углу кнопки
            AnchorPoint = Vector2.new(1, 0),
            
            -- ИДЕАЛЬНОЕ ВЫРАВНИВАНИЕ:
            -- Offset X = -16 (делаем стандартный для Roblox отступ от правого края экрана)
            -- Offset Y = 11 (магическая цифра, центрирующая кнопку 36px внутри панели 58px)
            Position = UDim2.new(1, -16, 0, 11), 
            
            -- Стандартный размер оригинальных кнопок Roblox
            Size = UDim2.new(0, 45, 0, 45),
            
            ScaleType = Enum.ScaleType.Fit,
            [React.Event.Activated] = onButtonClicked,
        }, {
            AspectRatio = React.createElement("UIAspectRatioConstraint", {
                AspectRatio = 1,
            })
        }),
        TradeMenu = isMenuOpen and React.createElement(TradeMenu) or nil
    })
end