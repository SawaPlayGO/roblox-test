
local function createHighlight(object: Instance): Highlight
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 255, 255)   -- Цвет заливки (оранжевый)
	highlight.FillTransparency = 0.6                     -- Прозрачность внутренности (слегка прозрачный)
	highlight.OutlineColor = Color3.fromRGB(0, 0, 0)  -- Цвет самого контура (яркий оранжевый)
	highlight.OutlineTransparency = 0                   -- Прозрачность контура (четкий, видимый)
	
	highlight.Parent = object
	return highlight
end

local function removeHighlight(object: Instance)
	-- Ищем объект класса Highlight внутри детали
	local highlight = object:FindFirstChildOfClass("Highlight")
	
	-- Если нашли — уничтожаем его
	if highlight then
		highlight:Destroy()
	end
end

return {
	createHighlight = createHighlight,
	removeHighlight = removeHighlight,
}