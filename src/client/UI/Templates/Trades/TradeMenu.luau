local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

return function()
    return React.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromScale(0.4, 0.3),
        BackgroundColor3 = Color3.fromRGB(183, 36, 36),
        BorderSizePixel = 0,
    })
end