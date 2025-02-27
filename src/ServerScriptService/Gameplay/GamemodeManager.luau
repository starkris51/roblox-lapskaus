--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Types = require(ReplicatedStorage.Types.Server)
local RequestKill: BindableEvent = ServerScriptService.Events.RequestKill
local TimerUpdated: UnreliableRemoteEvent = ReplicatedStorage.Events.TimerUpdated

local gameTimer: RBXScriptConnection

local Gamemodes: { [Types.GamemodesName]: Types.Gamemode } = {
	CaptureTheLapskaus = require(ServerScriptService.Gameplay.Gamemodes.CaptureTheLapskaus),
	Deathmatch = require(ServerScriptService.Gameplay.Gamemodes.Deathmatch),
}

local gameModeManager: {
	gamemode: Types.Gamemode?,
	setupGamemode: (gamemodeName: Types.GamemodesName) -> (),
	cleanup: () -> (),
} =
	{
		gamemode = nil,
		setupGamemode = function() end,
		cleanup = function() end,
	}

local function updateTimer(startTime: number, endTime: number)
	local currentTime: number = tick()
	if currentTime - startTime >= endTime then
		gameTimer:Disconnect()
		if gameModeManager.gamemode then
			gameModeManager.gamemode.handleWin()
		end
		gameModeManager.cleanup()
		return
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
	local endTime: number = 30 -- temporary value
	gameTimer = RunService.Heartbeat:Connect(function()
		updateTimer(startTime, endTime)
	end)
end

function gameModeManager.cleanup()
	RequestKill.Event:Connect(function()
		warn("RequestKill event was fired after cleanup")
	end)
end

return gameModeManager
