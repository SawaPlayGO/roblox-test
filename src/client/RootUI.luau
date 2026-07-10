local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local CrosshairCursor = require(StarterPlayer.StarterPlayerScripts.Client.UI.Templates.Crosshair.CrosshairCursor)
local HotbarRoot = require(StarterPlayer.StarterPlayerScripts.Client.UI.Templates.Hotbar.HotbarRoot)
local LeaveRoundPlatform = require(StarterPlayer.StarterPlayerScripts.Client.UI.Templates.Round.LeaveRoundPlatform)
local React = require(ReplicatedStorage.Packages.React)
local _ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local inventoryUpdated: RemoteEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("InventoryUpdated")

local function RootUI()
    local inventory, setInventory = React.useState({})

    React.useEffect(function()
        local conn = inventoryUpdated.OnClientEvent:Connect(function(data)
            setInventory(data)
        end)
        return function()
            conn:Disconnect()
        end
    end, {})

    return React.createElement(React.Fragment, {}, {
        Crosshair = React.createElement(CrosshairCursor, { Size = 8 }),
        LeaveRoundPlatform = React.createElement(LeaveRoundPlatform.Component),
        Hotbar = React.createElement(HotbarRoot, {
            Inventory = inventory,
        }),

    })
end

return RootUI