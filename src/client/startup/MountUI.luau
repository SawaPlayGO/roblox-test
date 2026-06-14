local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local RootUI = require(StarterPlayer.StarterPlayerScripts.Client.RootUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

return function()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local container = Instance.new("ScreenGui")
    container.Name = "UI"
    container.IgnoreGuiInset = true
    container.ResetOnSpawn = false
    container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    container.ClipToDeviceSafeArea = false
    container.Parent = playerGui

    local root = ReactRoblox.createRoot(container)
    local app = React.createElement(RootUI)
    root:render(app)
end