local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService") -- Добавили сервис для работы с кадрами
local Highlight = require(script.Parent.Highlight)

local pickupEvent: RemoteEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("pickupEvent")
local inventoryUpdated: RemoteEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("InventoryUpdated")

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

-- НАСТРОЙКА: Максимальная дистанция подбора предмета в студах
local MAX_DISTANCE = 15

-- Глобальные переменные состояния подсветки
isHovering = false
lastTarget = nil

-- Настройка параметров луча (чтобы луч игнорировал персонажа самого игрока)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function updateRaycastFilter(char)
	if char then
		raycastParams.FilterDescendantsInstances = {char}
	end
end

player.CharacterAdded:Connect(updateRaycastFilter)
updateRaycastFilter(player.Character)

-- Обработка нажатия кнопки E
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed then
		if input.KeyCode == Enum.KeyCode.E then
			print("E нажата, isHovering:", isHovering, "lastTarget:", lastTarget)
			if isHovering and lastTarget then
				print("Отправляем на сервер запрос подбора:", lastTarget.Name)
				pickupEvent:FireServer(lastTarget)
				
				-- БАГФИКС: Мгновенно гасим подсветку и обнуляем цель, так как предмет сейчас исчезнет
				Highlight.removeHighlight(lastTarget)
				isHovering = false
				lastTarget = nil
			end
		end
	end
end)

local function checkTargetInCenter()
	local cameraCFrame = camera.CFrame
	
	-- Пускаем луч из центра камеры строго вперед
	local raycastResult = workspace:Raycast(
		cameraCFrame.Position, 
		cameraCFrame.LookVector * MAX_DISTANCE, 
		raycastParams
	)

	-- Получаем объект, на который зафиксирован прицел
	local currentTarget = raycastResult and raycastResult.Instance

	-- Если цель изменилась, сдвинулась или старый предмет пропал
	if isHovering and lastTarget ~= currentTarget then
		if lastTarget then
			Highlight.removeHighlight(lastTarget)
		end
		isHovering = false
		lastTarget = nil
		print("Цель потеряна или изменилась, убираем подсветку")
	end

	-- Если перед прицелом находится валидный предмет для подбора
	if currentTarget and currentTarget:GetAttribute("isPickupItem") == true then
		if not isHovering then
			isHovering = true
			lastTarget = currentTarget
			Highlight.createHighlight(currentTarget)
			print("Авто-подсветка предмета в прицеле:", currentTarget.Name, "ItemId:", currentTarget:GetAttribute("ItemId"))
		end
	end
end

-- Привязываем проверку к обновлению кадров (работает даже без движения мыши)
RunService.RenderStepped:Connect(checkTargetInCenter)

inventoryUpdated.OnClientEvent:Connect(function(inventoryData)
	print("Клиент получил обновление инвентаря:", inventoryData)
end)