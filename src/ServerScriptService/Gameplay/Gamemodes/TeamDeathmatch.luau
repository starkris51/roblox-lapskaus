--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Types = require(ReplicatedStorage.Types.Server)

local KillPlayer: RemoteEvent = ReplicatedStorage.Events.KillPlayer

local Respawn = require(ServerScriptService.Gameplay.Utils.Respawn)
local PlayerKill = require(ServerScriptService.Gameplay.Utils.PlayerKill)

local TeamManager = require(ServerScriptService.Gameplay.Utils.TeamManager)

local TeamDeathmatch: Types.Gamemode = {
	name = "TeamDeathmatch",
	metadata = {
		teams = {},
		teamScores = {},
		teamDeaths = {},
	},
	setup = function() end,
	setupPlayer = function() end,
	handleKill = function() end,
	handleWin = function() end,
}

local metadata: Types.TeamDeathmatchMetadata = TeamDeathmatch.metadata :: Types.TeamDeathmatchMetadata
local teams: Types.Teams = metadata.teams
local teamScores: Types.TeamStatistics = metadata.teamScores
local teamDeaths: Types.TeamStatistics = metadata.teamDeaths

local function getPlayerTeam(player: Player): string | nil
	for teamName: string, team in pairs(teams) do
		if team[player] then
			return teamName
		end
	end
	return nil
end

function TeamDeathmatch.setup()
	teams = TeamManager.initializeTeamData("test", "test2", "test3", "test4")

	for teamName: string, team in pairs(teams) do
		teamScores[teamName] = 0
		teamDeaths[teamName] = 0
	end

	Respawn.setupRespawnPoints()
end

function TeamDeathmatch.setupPlayer(player: Player)
	TeamManager.assignPlayerToTeam(teams, player)
	Respawn.respawn(player)
	TeamManager.highlightPlayer(player, "")
end

function TeamDeathmatch.handleKill(killer: Player, victim: Player)
	local killerTeam: string | nil = getPlayerTeam(killer)
	local victimTeam: string | nil = getPlayerTeam(victim)

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
