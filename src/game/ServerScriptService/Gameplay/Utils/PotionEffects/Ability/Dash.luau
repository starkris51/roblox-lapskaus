--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Types.Global)

local function onApply(player: Player, level: number)
	-- Apply dash ability (would be implemented in client-side script)
	print(player.Name .. " got Dash ability")
end

local function onRemove(player: Player)
	-- Remove dash ability (would be implemented in client-side script)
end

local Dash: Types.PotionType = {
	name = "Dash",
	category = "Ability",
	maxLevel = 1,
	onApply = onApply,
	onRemove = onRemove,
}

return Dash
