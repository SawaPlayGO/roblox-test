local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local LeaveRoundPlatform = require(StarterPlayer.StarterPlayerScripts.Client.UI.Templates.Round.LeaveRoundPlatform)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local e = React.createElement

return function(parent)
    local root = ReactRoblox.createRoot(parent)
    local app = e(LeaveRoundPlatform)
    root:render(app)

    return function()
        root:unmount()
    end
end