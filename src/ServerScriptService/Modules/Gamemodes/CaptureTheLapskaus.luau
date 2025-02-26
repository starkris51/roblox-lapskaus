--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local RequestLapskaus: BindableFunction = ServerStorage.ServerEvents.RequestLapskaus
local GivePlayerLapskaus: RemoteEvent = ReplicatedStorage.Events.GivePlayerLapskaus
local KillPlayer: RemoteEvent = ReplicatedStorage.Events.KillPlayer
local Types = require(ReplicatedStorage.Types.Server)

local GameObjects = require(ServerScriptService.Modules.GameObjects)
local RespawnHandler = require(ServerScriptService.Modules.RespawnHandler)
local PlayerKillHandler = require(ServerScriptService.Modules.PlayerKillHandler)
local TeamManager = require(ServerScriptService.Modules.TeamManager)

type lapskausTeam = "Blue" | "Red"

local CaptureTheLapskaus: Types.Gamemode = {
	name = "CaptureTheLapskaus",
	metadata = {
		teams = {},
		teamScores = {},
		currentlyHoldingBlue = nil,
		currentlyHoldingRed = nil,
	},
	setup = function() end,
	setupPlayer = function() end,
	handleKill = function() end,
	handleWin = function() end,
}

local metadata: Types.CaptureTheLapskausMetadata = CaptureTheLapskaus.metadata :: Types.CaptureTheLapskausMetadata

local function getPlayerTeam(player: Player): lapskausTeam | nil
	local teams: Types.Teams = metadata.teams

	if teams["Blue"][player] then
		return "Blue"
	elseif teams["Red"][player] then
		return "Red"
	else
		return nil
	end
end

local function captureLapskaus(player: Player, team: lapskausTeam)
	if team == "Blue" then
		if metadata.currentlyHoldingBlue == player then
			print("Blue team captured the lapskaus")
			metadata.currentlyHoldingBlue = nil
			metadata.teamScores["Blue"] += 1
			return true
		end
	elseif team == "Red" then
		if metadata.currentlyHoldingRed == player then
			print("Red team captured the lapskaus")
			metadata.currentlyHoldingRed = nil
			metadata.teamScores["Red"] += 1
			return true
		end
	end

	return false
end

local function takeLapskaus(player: Player, team: lapskausTeam): boolean
	if metadata.currentlyHoldingBlue ~= nil and metadata.currentlyHoldingRed ~= nil then
		return false
	end

	if getPlayerTeam(player) == "Blue" and team == "Red" then
		metadata.currentlyHoldingBlue = player
	elseif getPlayerTeam(player) == "Red" and team == "Blue" then
		metadata.currentlyHoldingRed = player
	elseif getPlayerTeam(player) == team then
		captureLapskaus(player, team)
		return false
	else
		return false
	end

	GivePlayerLapskaus:FireClient(player, team)

	return true
end

function CaptureTheLapskaus.setup()
	metadata.teams = TeamManager.initializeTeamData("Blue", "Red")
	metadata.teamScores["Blue"] = 0
	metadata.teamScores["Red"] = 0

	RequestLapskaus.OnInvoke = takeLapskaus
	GameObjects.initializeGameObject("Lapskaus")
	RespawnHandler.setupRespawnPoints()
end

function CaptureTheLapskaus.setupPlayer(player: Player)
	RespawnHandler.respawn(player)

	TeamManager.assignPlayerToTeam(metadata.teams, player)
end

function CaptureTheLapskaus.handleKill(killer: Player, victim: Player)
	if not killer or not victim then
		error("Killer or victim is nil", 0)
		return
	end

	if getPlayerTeam(killer) == getPlayerTeam(victim) then
		return
	end

	if PlayerKillHandler.isPlayerKilled(victim) then
		return
	end

	PlayerKillHandler.addKilledPlayer(victim)
	KillPlayer:FireClient(victim, killer)
	RespawnHandler.startRespawnTimer(victim, 2)
end

function CaptureTheLapskaus.handleWin()
	print(metadata.teamScores)

	local highestScore: number = 0
	local winner: string = ""

	for team: string, score: number in pairs(metadata.teamScores) do
		if score > highestScore then
			highestScore = score
			winner = team
		end
	end

	print(winner .. " team won Capture the Lapskaus with " .. highestScore .. " captures!")
end

return CaptureTheLapskaus
