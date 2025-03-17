--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Types.Global)

local function onApply(player: Player, level: number)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
	if humanoid then
		local baseJump = 50
		humanoid.JumpPower = baseJump * (1 + level * 0.30) -- 30% increase per level
	end

	print(player.Name .. " got Jump level " .. level)
end

local function onRemove(player: Player)
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
		if humanoid then
			humanoid.JumpPower = 50
		end
	end
end

local JumpPotion: Types.PotionType = {
	name = "Jump",
	category = "Upgrade",
	maxLevel = 3,
	onApply = onApply,
	onRemove = onRemove,
}

return JumpPotion
