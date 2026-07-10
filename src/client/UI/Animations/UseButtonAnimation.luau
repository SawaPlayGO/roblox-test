local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

export type ButtonAnimationConfig = {
    hoverScale: number?,      -- множитель размера при наведении, например 1.05
    pressScale: number?,      -- множитель при нажатии, например 0.95
    hoverColor: Color3?,      -- цвет при наведении (опционально)
    baseColor: Color3?,       -- исходный цвет (нужен, если задан hoverColor)
    tweenTime: number?,       -- длительность анимации
    easingStyle: Enum.EasingStyle?,
}

local function useButtonAnimation(config: ButtonAnimationConfig)
    config = config or {}

    local ref = React.useRef(nil)
    local baseSize = React.useRef(nil) -- запоминаем исходный Size при первом рендере

    local hoverScale = config.hoverScale or 1.05
    local pressScale = config.pressScale or 0.95
    local tweenTime = config.tweenTime or 0.12
    local easingStyle = config.easingStyle or Enum.EasingStyle.Quad

    local function animate(scaleMultiplier: number)
        local button = ref.current
        if not button then return end

        if baseSize.current == nil then
            baseSize.current = button.size
        end

        local base = baseSize.current

        local targetSize = UDim2.new(
            base.X.Scale * scaleMultiplier, base.X.Offset * scaleMultiplier,
            base.Y.Scale * scaleMultiplier, base.Y.Offset * scaleMultiplier
        )

        local goals = {Size = targetSize}

        local tween = TweenService:Create(button, TweenInfo.new(
            tweenTime, easingStyle
        ), goals)
        tween:Play()
    end
    local handlers = {
        [React.Event.MouseEnter] = function()
            animate(hoverScale)
        end,
        [React.Event.MouseLeave] = function()
            animate(1)
        end,
        [React.Event.MouseButton1Down] = function()
            animate(pressScale)
        end,
        [React.Event.MouseButton1Up] = function()
            animate(hoverScale)
        end,
    }
    return ref, handlers
end

return useButtonAnimation