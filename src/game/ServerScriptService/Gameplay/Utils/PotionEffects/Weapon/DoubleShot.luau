--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local WeaponStateManager = require(ServerScriptService.Gameplay.Utils.WeaponStateManager)
local Types = require(ReplicatedStorage.Types.Global)

local function onApply(player: Player, level: number)
	if WeaponStateManager.playerReloadState[player] then
		WeaponStateManager.playerReloadState[player].doubleShot = true
	end

	print(player.Name .. " got DoubleShot level " .. level)
end

local function onRemove(player: Player)
	if WeaponStateManager.playerReloadState[player] then
		WeaponStateManager.playerReloadState[player].doubleShot = false
	end
end

local DoubleShot: Types.PotionType = {
	name = "DoubleShot",
	category = "Weapon",
	maxLevel = 1,
	onApply = onApply,
	onRemove = onRemove,
}

return DoubleShot
