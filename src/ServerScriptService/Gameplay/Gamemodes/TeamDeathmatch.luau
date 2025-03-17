--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Types = require(ReplicatedStorage.Types.Server)

local KillPlayer: RemoteEvent = ReplicatedStorage.Events.KillPlayer

local Respawn = require(ServerScriptService.Gameplay.Utils.Respawn)
local PlayerKill = require(ServerScriptService.Gameplay.Utils.PlayerKill)
local PotionManager = require(ServerScriptService.Gameplay.Utils.PotionManager)

local TeamManager = require(ServerScriptService.Gameplay.Utils.TeamManager)
local WeaponStateManager = require(ServerScriptService.Gameplay.Utils.WeaponStateManager)

local TeamDeathmatch: Types.Gamemode = {} :: Types.Gamemode

TeamDeathmatch.name = "TeamDeathmatch"
TeamDeathmatch.metadata = {
	teams = {},
	teamScores = {},
	teamDeaths = {},
}

local metadata: Types.TeamDeathmatchMetadata = TeamDeathmatch.metadata :: Types.TeamDeathmatchMetadata
local teams: Types.Teams = metadata.teams
local teamScores: Types.TeamStatistics = metadata.teamScores
local teamDeaths: Types.TeamStatistics = metadata.teamDeaths

function TeamDeathmatch.setup()
	teams = TeamManager.initializeTeamData("test", "test2", "test3", "test4")

	for teamName: string, team in pairs(teams) do
		teamScores[teamName] = 0
		teamDeaths[teamName] = 0
	end

	Respawn.setupRespawnPoints()
end

function TeamDeathmatch.setupPlayer(player: Player)
	WeaponStateManager.initPlayerReloadState(player)

	TeamManager.assignPlayerToTeam(teams, player)
	Respawn.respawn(player)
	TeamManager.highlightPlayer(player, "")
	PotionManager.initPlayer(player)
end

function TeamDeathmatch.playerLeave(player: Player)
	WeaponStateManager.cleanupPlayerReloadState(player)
	TeamManager.removePlayerFromTeam(teams, player)
	PlayerKill.removeKilledPlayer(player)
	PotionManager.cleanupPlayer(player)
end

function TeamDeathmatch.handleKill(killer: Player, victim: Player)
	local killerTeam: string | nil = TeamManager.getPlayerTeam(killer, teams)
	local victimTeam: string | nil = TeamManager.getPlayerTeam(victim, teams)

	if not killerTeam or not victimTeam then
		return
	end

	if killerTeam == victimTeam then
		return
	end

	if PlayerKill.isPlayerKilled(victim) then
		return
	end

	teamScores[killerTeam] += 1
	teamDeaths[victimTeam] += 1

	PlayerKill.addKilledPlayer(victim)
	KillPlayer:FireClient(victim, killer)
	Respawn.startRespawnTimer(victim, 2)
end

function TeamDeathmatch.handleWin()
	local highestScore: number = 0
	local winner: { Name: string } = { Name = "" }

	for teamName: string, score: number in pairs(teamScores) do
		if score > highestScore then
			highestScore = score
			winner.Name = teamName
		end
	end

	print(winner.Name .. " won the TeamDeathmatch with " .. highestScore)
end

return TeamDeathmatch
