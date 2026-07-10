local SoundService = game:GetService("SoundService")

local SoundManager = {}
type SoundName = "ButtonClick" | "ButtonHover" | "Notification"

local sounds: { [SoundName]: string } = {
    ButtonClick = "rbxassetid://71171124719613",
}

function SoundManager.playSound(soundName: SoundName, volume: number)
    local soundId = sounds[soundName]
    if soundId then
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = volume
        sound.Parent = SoundService
        sound.PlayOnRemove = true
        sound.Parent = SoundService
        sound:Destroy()
    end
end

return SoundManager