--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Types = require(ReplicatedStorage.Types.Global)
local WeaponStateManager = require(ServerScriptService.Gameplay.Utils.WeaponStateManager)

local ExtraShotEffect = {}

function ExtraShotEffect.apply(player: Player, existingEffect: Types.PotionEffect?): Types.PotionEffect
	if existingEffect then
		existingEffect.data.shots += 1
		existingEffect.level += 1
		return existingEffect
	else
		local effect: Types.PotionEffect = {
			type = "ExtraShot",
			level = 1,
			data = {
				shots = 3,
			},
			persistThroughDeath = false,
		}

		if WeaponStateManager.playerReloadState[player] then
			WeaponStateManager.playerReloadState[player].hasPowerup = true
		end

		return effect
	end
end

function ExtraShotEffect.remove(player: Player)
	if WeaponStateManager.playerReloadState[player] then
		WeaponStateManager.playerReloadState[player].hasPowerup = false
	end
end

function ExtraShotEffect.consumeUse(player: Player, effect: Types.PotionEffect, onRemoveCallback: () -> ()): boolean
	if effect.data.DoubleShot.shots > 0 then
		effect.data.DoubleShot.shots -= 1

		if effect.data.DoubleShot.shots <= 0 then
			ExtraShotEffect.remove(player)
			onRemoveCallback()
		end

		return true
	end

	return false
end

return ExtraShotEffect
