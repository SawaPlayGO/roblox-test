local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- 1. Берем модель рук из ReplicatedStorage и клонируем её на клиент
local viewmodelTemplate = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Hand")
local viewmodel = viewmodelTemplate:Clone()

-- Находим корневую деталь для позиционирования (плечо)
local rootPart = viewmodel:FindFirstChild("LeftUpperArm") or viewmodel:FindFirstChildOfClass("BasePart")

if not rootPart then
	warn("Client ViewModel Error: В модели Hand не найдено деталей для фиксации!")
end

-- Жестко свариваем всю структуру кодом, чтобы она двигалась как монолитный объект
for _, part in ipairs(viewmodel:GetDescendants()) do
	if part:IsA("BasePart") then
		part.CanCollide = false
		part.CastShadow = false
		part.Anchored = true -- Отключаем физику Roblox, берем управление на себя
	end
end

viewmodel.Parent = camera -- Помещаем руку внутрь камеры

-- 2. НАСТРОЙКИ КАЧАНИЯ (BOBBING)
local BOB_SPEED = 12       -- Скорость покачивания рук при ходьбе
local BOB_HEIGHT = 0.05    -- Амплитуда движения вверх-вниз
local BOB_WIDTH = 0.04     -- Амплитуда движения влево-вправо

local tickCount = 0

-- 3. ГЛАВНЫЙ ЦИКЛ ОБНОВЛЕНИЯ (Вызывается каждый кадр перед рендером)
RunService.RenderStepped:Connect(function(deltaTime)
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local charRoot = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not charRoot then return end

	-- Рассчитываем реальное движение игрока
	local speed = charRoot.AssemblyLinearVelocity.Magnitude
	local isMoving = speed > 2 and humanoid.MoveDirection.Magnitude > 0

	-- === ОБНОВЛЕННЫЕ НАСТРОЙКИ ПОЗИЦИИ ===
	-- X = 1.85 (Сдвинули еще дальше вправо, чтобы освободить центр экрана)
	-- Y = -1.65 (Опустили чуть пониже)
	-- Z = -1.9  (Сделали глубже! Было -2.5. Мы притянули руку ближе к камере, чтобы спрятать пустой срез плеча за экран)
	local positionOffset = CFrame.new(1.85, -1.65, -1.9)
	
	-- rotationOffset (оставляем твой рабочий поворот):
	local rotationOffset = CFrame.Angles(math.rad(90), math.rad(15), math.rad(0)) 
	
	local defaultOffset = positionOffset * rotationOffset
	local bobbingCFrame = CFrame.new()

	-- Логика эффекта шагов
	if isMoving then
		tickCount = tickCount + (deltaTime * BOB_SPEED)
		
		local xBob = math.sin(tickCount) * BOB_WIDTH
		local yBob = math.cos(tickCount * 2) * BOB_HEIGHT
		
		bobbingCFrame = CFrame.new(xBob, yBob, 0)
	else
		tickCount = 0
		bobbingCFrame = bobbingCFrame:Lerp(CFrame.new(), 0.1)
	end

	-- ПРИВЯЗКА К КАМЕРЕ
	local targetCFrame = camera.CFrame * defaultOffset * bobbingCFrame
	
	-- Сдвигаем всю модель
	if viewmodel.PrimaryPart then
		viewmodel:PivotTo(targetCFrame)
	else
		-- Безопасный режим: если PrimaryPart потерялся, сдвигаем через ручную матрицу плеча
		local currentRootCFrame = rootPart.CFrame
		for _, part in ipairs(viewmodel:GetDescendants()) do
			if part:IsA("BasePart") then
				local relativeCFrame = currentRootCFrame:ToObjectSpace(part.CFrame)
				part.CFrame = targetCFrame:ToWorldSpace(relativeCFrame)
			end
		end
	end
end)