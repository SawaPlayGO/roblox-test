local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")
local React = require(ReplicatedStorage.Packages.React)
local ClientState = require(StarterPlayer.StarterPlayerScripts.Client.ClientState)
local Hotbar = require(StarterPlayer.StarterPlayerScripts.Client.UI.Templates.Hotbar.Hotbar)

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
                    ClientState.activeSlot = slot
                    setActiveSlot(slot)
                end
            end
        end)
        return function()
            conn:Disconnect()
        end
    end, {inventory})

    -- Обработка колёсика мыши для переключения слотов
    React.useEffect(function()
        local conn = UserInputService.InputChanged:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.MouseWheel then
                local delta = input.Position.Z
                local slotCount = getSlotCount()
                print("Колёсико:", delta, "слотов:", slotCount)
                if delta > 0 then
                    -- Вперед
                    setActiveSlot(function(prev)
                        local next = prev + 1
                        if next > slotCount then
                            return 1
                        end
                        return next
                    end)
                    ClientState.activeSlot = activeSlot + 1
                else
                    -- Назад
                    setActiveSlot(function(prev)
                        local next = prev - 1
                        if next < 1 then
                            return slotCount
                        end
                        return next
                    end)
                    ClientState.activeSlot = activeSlot - 1
                end
            end
        end)
        return function()
            conn:Disconnect()
        end
    end, {inventory})

    return React.createElement(React.Fragment, {}, {
        Hotbar = React.createElement(Hotbar, {
            Inventory = inventory,
            ActiveSlot = activeSlot,
            OnSlotClick = setActiveSlot,
        }),
    })
end