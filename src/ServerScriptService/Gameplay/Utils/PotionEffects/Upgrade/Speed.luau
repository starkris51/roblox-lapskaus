--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Types.Global)

local function onApply(player: Player, level: number)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
	if humanoid then
		local baseSpeed = 16
		humanoid.WalkSpeed = baseSpeed * (1 + level * 0.25)
	end

	print(player.Name .. " got Speed level " .. level)
end

local function onRemove(player: Player)
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
		if humanoid then
			humanoid.WalkSpeed = 16
		end
	end
end

local Speed: Types.PotionType = {
	name = "Speed",
	category = "Upgrade",
	maxLevel = 3,
	onApply = onApply,
	onRemove = onRemove,
}

return Speed
