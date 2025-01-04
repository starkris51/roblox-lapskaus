--!strict
local player: Player = game:GetService("Players").LocalPlayer

type PlayerData = {
	Name: string,
	Age: number,
	IsAdmin: boolean,
}

local function onCharacterAdded(character: Model)
	print(character.Name)
end

player.CharacterAdded:Connect(onCharacterAdded)
