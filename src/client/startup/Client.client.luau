-- OFF Default backpack
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
local player = game:GetService("Players").LocalPlayer

-- 1st person camera
-- player.CameraMode = Enum.CameraMode.LockFirstPerson

-- Hide mouse cursor
-- game:GetService("UserInputService").MouseIconEnabled = false

-- load UI
local MountUI = require(script.Parent.MountUI)
MountUI()