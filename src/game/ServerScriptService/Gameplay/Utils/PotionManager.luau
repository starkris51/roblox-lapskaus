--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Types = require(ReplicatedStorage.Types.Global)

local MAX_UPGRADE_POTIONS = 3
local MAX_ABILITY_POTIONS = 1
local MAX_WEAPON_POTIONS = 1

type Potions = {
	[string]: Types.PotionType,
}

type PlayerPotions = {
	[Player]: Types.PlayerPotions,
}

local playerPotions: PlayerPotions = {}

local PotionManager = {}

local potions: { [Types.PotionName]: Types.PotionType } = {
	Jump = require(ServerScriptService.Gameplay.Utils.PotionEffects.Upgrade.Jump),
	Dash = require(ServerScriptService.Gameplay.Utils.PotionEffects.Ability.Dash),
	Speed = require(ServerScriptService.Gameplay.Utils.PotionEffects.Upgrade.Speed),
	DoubleShot = require(ServerScriptService.Gameplay.Utils.PotionEffects.Weapon.DoubleShot),
}

function PotionManager.initPlayer(player: Player)
	playerPotions[player] = {
		Upgrade = {},
		Ability = {},
		Weapon = {},
		upgradeCount = 0,
		abilityCount = 0,
		weaponCount = 0,
	}
end

function PotionManager.cleanupPlayer(player: Player)
	playerPotions[player] = nil
end

function PotionManager.canReceivePotion(player: Player, potionName: Types.PotionName): boolean
	if not playerPotions[player] then
		PotionManager.initPlayer(player)
	end

	local potionData = potions[potionName]
	if not potionData then
		warn("Potion type not found: " .. potionName)
		return false
	end

	local playerData = playerPotions[player]
	local category = potionData.category
	local currentLevel = playerData[category][potionName] or 0

	if currentLevel >= potionData.maxLevel then
		return false
	end

	if category == "Upgrade" and playerData.upgradeCount >= MAX_UPGRADE_POTIONS and currentLevel == 0 then
		return false
	elseif category == "Ability" and playerData.abilityCount >= MAX_ABILITY_POTIONS and currentLevel == 0 then
		return false
	elseif category == "Weapon" and playerData.weaponCount >= MAX_WEAPON_POTIONS and currentLevel == 0 then
		return false
	end

	return true
end

function PotionManager.givePotion(player: Player, potionName: Types.PotionName): boolean
	if not PotionManager.canReceivePotion(player, potionName) then
		return false
	end

	local playerData = playerPotions[player]
	local potionData = potions[potionName]
	local category = potionData.category

	if playerData[category][potionName] then
		potionData.onRemove(player)
	else
		if category == "Upgrade" then
			playerData.upgradeCount += 1
		elseif category == "Ability" then
			playerData.abilityCount += 1
		elseif category == "Weapon" then
			playerData.weaponCount += 1
		end
	end

	playerData[category][potionName] = (playerData[category][potionName] or 0) + 1

	potionData.onApply(player, playerData[category][potionName])

	return true
end

function PotionManager.removePotion(player: Player, potionName: Types.PotionName): boolean
	if not playerPotions[player] then
		return false
	end

	local playerData = playerPotions[player]
	local potionData = potions[potionName]

	if not potionData then
		return false
	end

	local category = potionData.category

	if not playerData[category][potionName] then
		return false
	end

	potionData.onRemove(player)

	if category == "Upgrade" then
		playerData.upgradeCount -= 1
	elseif category == "Ability" then
		playerData.abilityCount -= 1
	elseif category == "Weapon" then
		playerData.weaponCount -= 1
	end

	playerData[category][potionName] = nil

	return true
end

function PotionManager.getPlayerPotions(player: Player): Types.PlayerPotions?
	return playerPotions[player]
end

function PotionManager.getPotionLevel(player: Player, potionName: Types.PotionName): number
	if not playerPotions[player] then
		return 0
	end

	local potionData = potions[potionName]
	if not potionData then
		return 0
	end

	local category = potionData.category
	return playerPotions[player][category][potionName] or 0
end

return PotionManager
