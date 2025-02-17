local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RequestLapskaus: BindableFunction = ReplicatedStorage.BindebaleFunctions.RequestLapskaus
local GivePlayerLapskaus: RemoteEvent = ReplicatedStorage.Events.GivePlayerLapskaus
local Types = require(ReplicatedStorage.Types.Server)

local lapskaus = require(ReplicatedStorage.Modules.LapskausSetup)

export type CaptureTheLapskausMetadata = {
	blueTeam: { [Player]: Player },
	redTeam: { [Player]: Player },
	currentlyHoldingBlue: Player?,
	currentlyHoldingRed: Player?,
}

local CaptureTheLapskaus: Types.Gamemode = {
	name = "CaptureTheLapskaus",
	metadata = {
		blueTeam = {},
		redTeam = {},
		currentlyHoldingBlue = nil,
		currentlyHoldingRed = nil,
	} :: CaptureTheLapskausMetadata,
} :: Types.Gamemode

local function getPlayerTeam(player: Player): string
	local metadata = CaptureTheLapskaus.metadata :: CaptureTheLapskausMetadata
	if metadata.blueTeam[player] then
		return "Blue"
	elseif metadata.redTeam[player] then
		return "Red"
	else
		return "None"
	end
end

local function captureLapskaus(player: Player, team: string)
	local metadata = CaptureTheLapskaus.metadata :: CaptureTheLapskausMetadata
	if team == "Blue" then
		if metadata.currentlyHoldingBlue == player then
			metadata.currentlyHoldingBlue = nil
			return true
		end
	elseif team == "Red" then
		if metadata.currentlyHoldingRed == player then
			metadata.currentlyHoldingRed = nil
			return true
		end
	end
	return false
end

local function takeLapskaus(player: Player, team: string): boolean
	local metadata = CaptureTheLapskaus.metadata :: CaptureTheLapskausMetadata

	if metadata.currentlyHoldingBlue ~= nil and metadata.currentlyHoldingRed ~= nil then
		return false
	end

	if metadata.currentlyHoldingBlue == player or metadata.currentlyHoldingRed == player then
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
	local metadata = CaptureTheLapskaus.metadata :: CaptureTheLapskausMetadata
	for _, player in ipairs(players) do
		if math.random() > 0.5 then
			metadata.blueTeam[player] = player
		else
			metadata.redTeam[player] = player
		end
	end
end

function CaptureTheLapskaus.handleKill(killer: Player, victim: Player)
	print("Killer: " .. killer.Name .. " Victim: " .. victim.Name)
end

return CaptureTheLapskaus
