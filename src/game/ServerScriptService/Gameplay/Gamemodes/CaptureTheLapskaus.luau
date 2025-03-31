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

local PlayerLapskausAttachment: Attachment = Instance.new("Attachment")
PlayerLapskausAttachment.Name = "PlayerLapskausAttachment"

local DroppedLapskausLocation: Part = Instance.new("Part")
DroppedLapskausLocation.Name = "DroppedLapskausLocation"
DroppedLapskausLocation.Size = Vector3.new(1, 1, 1)
DroppedLapskausLocation.Transparency = 1
DroppedLapskausLocation.CanCollide = false
DroppedLapskausLocation.Anchored = true

type lapskausTeam = "Blue" | "Red"

local droppedLapskaus: { [string]: lapskausTeam } = {}

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

local function createDroppedLapskaus(team: lapskausTeam, character: Model)
	local lapskausModel: Model = nil
	for _, obj: Instance in pairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj.Name == "Lapskaus" .. team then
			lapskausModel = obj
			break
		end
	end

	if not lapskausModel then
		warn("Could not find lapskaus model for team: " .. team)
		return
	end

	if not lapskausModel.PrimaryPart then
		warn("Lapskaus model does not have a PrimaryPart")
		return
	end

	local primaryPart: MeshPart? = lapskausModel.PrimaryPart :: MeshPart
	if not primaryPart then
		warn("Lapskaus model does not have a PrimaryPart")
		return
	end

	local alignPosition = primaryPart:FindFirstChild("LapskausAlignPosition") :: AlignPosition
	if not alignPosition then
		warn("LapskausAlignPosition not found in lapskaus model")
		return
	end

	local HumanoidRootPart: Part? = character:FindFirstChild("HumanoidRootPart") :: Part
	if not HumanoidRootPart then
		warn("HumanoidRootPart not found in character")
		return
	end

	local droppedLapskausLocation: Part = DroppedLapskausLocation:Clone()
	droppedLapskausLocation.Parent = workspace
	droppedLapskausLocation.Position = HumanoidRootPart.Position

	local floorAttachment = Instance.new("Attachment")
	floorAttachment.Name = "FloorAttachment"
	floorAttachment.Parent = droppedLapskausLocation

	alignPosition.Attachment1 = floorAttachment

	local prompt: ProximityPrompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = team .. " Lapskaus"
	prompt.ActionText = "Pick up"
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 8

	if lapskausModel:IsA("Model") and lapskausModel.PrimaryPart then
		prompt.Parent = lapskausModel.PrimaryPart
	else
		prompt.Parent = lapskausModel
	end

	prompt.Triggered:Connect(function(player)
		local success: any = RequestLapskaus:Invoke(player, team)
		if success and droppedLapskaus[team] then
			ResetLapskaus:Fire(team)
			droppedLapskaus[team] = nil
		end
	end)

	droppedLapskaus[team] = team

	return lapskausModel
end

local function cleanupDroppedLapskaus(team: string)
	if droppedLapskaus[team] then
		ResetLapskaus:Fire(team)
		droppedLapskaus[team] = nil
	end
end

local function cleanupAllDroppedLapskaus()
	for team, _ in pairs(droppedLapskaus) do
		ResetLapskaus:Fire(team)
		droppedLapskaus[team :: lapskausTeam] = nil
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

	local playerLapskausAttachment: Attachment = PlayerLapskausAttachment:Clone()
	if player.Character then
		playerLapskausAttachment.Parent = player.Character:WaitForChild("HumanoidRootPart")
	end
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
					createDroppedLapskaus(team :: lapskausTeam, character)
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
