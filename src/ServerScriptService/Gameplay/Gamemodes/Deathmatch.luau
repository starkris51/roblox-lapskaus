--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Types = require(ReplicatedStorage.Types.Server)

local KillPlayer: RemoteEvent = ReplicatedStorage.Events.KillPlayer

local Respawn = require(ServerScriptService.Gameplay.Utils.Respawn)
local PlayerKill = require(ServerScriptService.Gameplay.Utils.PlayerKill)
local WeaponStateManager = require(ServerScriptService.Gameplay.Utils.WeaponStateManager)

local Deathmatch: Types.Gamemode = {} :: Types.Gamemode

Deathmatch.name = "Deathmatch"
Deathmatch.metadata = {
	playerScore = {},
	playerDeaths = {},
}

local metadata: Types.DeathmatchMetadata = Deathmatch.metadata :: Types.DeathmatchMetadata

function Deathmatch.setup()
	Respawn.setupRespawnPoints()
end

function Deathmatch.setupPlayer(player: Player)
	WeaponStateManager.initPlayerReloadState(player)

	metadata.playerScore[player] = 0
	metadata.playerDeaths[player] = 0

	Respawn.respawn(player)
end

function Deathmatch.playerLeave(player: Player)
	WeaponStateManager.cleanupPlayerReloadState(player)
	PlayerKill.removeKilledPlayer(player)

	metadata.playerScore[player] = nil
	metadata.playerDeaths[player] = nil
end

function Deathmatch.handleKill(killer: Player, victim: Player)
	if not killer or not victim then
		error("Killer or victim is nil", 0)
		return
	end

	if PlayerKill.isPlayerKilled(victim) then
		return
	end

	metadata.playerScore[killer] += 1
	metadata.playerDeaths[victim] += 1

	PlayerKill.addKilledPlayer(victim)
	KillPlayer:FireClient(victim, killer)
	Respawn.startRespawnTimer(victim, 2)
end

function Deathmatch.handleWin()
	local highestScore: number = 0
	local winner: Player = nil

	for player: Player, score: number in pairs(metadata.playerScore) do
		if score > highestScore then
			highestScore = score
			winner = player
		end
	end

	print(winner.Name .. " won the Deathmatch with " .. highestScore .. " kills!")
end

return Deathmatch
