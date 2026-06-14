local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TradeButton = require(StarterPlayer.StarterPlayerScripts.Client.UI.Templates.Trades.TradeButton)
local React = require(ReplicatedStorage.Packages.React)
local _ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)


local function RootUI()
    return React.createElement(TradeButton)
end

return RootUI