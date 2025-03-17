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
local PotionManager = require(ServerScriptService.Gameplay.Utils.PotionManager)
local TeamManager = require(ServerScriptService.Gameplay.Utils.TeamManager)
local WeaponStateManager = require(ServerScriptService.Gameplay.Utils.WeaponStateManager)

type lapskausTeam = "Blue" | "Red"

local droppedLapskaus: { [string]: { part: Part, team: string } } = {}

local TEAMS = {
	Blue = "Blue",
	Red = "Red",
}

local CaptureTheLapskaus: Types.Gamemode = {} :: Types.Gamemode

CaptureTheLapskaus.name = "CaptureTheLapskaus"
CaptureTheLapskaus.metadata = {
	teams = {},
	teamScores = {},
	holdingFlags = {},
}

local metadata: Types.CaptureTheLapskausMetadata = CaptureTheLapskaus.metadata :: Types.CaptureTheLapskausMetadata
local teams: Types.Teams = metadata.teams
local teamScores: Types.TeamStatistics = metadata.teamScores
local holdingFlags: Types.HoldingFlags = metadata.holdingFlags

local function createDroppedLapskaus(team: string, position: Vector3)
	if droppedLapskaus[team] and droppedLapskaus[team].part then
		droppedLapskaus[team].part:Destroy()
	end

	local flag: Part = Instance.new("Part")
	flag.Name = "DroppedLapskaus_" .. team
	flag.Anchored = true
	flag.CanCollide = false
	flag.Size = Vector3.new(2, 2, 2)
	flag.Position = position + Vector3.new(0, 2, 0)

	if team == "Blue" then
		flag.Color = Color3.fromRGB(0, 0, 255)
	elseif team == "Red" then
		flag.Color = Color3.fromRGB(255, 0, 0)
	end

	flag.Material = Enum.Material.Neon

	local prompt: ProximityPrompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = team .. " Lapskaus"
	prompt.ActionText = "Pick up"
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 8
	prompt.Parent = flag

	prompt.Triggered:Connect(function(player)
		local success: any = RequestLapskaus:Invoke(player, team)
		if success and droppedLapskaus[team] then
			droppedLapskaus[team].part:Destroy()
			droppedLapskaus[team] = nil
		end
	end)

	droppedLapskaus[team] = { part = flag, team = team }
	flag.Parent = workspace

	return flag
end

local function cleanupDroppedLapskaus(team: string)
	if droppedLapskaus[team] and droppedLapskaus[team].part then
		droppedLapskaus[team].part:Destroy()
		droppedLapskaus[team] = nil
	end
end

local function cleanupAllDroppedLapskaus()
	for team: string, data: { part: Part, team: string } in pairs(droppedLapskaus) do
		if data.part then
			data.part:Destroy()
		end
	end
	droppedLapskaus = {}
end

local function captureLapskaus(player: Player, team: lapskausTeam)
	if holdingFlags[team] == player then
		holdingFlags[team] = nil
		local playerTeam: lapskausTeam | nil = TeamManager.getPlayerTeam(player, teams) :: lapskausTeam | nil
		if playerTeam then
			teamScores[playerTeam] = (teamScores[playerTeam] or 0) + 1
		end

		ResetLapskaus:Fire(team)

		return
	end
end

local function takeLapskaus(player: Player, team: lapskausTeam): boolean
	local playerTeam: lapskausTeam | nil = TeamManager.getPlayerTeam(player, teams) :: lapskausTeam | nil
	if not playerTeam then
		return false
	end

	local oppositeTeam: lapskausTeam = (playerTeam == TEAMS.Blue and TEAMS.Red or TEAMS.Blue) :: lapskausTeam

	if playerTeam == team then
		if droppedLapskaus[team] then
			cleanupDroppedLapskaus(team)
			ResetLapskaus:Fire(team)
			return true
		end

		captureLapskaus(player, oppositeTeam)
		return false
	end

	if holdingFlags[team] then
		return false
	end

	local flagsHeld: number = 0
	for _, carrier: Player in pairs(holdingFlags) do
		if carrier == player then
			flagsHeld += 1
		end
	end

	if flagsHeld >= 1 then
		return false
	end

	holdingFlags[team] = player
	GivePlayerLapskaus:FireClient(player, team)

	cleanupDroppedLapskaus(team)

	return true
end

function CaptureTheLapskaus.setup()
	teams = TeamManager.initializeTeamData("Blue", "Red")
	teamScores[TEAMS.Blue] = 0
	teamScores[TEAMS.Red] = 0

	RequestLapskaus.OnInvoke = takeLapskaus
	GameObjects.initializeGameObject("Lapskaus")
	GameObjects.initializeGameObject("Potion")
	Respawn.setupRespawnPoints()
end

function CaptureTheLapskaus.setupPlayer(player: Player)
	WeaponStateManager.initPlayerReloadState(player)
	TeamManager.assignPlayerToTeam(teams, player)
	Respawn.respawn(player)
	TeamManager.highlightPlayer(player, TeamManager.getPlayerTeam(player, teams) or "")
	PotionManager.initPlayer(player)
end

function CaptureTheLapskaus.playerLeave(player: Player)
	WeaponStateManager.cleanupPlayerReloadState(player)
	PlayerKill.removeKilledPlayer(player)
	TeamManager.removePlayerFromTeam(teams, player)
	PotionManager.cleanupPlayer(player)
end

function CaptureTheLapskaus.handleKill(killer: Player, victim: Player)
	local killerTeam: string | nil = TeamManager.getPlayerTeam(killer, teams)
	local victimTeam: string | nil = TeamManager.getPlayerTeam(victim, teams)

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
			local character: Model? = victim.Character
			if character then
				local rootPart: Instance? = character:FindFirstChild("HumanoidRootPart")
				if rootPart and rootPart:IsA("BasePart") then
					createDroppedLapskaus(team, rootPart.Position)
				end
			end

			holdingFlags[team] = nil
			GivePlayerLapskaus:FireClient(victim, "None")
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

	cleanupAllDroppedLapskaus()

	metadata = {
		teams = {},
		teamScores = {},
		holdingFlags = {},
	} -- Reset metadata

	wait(2)
end

return CaptureTheLapskaus
