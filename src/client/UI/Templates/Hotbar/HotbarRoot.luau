local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)
local InventoryManager = require(ReplicatedStorage.Shared.Managers.InventoryManager)
local ClientState = require(StarterPlayer.StarterPlayerScripts.Client.ClientState)
local Hotbar = require(StarterPlayer.StarterPlayerScripts.Client.UI.Templates.Hotbar.Hotbar)

local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local eventsFolder = sharedFolder:WaitForChild("Events")
local equipSlot = eventsFolder:WaitForChild("EquipSlot")


return function(props)
	local inventory = props.Inventory or {}
	local activeSlot, setActiveSlot = React.useState(1)

	-- Считаем реальное количество уникальных слотов
	local function getSlotCount()
		local stacks = {}
		for _, itemId in inventory do
			stacks[itemId] = true
		end
		local count = 0
		for _ in stacks do
			count = count + 1
		end
		return math.max(count, 1) -- Минимум 1 слот
	end

	-- ЭФФЕКТ: Проверяет валидность activeSlot при изменении инвентаря
	React.useEffect(function()
		-- Если инвентарь пуст или activeSlot не существует в инвентаре, сбросить на первый слот
		if #inventory == 0 then
			setActiveSlot(1)
		else
			local slotExists = false
			for _, entry in ipairs(inventory) do
				if entry.slot == activeSlot then
					slotExists = true
					break
				end
			end
			if not slotExists then
				-- Найти первый доступный слот
				local firstSlot = inventory[1] and inventory[1].slot or 1
				setActiveSlot(firstSlot)
			end
		end
	end, {inventory})

	-- ЭФФЕКТ: Срабатывает когда меняется activeSlot или inventory
	-- Он собирает CFrame смещения и мгновенно отправляет серверу
	React.useEffect(function()
		-- Вычисляем смещение локальной руки относительно серверного плеча
		local offset = InventoryManager.GetHandOffset()
		
		-- Отправляем запрос на сервер
		equipSlot:FireServer(activeSlot, offset)
		
		-- На всякий случай синхронизируем глобальный стейт клиента
		ClientState.activeSlot = activeSlot
	end, {activeSlot, inventory}) -- Зависимость на изменение слота или инвентаря

	-- Обработка горячих клавиш 1-9 и 0 для переключения слотов
	React.useEffect(function()
		local conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed then
				local keyCode = input.KeyCode
				local slotCount = getSlotCount()
				local slot = nil
				
				if keyCode == Enum.KeyCode.One then slot = 1
				elseif keyCode == Enum.KeyCode.Two then slot = 2
				elseif keyCode == Enum.KeyCode.Three then slot = 3
				elseif keyCode == Enum.KeyCode.Four then slot = 4
				elseif keyCode == Enum.KeyCode.Five then slot = 5
				elseif keyCode == Enum.KeyCode.Six then slot = 6
				elseif keyCode == Enum.KeyCode.Seven then slot = 7
				elseif keyCode == Enum.KeyCode.Eight then slot = 8
				elseif keyCode == Enum.KeyCode.Nine then slot = 9
				elseif keyCode == Enum.KeyCode.Zero then slot = 10
				end
				
				if slot and slot <= slotCount then
					setActiveSlot(slot)
				end
			end
		end)
		return function()
			conn:Disconnect()
		end
	end, {inventory})

	-- Обработка прокрутки колесика мыши
	React.useEffect(function()
		local conn = UserInputService.InputChanged:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			if input.UserInputType ~= Enum.UserInputType.MouseWheel then return end
			
			local delta = input.Position.Z
			
			setActiveSlot(function(prev)
				local slotCount = getSlotCount()
				if slotCount <= 0 then return prev end
				
				local newSlot = prev
				if delta > 0 then
					newSlot = (prev <= 1) and slotCount or (prev - 1)
				else
					newSlot = (prev >= slotCount) and 1 or (prev + 1)
				end
				
				return newSlot
			end)
		end)
		
		return function()
			conn:Disconnect()
		end
	end, {inventory})

	return React.createElement(React.Fragment, {}, {
		Hotbar = React.createElement(Hotbar, {
			Inventory = inventory,
			ActiveSlot = activeSlot,
			OnSlotClick = setActiveSlot, -- Клик по UI тоже вызовет обновление activeSlot и стриггерит эффект
		}),
	})
end