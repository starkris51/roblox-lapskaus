--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Types = require(ReplicatedStorage.Types.Server)
local ServerStorage = game:GetService("ServerStorage")
local RequestKill: BindableEvent = ServerStorage.ServerEvents.RequestKill
local TimerUpdated: UnreliableRemoteEvent = ReplicatedStorage.Events.TimerUpdated

-- local CaptureTheLapskaus = require(ReplicatedStorage.Modules.Gamemodes.CaptureTheLapskaus)
-- local Deathmatch = require(ReplicatedStorage.Modules.Gamemodes.Deathmatch)

local gameTimer: RBXScriptConnection

local Gamemodes: { [Types.GamemodesName]: Types.Gamemode } = {
	CaptureTheLapskaus = require(ServerScriptService.Modules.Gamemodes.CaptureTheLapskaus),
	Deathmatch = require(ServerScriptService.Modules.Gamemodes.Deathmatch),
}

local gameModeManager: {
	gamemode: Types.Gamemode?,
	setupGamemode: (gamemodeName: Types.GamemodesName) -> (),
} = {
	gamemode = nil,
	setupGamemode = function() end,
}

local function updateTimer(startTime: number, endTime: number)
	local currentTime: number = tick()
	if currentTime - startTime >= endTime then
		gameTimer:Disconnect()
		if gameModeManager.gamemode then
			gameModeManager.gamemode.handleWin()
		end
	end

	local remainingTime: number = math.ceil(endTime - (currentTime - startTime))
	TimerUpdated:FireAllClients(remainingTime)
end

function gameModeManager.setupGamemode(gamemodeName: Types.GamemodesName)
	local gamemode: Types.Gamemode = Gamemodes[gamemodeName]
	if not gamemode then
		error("Invalid gamemode")
	end

	gameModeManager.gamemode = gamemode
	gamemode.setup()

	for _, player in ipairs(Players:GetPlayers()) do
		gamemode.setupPlayer(player)
	end

	Players.PlayerAdded:Connect(gamemode.setupPlayer)

	RequestKill.Event:Connect(gamemode.handleKill)

	local startTime: number = tick()
	local endTime: number = 10
	gameTimer = RunService.Heartbeat:Connect(function()
		updateTimer(startTime, endTime)
	end)
end

return gameModeManager
