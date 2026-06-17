local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

return function(props)
	local size = props.Size or 6
	local color = props.Color or Color3.fromRGB(255, 255, 255)

	return React.createElement("Frame", {
		-- Подставляем наш размер динамически
		Size = UDim2.fromOffset(size, size),
		
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		
		-- Подставляем наш цвет
		BackgroundColor3 = color,
		BorderSizePixel = 0,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(1, 0)
		})
	})
end