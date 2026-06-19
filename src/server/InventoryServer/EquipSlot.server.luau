local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[SERVER TOWER] Скрипт башни инициализирован: Стабильное позиционирование через HumanoidRootPart.")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local eventsFolder = sharedFolder:WaitForChild("Events")
local equipSlot = eventsFolder:WaitForChild("EquipSlot")

local ItemRegistry = require(sharedFolder.ItemRegistry)
local modelsFolder = ReplicatedStorage:WaitForChild("Models")

local holdAnimation = Instance.new("Animation")
holdAnimation.AnimationId = "rbxassetid://75401832038017"

local function makeModelSafe(model)
	model:SetAttribute("isPickupItem", false)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part:SetAttribute("isPickupItem", false)
			part.CanCollide = false
			part.Massless = true
			part.Anchored = false
		end
	end
end

local function setHandAnimation(character, shouldPlay, playerName)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then return end

	local alreadyPlayingTrack = nil
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		if track.Animation.AnimationId == holdAnimation.AnimationId then
			alreadyPlayingTrack = track
			break
		end
	end

	if shouldPlay then
		if alreadyPlayingTrack then return end
		local success, err = pcall(function()
			local track = animator:LoadAnimation(holdAnimation)
			track.Priority = Enum.AnimationPriority.Action
			track.Looped = true
			track:Play(0.1)
		end)
		if not success then
			warn(string.format("[SERVER TOWER ERROR] Ошибка анимации у %s: %s", playerName, tostring(err)))
		end
	else
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			if track.Animation.AnimationId == holdAnimation.AnimationId then
				track:Stop(0.15)
			end
		end
	end
end

local function clearCurrentTower(character)
	local oldTower = character:FindFirstChild("HeldItemsTower")
	if oldTower then oldTower:Destroy() end
end

equipSlot.OnServerEvent:Connect(function(player, slotNumber, clientOffsetCFrame)
	local character = player.Character
	if not character then return end
	
	local realHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not realHand or not rootPart then return end

	clearCurrentTower(character)

	if not slotNumber then 
		setHandAnimation(character, false, player.Name)
		equipSlot:FireClient(player, nil)
		return 
	end

	local inventory = player:FindFirstChild("Inventory")
	local slotFolder = inventory and inventory:FindFirstChild(tostring(slotNumber))
	if not slotFolder then 
		setHandAnimation(character, false, player.Name)
		equipSlot:FireClient(player, nil)
		return  
	end

	local itemIdObj = slotFolder:FindFirstChild("ItemId")
	local countObj = slotFolder:FindFirstChild("Count")
	if not itemIdObj or not countObj or countObj.Value <= 0 then 
		setHandAnimation(character, false, player.Name)
		equipSlot:FireClient(player, nil)
		return 
	end

	local itemData = ItemRegistry[itemIdObj.Value]
	local templateModel = itemData and modelsFolder:FindFirstChild(itemData.modelName)
	if not templateModel then 
		setHandAnimation(character, false, player.Name)
		equipSlot:FireClient(player, nil)
		return 
	end

	setHandAnimation(character, true, player.Name)

	-- Создаем контейнер башни
	local towerFolder = Instance.new("Folder")
	towerFolder.Name = "HeldItemsTower"
	towerFolder:SetAttribute("OwnerUserId", player.UserId)
	towerFolder.Parent = character

	local offset = clientOffsetCFrame or CFrame.new()
	local currentParentPart = realHand 
	local currentHeightOffset = 0

	-- =====================================================================
	-- 🔧 НАСТРОЙКА ПОЗИЦИИ ОТНОСИТЕЛЬНО ТЕЛА ИГРОКА (HumanoidRootPart)
	-- Оси здесь стабильны и не зависят от анимаций:
	-- X: Вправо (+) / Влево (-)
	-- Y: Вверх (+) / Вниз (-)
	-- Z: Назад (+) / Вперед (-)
	-- =====================================================================
	
	local moveForward = -1.4  -- Выталкиваем ВПЕРЕД перед грудью (отрицательное значение Z)
	local moveRight = 0.0     -- Центрируем коробку ровно посередине тела (0.0)
	local moveUp = 0.5        -- Поднимаем на уровень рук/груди от пояса (+)

	-- Вращение коробки: разворачиваем строго на 180 градусов по оси Y "от игрока"
	local rotX = 0
	local rotY = 180
	local rotZ = 0

	-- Вычисляем фиксированную мировую позицию первой коробки перед персонажем
	local baseCFrame = rootPart.CFrame 
		* CFrame.new(moveRight, moveUp, moveForward) 
		* CFrame.Angles(math.rad(rotX), math.rad(rotY), math.rad(rotZ))

	for i = 1, countObj.Value do
		local itemClone = templateModel:Clone()
		makeModelSafe(itemClone)
		itemClone.Parent = towerFolder

		local primaryPart = itemClone.PrimaryPart or itemClone:FindFirstChildWhichIsA("BasePart")
		if not primaryPart then 
			itemClone:Destroy()
			continue 
		end

		local sizeY = itemClone:GetExtentsSize().Y
		
		-- Выстраиваем блоки в мировых координатах четко друг на друга вверх
		local blockCFrame = baseCFrame * CFrame.new(0, currentHeightOffset + (sizeY / 2), 0)
		itemClone:PivotTo(blockCFrame)

		-- Создаем жесткую физическую связь (WeldConstraint)
		-- Она мгновенно зафиксирует текущее идеальное положение коробки относительно руки!
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = currentParentPart -- Первая коробка крепится к RightHand, остальные — цепочкой друг к другу
		weld.Part1 = primaryPart
		weld.Parent = primaryPart

		currentParentPart = primaryPart
		currentHeightOffset = currentHeightOffset + sizeY
	end

	-- Пингуем клиента
	equipSlot:FireClient(player, slotNumber)
end)