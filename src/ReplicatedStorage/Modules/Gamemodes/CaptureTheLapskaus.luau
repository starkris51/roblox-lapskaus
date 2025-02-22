local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RequestLapskaus: BindableFunction = ServerStorage.ServerEvents.RequestLapskaus
local GivePlayerLapskaus: RemoteEvent = ReplicatedStorage.Events.GivePlayerLapskaus
local KillPlayer: RemoteEvent = ReplicatedStorage.Events.KillPlayer
local Types = require(ReplicatedStorage.Types.Server)

local lapskaus = require(ReplicatedStorage.Modules.LapskausSetup)

export type CaptureTheLapskausMetadata = {
	blueTeam: { [Player]: Player },
	redTeam: { [Player]: Player },
	currentlyHoldingBlue: Player?,
	currentlyHoldingRed: Player?,
}

local CaptureTheLapskaus = {
	name = "CaptureTheLapskaus",
	metadata = {
		blueTeam = {},
		redTeam = {},
		currentlyHoldingBlue = nil,
		currentlyHoldingRed = nil,
	} :: CaptureTheLapskausMetadata,
} :: Types.Gamemode

local function getPlayerTeam(player: Player): string
	local metadata: CaptureTheLapskausMetadata = CaptureTheLapskaus.metadata :: CaptureTheLapskausMetadata
	if metadata.blueTeam[player] then
		return "Blue"
	elseif metadata.redTeam[player] then
		return "Red"
	else
		return "None"
	end
end

local function captureLapskaus(player: Player, team: string)
	local metadata: CaptureTheLapskausMetadata = CaptureTheLapskaus.metadata :: CaptureTheLapskausMetadata
	if team == "Blue" then
		if metadata.currentlyHoldingBlue == player then
			print("Blue team captured the lapskaus")
			metadata.currentlyHoldingBlue = nil
			return true
		end
	elseif team == "Red" then
		if metadata.currentlyHoldingRed == player then
			print("Red team captured the lapskaus")
			metadata.currentlyHoldingRed = nil
			return true
		end
	end
	return false
end

local function takeLapskaus(player: Player, team: string): boolean
	local metadata: CaptureTheLapskausMetadata = CaptureTheLapskaus.metadata :: CaptureTheLapskausMetadata

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
	print("Setting up Capture The Flag")

	RequestLapskaus.OnInvoke = takeLapskaus

	lapskaus.setupLapskaus()
end

function CaptureTheLapskaus.setupPlayers(players: { Player })
	local metadata: CaptureTheLapskausMetadata = CaptureTheLapskaus.metadata :: CaptureTheLapskausMetadata
	for _, player in ipairs(players) do
		if math.random() > 0.5 then
			metadata.blueTeam[player] = player
		else
			metadata.redTeam[player] = player
		end
	end
end

function CaptureTheLapskaus.handleKill(killer: Player, victim: Player)
	if killer == nil or victim == nil then
		return
	end

	if getPlayerTeam(killer) == getPlayerTeam(victim) then
		return
	end

	print("Killer: " .. killer.Name .. " Victim: " .. victim.Name)

	KillPlayer:FireClient(victim, killer)
end

return CaptureTheLapskaus
