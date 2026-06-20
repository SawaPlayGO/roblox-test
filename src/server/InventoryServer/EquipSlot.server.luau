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

-- 🔧 Возвращает CFrame с позицией part, но без наклона по pitch/roll —
-- только горизонтальное направление (yaw). Благодаря этому башня всегда
-- стоит идеально вертикально и ровно относительно земли, даже если
-- HumanoidRootPart слегка "заваливается" (на лестницах, наклонных поверхностях,
-- во время некоторых анимаций и т.п.)
local function getLevelCFrame(part)
	local look = part.CFrame.LookVector
	local flatLook = Vector3.new(look.X, 0, look.Z)
	if flatLook.Magnitude < 0.001 then
		flatLook = Vector3.new(0, 0, -1)
	end
	flatLook = flatLook.Unit
	return CFrame.new(part.Position, part.Position + flatLook)
end

-- ПРИМЕЧАНИЕ: убрал параметр clientOffsetCFrame. В оригинале он принимался,
-- но даже не использовался в расчёте позиции — а доверять клиенту координаты
-- размещения предмета в принципе небезопасно (читер может прислать что угодно).
-- Позиция теперь полностью считается на сервере.
equipSlot.OnServerEvent:Connect(function(player, slotNumber)
	local character = player.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

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

	local towerFolder = Instance.new("Folder")
	towerFolder.Name = "HeldItemsTower"
	towerFolder:SetAttribute("OwnerUserId", player.UserId)
	towerFolder.Parent = character

	-- =====================================================================
	-- 🔧 НАСТРОЙКА ПОЗИЦИИ ОТНОСИТЕЛЬНО ТЕЛА ИГРОКА (HumanoidRootPart)
	-- X: Вправо (+) / Влево (-)
	-- Y: Вверх (+) / Вниз (-)
	-- Z: Назад (+) / Вперед (-)  (LookVector смотрит в -Z)
	--
	-- Увеличил вылет вперед (-2.2 вместо -1.4) и добавил смещение вправо,
	-- чтобы коробка не "влипала" в лицо/грудь, а смотрелась так,
	-- будто её держат на вытянутой правой руке.
	-- =====================================================================
	local moveForward = -2.2
	local moveRight = 0.7
	local moveUp = 0.1

	local rotX = 0
	local rotY = 180
	local rotZ = 0

	-- ВАЖНО: используем getLevelCFrame(rootPart), а НЕ rootPart.CFrame напрямую.
	-- Так башня всегда стоит ровно относительно земли.
	local baseCFrame = getLevelCFrame(rootPart)
		* CFrame.new(moveRight, moveUp, moveForward)
		* CFrame.Angles(math.rad(rotX), math.rad(rotY), math.rad(rotZ))

	-- ВАЖНО (ключевой фикс): первая коробка крепится через WeldConstraint
	-- к HumanoidRootPart, а НЕ к руке (RightHand), как было раньше.
	-- Раньше из-за крепления к руке вся башня "ехала" вслед за анимацией
	-- руки — анимация поднимала/двигала руку, и весь столбик коробок
	-- тащился за ней, отсюда кривое и слишком близкое к лицу положение
	-- на скрине. Теперь позиция полностью стабильна и зависит
	-- только от тела персонажа, а не от руки.
	local currentParentPart = rootPart
	local currentHeightOffset = 0

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

		local blockCFrame = baseCFrame * CFrame.new(0, currentHeightOffset + (sizeY / 2), 0)
		itemClone:PivotTo(blockCFrame)

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = currentParentPart
		weld.Part1 = primaryPart
		weld.Parent = primaryPart

		currentParentPart = primaryPart
		currentHeightOffset = currentHeightOffset + sizeY
	end

	-- Отдаём клиенту itemId и count, чтобы он мог построить такую же
	-- башню локально (вьюмодель от первого лица).
	equipSlot:FireClient(player, slotNumber, itemIdObj.Value, countObj.Value)
end)
