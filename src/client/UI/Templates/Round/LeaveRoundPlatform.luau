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
    local refPlayButton, handlersPlayButton = UseButtonAnimation({
        hoverScale = 1.05,
        pressScale = 0.93,
    })

    local refExitButton, handlersExitButton = UseButtonAnimation({
        hoverScale = 1.05,
        pressScale = 0.93,
    })

    React.useEffect(function()
        local connection = Changed.Event:Connect(function(value)
            setLocalVisible(value)
        end)
        return function()
            connection:Disconnect()
        end
    end, {})

    React.createElement("TextButton", {
        Text = "",
        BackgroundColor3 = Color3.fromHex("#FF3134"),
        Visible = isVisible,
    })

    return React.createElement("Frame", {
        Visible = isVisible,
        Position = UDim2.fromScale(0.5, 0.15),
        Size = UDim2.fromScale(0.15, 0.065),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
    }, {
        ButtonPlay = React.createElement("TextButton", {
            ref = refPlayButton,
            Text = "",
            BackgroundColor3 = Color3.fromHex("#31ff4c"),
            Size = UDim2.fromScale(.3, 1),

            [React.Event.Activated] = function()
                SoundManager.playSound("ButtonClick", 1)
                RoundLeave:FireServer()
                setVisible(false)
            end,
            [React.Event.MouseEnter] = handlersPlayButton[React.Event.MouseEnter],
            [React.Event.MouseLeave] = handlersPlayButton[React.Event.MouseLeave],
            [React.Event.MouseButton1Down] = handlersPlayButton[React.Event.MouseButton1Down],
            [React.Event.MouseButton1Up] = handlersPlayButton[React.Event.MouseButton1Up],
        }, {
            UICorner = e("UICorner", {
                CornerRadius = UDim.new(0, 25)
            }),
            Stroke = e("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Color3.fromRGB(0, 0, 0),
                Thickness = 1.5,
            }),
            FrameText = e("Frame", {
                Position = UDim2.fromScale(0.5, .5),
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(.9, .95),
                AnchorPoint = Vector2.new(0.5, 0.5),
            }, {
                PlayIcon = e("ImageLabel", {
                    Image = "rbxassetid://92939030534399",
                    Size = UDim2.fromScale(.5, .35),
                    Position = UDim2.fromScale(.5, .5),
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(.5, .5)
                }, {
                    AspectRatio = e("UIAspectRatioConstraint", {
                        AspectRatio = 1,
                        DominantAxis = Enum.DominantAxis.Height
                    })
                })
            }),
        }),
        Layout = e("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(.06, 0),
            SortOrder = Enum.SortOrder.Name
        }),
        ButtonExit = React.createElement("TextButton", {
            ref = refExitButton,
            Text = "",
            BackgroundColor3 = Color3.fromHex("#FF3134"),
            Size = UDim2.fromScale(1, 1),

            [React.Event.Activated] = function()
                SoundManager.playSound("ButtonClick", 1)
                RoundLeave:FireServer()
                setVisible(false)
            end,
            [React.Event.MouseEnter] = handlersExitButton[React.Event.MouseEnter],
            [React.Event.MouseLeave] = handlersExitButton[React.Event.MouseLeave],
            [React.Event.MouseButton1Down] = handlersExitButton[React.Event.MouseButton1Down],
            [React.Event.MouseButton1Up] = handlersExitButton[React.Event.MouseButton1Up],
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
        }),
    })
end

return {
    Component = Component,
    setVisible = setVisible,
}