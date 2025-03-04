--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Types.Server)
local ServerScriptService = game:GetService("ServerScriptService")

local RequestLapskaus: BindableFunction = ServerScriptService.Events.RequestLapskaus
local ResetLapskaus: BindableEvent = ServerScriptService.Events.ResetLapskaus
local GivePlayerLapskaus: RemoteEvent = ReplicatedStorage.Events.GivePlayerLapskaus
local KillPlayer: RemoteEvent = ReplicatedStorage.Events.KillPlayer

local GameObjects = require(ServerScriptService.Gameplay.Utils.GameObjects)
local Respawn = require(ServerScriptService.Gameplay.Utils.Respawn)
local PlayerKill = require(ServerScriptService.Gameplay.Utils.PlayerKill)
local TeamManager = require(ServerScriptService.Gameplay.Utils.TeamManager)

type lapskausTeam = "Blue" | "Red"

local TEAMS = {
	Blue = "Blue",
	Red = "Red",
}

local CaptureTheLapskaus: Types.Gamemode = {
	name = "CaptureTheLapskaus",
	metadata = {
		teams = {},
		teamScores = {},
		holdingFlags = {},
	},
	setup = function() end,
	setupPlayer = function() end,
	handleKill = function() end,
	handleWin = function() end,
}

local metadata: Types.CaptureTheLapskausMetadata = CaptureTheLapskaus.metadata :: Types.CaptureTheLapskausMetadata
local teams: Types.Teams = metadata.teams
local teamScores: Types.TeamStatistics = metadata.teamScores
local holdingFlags: Types.HoldingFlags = metadata.holdingFlags

local function getPlayerTeam(player: Player): lapskausTeam | nil
	for teamName: string, team in pairs(teams) do
		if team[player] then
			return teamName :: lapskausTeam
		end
	end
	return nil
end

local function captureLapskaus(player: Player, team: lapskausTeam)
	if holdingFlags[team] == player then
		holdingFlags[team] = nil
		local playerTeam: lapskausTeam | nil = getPlayerTeam(player)
		if playerTeam then
			teamScores[playerTeam] = (teamScores[playerTeam] or 0) + 1
		end

		ResetLapskaus:Fire(team)

		return
	end

	print("Player is not holding the flag")
end

local function takeLapskaus(player: Player, team: lapskausTeam): boolean
	local playerTeam: lapskausTeam | nil = getPlayerTeam(player)
	if not playerTeam then
		return false
	end

	local oppositeTeam: lapskausTeam = (playerTeam == TEAMS.Blue and TEAMS.Red or TEAMS.Blue) :: lapskausTeam

	if playerTeam == team then
		captureLapskaus(player, oppositeTeam)
		return false
	end

	if holdingFlags[team] then
		return false
	end

	local flagsHeld: number = 0
	for _, _ in pairs(holdingFlags) do
		flagsHeld += 1
	end
	if flagsHeld >= 2 then
		return false
	end

	holdingFlags[team] = player
	GivePlayerLapskaus:FireClient(player, team)
	return true
end

function CaptureTheLapskaus.setup()
	teams = TeamManager.initializeTeamData("Blue", "Red")
	teamScores[TEAMS.Blue] = 0
	teamScores[TEAMS.Red] = 0

	RequestLapskaus.OnInvoke = takeLapskaus
	GameObjects.initializeGameObject("Lapskaus")
	Respawn.setupRespawnPoints()
end

function CaptureTheLapskaus.setupPlayer(player: Player)
	Respawn.respawn(player)
	TeamManager.assignPlayerToTeam(teams, player)
end

function CaptureTheLapskaus.handleKill(killer: Player, victim: Player)
	local killerTeam: string | nil = getPlayerTeam(killer)
	local victimTeam: string | nil = getPlayerTeam(victim)

	if not killer or not victim then
		error("Killer or victim is nil", 0)
		return
	end

	if killerTeam == victimTeam then
		return
	end

	if PlayerKill.isPlayerKilled(victim) then
		return
	end

	for team: string, carrier: Player in pairs(holdingFlags) do
		if carrier == victim then
			-- Tempoary fix for resetting lapskaus when player dies, will improve later and add drop lapskaus feature
			holdingFlags[team] = nil
			ResetLapskaus:Fire(team)
		end
	end

	PlayerKill.addKilledPlayer(victim)
	KillPlayer:FireClient(victim, killer)
	Respawn.startRespawnTimer(victim, 2)
end

function CaptureTheLapskaus.handleWin()
	local highestScore: number = 0
	local winner: string = ""

	for team: string, score: number in pairs(teamScores) do
		if score > highestScore then
			highestScore = score
			winner = team
		end
	end

	print(winner .. " team won Capture the Lapskaus with " .. highestScore .. " captures!")

	metadata = {
		teams = {},
		teamScores = {},
		holdingFlags = {},
	} -- Reset metadata

	wait(2)
end

return CaptureTheLapskaus
