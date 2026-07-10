local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UseButtonAnimation = require(StarterPlayer.StarterPlayerScripts.Client.UI.Animations.UseButtonAnimation)
local React = require(ReplicatedStorage.Packages.React)
local SoundManager = require(ReplicatedStorage.Shared.Managers.SoundManager)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Events = Shared:WaitForChild("Events")
local e = React.createElement

local RoundLeave: RemoteEvent = Events:WaitForChild("RoundLeave")

local Changed = Instance.new("BindableEvent")
local isVisibleValue = false

local function setVisible(value: boolean)
    isVisibleValue = value
    Changed:Fire(value)
end

local function Component()
    local isVisible, setLocalVisible = React.useState(isVisibleValue)
    local ref, handlers = UseButtonAnimation({
        hoverScale = 1.05,
        pressScale = 0.93,
        baseColor = Color3.fromHex("#FF3134"),
        hoverColor = Color3.fromHex("#FF5254"),
    })

    React.useEffect(function()
        local connection = Changed.Event:Connect(function(value)
            setLocalVisible(value)
        end)
        return function()
            connection:Disconnect()
        end
    end, {})

    return React.createElement("TextButton", {
        ref = ref,
        Text = "",
        BackgroundColor3 = Color3.fromHex("#FF3134"),
        Visible = isVisible,
        Position = UDim2.fromScale(0.5, 0.15),
        Size = UDim2.fromScale(0.15, 0.07),
        AnchorPoint = Vector2.new(0.5, 0.5),

        [React.Event.Activated] = function()
            SoundManager.playSound("ButtonClick", 1)
            RoundLeave:FireServer()
            setVisible(false)
        end,
        [React.Event.MouseEnter] = handlers[React.Event.MouseEnter],
        [React.Event.MouseLeave] = handlers[React.Event.MouseLeave],
        [React.Event.MouseButton1Down] = handlers[React.Event.MouseButton1Down],
        [React.Event.MouseButton1Up] = handlers[React.Event.MouseButton1Up],
    }, {
        UICorner = e("UICorner", {
            CornerRadius = UDim.new(0, 25)
        }),
        Stroke = e("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(0, 0, 0),
            Thickness = 2,
        }),
        FrameText = e("Frame", {
            Position = UDim2.fromScale(0.5, .5),
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(.9, .95),
            AnchorPoint = Vector2.new(0.5, 0.5),
        }, {
            Layout = e("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 0),
                SortOrder = Enum.SortOrder.Name
            }),
            TextLabel = e("TextLabel", {
                Text = "Exit",
                Font = Enum.Font.Roboto,
                TextColor3 = Color3.new(0, 0, 0),
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.fromScale(0.25, 0.4),
                TextScaled = true,
            }),
            ImageLabel = e("ImageLabel", {
                Image = "rbxassetid://75891751655062",
                Size = UDim2.fromScale(.5, .35),
                BackgroundTransparency = 1
            }, {
                AspectRatio = e("UIAspectRatioConstraint", {
                    AspectRatio = 1,
                    DominantAxis = Enum.DominantAxis.Height
                })
            })
        }),
    })
end

return {
    Component = Component,
    setVisible = setVisible,
}