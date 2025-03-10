--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Types = require(ReplicatedStorage.Types.Global)
local PlayerKill = require(ServerScriptService.Gameplay.Utils.PlayerKill)
local WeaponStateManager = require(ServerScriptService.Gameplay.Utils.WeaponStateManager)

local GetPotion: BindableEvent = ServerScriptService.Events.GetPotion

type PotionManager = {
	playerPotions: { [Player]: { [Types.PotionType]: Types.PotionEffect } },
	initializePlayerPotions: (player: Player) -> (),
	cleanupPlayerPotions: (player: Player) -> (),
	applyPotion: (player: Player, potionType: Types.PotionType) -> (),
}

local PotionManager: PotionManager = {} :: PotionManager

function PotionManager.initializePlayerPotions(player: Player)
	PotionManager.playerPotions[player] = {}
end

function PotionManager.cleanupPlayerPotions(player: Player)
	PotionManager.playerPotions[player] = nil
end

function PotionManager.applyPotion(player: Player, potionType: Types.PotionType)
	if not PotionManager.playerPotions[player] then
		return
	end

	local existingPotion = PotionManager.playerPotions[player][potionType]

	local potionCount = 0
	for _ in pairs(PotionManager.playerPotions[player]) do
		potionCount += 1
	end

	if not existingPotion and potionCount >= 3 then
		return false
	end

	-- local effect = PotionEffects.applyEffect(player, potionType, existingPotion)
	-- if effect then
	-- 	PotionManager.playerPotions[player][potionType] = effect
	-- 	return true
	-- end

	return false
end

GetPotion.Event:Connect(PotionManager.applyPotion)

return PotionManager
