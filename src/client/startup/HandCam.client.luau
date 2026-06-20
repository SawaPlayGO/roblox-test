local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local sharedFolder   = ReplicatedStorage:WaitForChild("Shared")
local eventsFolder   = sharedFolder:WaitForChild("Events")
local equipSlot      = eventsFolder:WaitForChild("EquipSlot")
local ItemRegistry   = require(sharedFolder.ItemRegistry)
local modelsFolder   = ReplicatedStorage:WaitForChild("Models")

-- Берем модель рук из ReplicatedStorage и клонируем её на клиент
local viewmodelTemplate = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Hand")
local viewmodel = viewmodelTemplate:Clone()
local handAttachPart = viewmodel:FindFirstChild("LeftHand", true)
local towerAttachPart = viewmodel:FindFirstChild("TowerAttach", true)

local rootPart = viewmodel:FindFirstChild("LeftUpperArm") or viewmodel:FindFirstChildOfClass("BasePart")

if not rootPart then
	warn("Client ViewModel Error: В модели Hand не найдено деталей для фиксации!")
end

-- Физику Roblox отключаем, управляем вручную
for _, part in ipairs(viewmodel:GetDescendants()) do
	if part:IsA("BasePart") then
		part.CanCollide = false
		part.CastShadow = false
		part.Anchored   = true
	end
end

if rootPart then
	viewmodel.PrimaryPart = rootPart
end

viewmodel.Parent = camera

-- ─────────────────────────────────────────────────────────────────────
-- Настройки положения предмета. ВАЖНО: эти оффсеты применяются
-- от camera.CFrame напрямую (без rotationOffset руки!), поэтому
-- Right/Up/Forward совпадают с обычными осями камеры.
-- ─────────────────────────────────────────────────────────────────────
local ITEM_TARGET_SIZE =  10

local function scaleModelToFit(model, targetSize)
	local size = model:GetExtentsSize()
	local maxDimension = math.max(size.X, size.Y, size.Z)
	if maxDimension <= 0 then return end
	model:ScaleTo(targetSize / maxDimension)
end

local itemTowerFolder = nil
local towerItemOffsets = {} -- { {model = Model, heightOffset = number}, ... }

local function clearItemTower()
	if itemTowerFolder then
		itemTowerFolder:Destroy()
		itemTowerFolder = nil
	end
	towerItemOffsets = {}
end

local function buildItemTower(itemId, count)
	print("[Tower] buildItemTower вызван. itemId =", itemId, "| count =", count)
	clearItemTower()

	if not rootPart then
		warn("[Tower] СТОП: rootPart = nil, выход")
		return
	end

	local itemData = ItemRegistry[itemId]
	if not itemData then
		warn("[Tower] СТОП: ItemRegistry['" .. tostring(itemId) .. "'] = nil")
		print("[Tower] Все ключи в ItemRegistry:")
		for k, _ in pairs(ItemRegistry) do
			print("  ->", k)
		end
		return
	end
	print("[Tower] itemData найден. modelName =", itemData.modelName, "| holdSize =", itemData.holdSize)

	local templateModel = modelsFolder:FindFirstChild(itemData.modelName)
	if not templateModel then
		warn("[Tower] СТОП: modelsFolder:FindFirstChild('" .. tostring(itemData.modelName) .. "') = nil")
		print("[Tower] Все модели в modelsFolder:")
		for _, child in ipairs(modelsFolder:GetChildren()) do
			print("  ->", child.Name)
		end
		return
	end
	print("[Tower] templateModel найден:", templateModel.Name)

	itemTowerFolder        = Instance.new("Folder")
	itemTowerFolder.Name   = "ItemTowerVM"
	itemTowerFolder.Parent = camera
	print("[Tower] Папка ItemTowerVM создана, parent =", itemTowerFolder.Parent.Name)

	local heightOffset = 0

	for i = 1, count do
		print("[Tower] Клонируем предмет #" .. i)
		local itemClone = templateModel:Clone()
		itemClone:SetAttribute("isPickupItem", false)

		for _, part in ipairs(itemClone:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
				part.CanQuery   = false
				part.CastShadow = false
				part.Anchored   = true
				part.Massless   = true
			end
		end

		itemClone.Parent = itemTowerFolder

		local primaryPart = itemClone.PrimaryPart or itemClone:FindFirstChildWhichIsA("BasePart")
		if not primaryPart then
			warn("[Tower] Предмет #" .. i .. " не имеет BasePart, пропускаем")
			itemClone:Destroy()
			continue
		end
		print("[Tower] PrimaryPart предмета #" .. i .. " =", primaryPart.Name)

		local VM_SCALE = 0.3
		local holdSize = (itemData.holdSize or ITEM_TARGET_SIZE) * VM_SCALE
		print("[Tower] Масштабируем до holdSize =", holdSize)
		scaleModelToFit(itemClone, holdSize)

		local extents = itemClone:GetExtentsSize()
		print("[Tower] Размер после масштабирования:", extents)

		local sizeY = extents.Y
		local centerOffset = heightOffset + sizeY / 2
		table.insert(towerItemOffsets, { model = itemClone, heightOffset = centerOffset })
		print("[Tower] Предмет #" .. i .. " добавлен. centerOffset =", centerOffset)

		heightOffset += sizeY
	end
    if handAttachPart and rootPart then
        handToRootOffset = rootPart.CFrame:ToObjectSpace(handAttachPart.CFrame)
    end
end

-- Прячем серверную башню от собственной камеры (третье лицо → не видно себе)
local function hideRealTowerFromSelf(character)
	local function applyHide(folder)
		for _, part in ipairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 1
			end
		end
		folder.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 1
			end
		end)
	end

	local existing = character:FindFirstChild("HeldItemsTower")
	if existing then applyHide(existing) end

	character.ChildAdded:Connect(function(child)
		if child.Name == "HeldItemsTower" then
			applyHide(child)
		end
	end)
end

if player.Character then
	hideRealTowerFromSelf(player.Character)
end
player.CharacterAdded:Connect(hideRealTowerFromSelf)

-- Сервер шлёт: slotNumber, itemId, count (или nil, если снят)
equipSlot.OnClientEvent:Connect(function(slotNumber, itemId, count)
	print("[EquipSlot] Получено событие. slotNumber =", slotNumber, "| itemId =", itemId, "| count =", count)
	if not slotNumber or not itemId or not count then
		print("[EquipSlot] Один из параметров nil — очищаем башню")
		clearItemTower()
		return
	end
	buildItemTower(itemId, count)
end)

-- ─────────────────────────────────────────────────────────────────────
-- Настройки боббинга
-- ─────────────────────────────────────────────────────────────────────
local BOB_SPEED  = 12
local BOB_HEIGHT = 0.05
local BOB_WIDTH  = 0.04

local positionOffset = CFrame.new(1.85, -1.65, -1.9)
local rotationOffset = CFrame.Angles(math.rad(90), math.rad(15), math.rad(0))
local defaultOffset  = positionOffset * rotationOffset

local tickCount = 0
local lastBobbingCFrame = CFrame.new()

RunService.RenderStepped:Connect(function(deltaTime)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local charRoot  = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not charRoot then return end

	local speed    = charRoot.AssemblyLinearVelocity.Magnitude
	local isMoving = speed > 2 and humanoid.MoveDirection.Magnitude > 0

	local xBob, yBob = 0, 0

	if isMoving then
		tickCount   = tickCount + deltaTime * BOB_SPEED
		xBob  = math.sin(tickCount)     * BOB_WIDTH
		yBob  = math.cos(tickCount * 2) * BOB_HEIGHT
	else
		tickCount = 0
	end

	local bobbingCFrame = isMoving
		and CFrame.new(xBob, yBob, 0)
		or lastBobbingCFrame:Lerp(CFrame.new(), 0.1)

	lastBobbingCFrame = bobbingCFrame

	-- ── Рука (со своим техническим поворотом меша) ─────────────────────
	local targetCFrame = camera.CFrame * defaultOffset * bobbingCFrame

	if viewmodel.PrimaryPart then
		viewmodel:PivotTo(targetCFrame)
	else
		if not rootPart then return end
		local currentRootCFrame = rootPart.CFrame
		for _, part in ipairs(viewmodel:GetDescendants()) do
			if part:IsA("BasePart") then
				local rel = currentRootCFrame:ToObjectSpace(part.CFrame)
				part.CFrame = targetCFrame:ToWorldSpace(rel)
			end
		end
	end

	-- ── Башня предметов: позиция от camera.CFrame НАПРЯМУЮ ──────────────
	-- (без rotationOffset руки!), поэтому Right/Up/Forward не "слетают"
	-- при наклоне камеры. Поворот предметов — только yaw, без pitch/roll.
	if #towerItemOffsets > 0 then
		local attachPart = towerAttachPart or handAttachPart or rootPart

		-- Полный CFrame якоря — позиция И поворот, ничего не извлекаем
		local baseCFrame = attachPart.CFrame

		for _, entry in ipairs(towerItemOffsets) do
			if entry.model and entry.model.Parent then
				entry.model:PivotTo(baseCFrame * CFrame.new(0, entry.heightOffset, 0))
			end
		end
	end
end)