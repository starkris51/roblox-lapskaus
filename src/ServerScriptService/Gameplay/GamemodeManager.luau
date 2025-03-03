--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Types = require(ReplicatedStorage.Types.Server)
local RequestKill: BindableEvent = ServerScriptService.Events.RequestKill
local TimerUpdated: UnreliableRemoteEvent = ReplicatedStorage.Events.TimerUpdated

local gameTimer: RBXScriptConnection
local requestKillConnection: RBXScriptConnection
local playerAddedConnection: RBXScriptConnection

local Gamemodes: { [Types.GamemodesName]: Types.Gamemode } = {
	CaptureTheLapskaus = require(ServerScriptService.Gameplay.Gamemodes.CaptureTheLapskaus),
	Deathmatch = require(ServerScriptService.Gameplay.Gamemodes.Deathmatch),
}

local gamemodeManager: {
	gamemode: Types.Gamemode?,
	setupGamemode: (gamemodeName: Types.GamemodesName) -> (),
	isGamemodeActive: () -> boolean,
} =
	{
		gamemode = nil,
		setupGamemode = function() end,
		isGamemodeActive = function()
			return false
		end,
	}

local function cleanup()
	requestKillConnection:Disconnect()
	playerAddedConnection:Disconnect()
	gameTimer:Disconnect()

	requestKillConnection = RequestKill.Event:Connect(function()
		warn("RequestKill event was fired after cleanup")
	end)

	gamemodeManager.gamemode = nil
end

local function updateTimer(startTime: number, endTime: number)
	local currentTime: number = tick()
	if currentTime - startTime >= endTime then
		local isGameWin = false
		if gamemodeManager.gamemode then
			isGameWin = pcall(gamemodeManager.gamemode.handleWin)
		end

		if not isGameWin then
			error("Failed to handle win")
		end

		local isCleanup = pcall(cleanup)

		if not isCleanup then
			error("Failed to complete gamemode")
		end

		return
	end

	local remainingTime: number = math.ceil(endTime - (currentTime - startTime))
	TimerUpdated:FireAllClients(remainingTime)
end

function gamemodeManager.setupGamemode(gamemodeName: Types.GamemodesName)
	local gamemode: Types.Gamemode = Gamemodes[gamemodeName]
	if not gamemode then
		error("Invalid gamemode")
	end

	gamemodeManager.gamemode = gamemode

	local isSetup = pcall(gamemode.setup)

	if not isSetup then
		error("Failed to setup gamemode")
	end

	for _, player in ipairs(Players:GetPlayers()) do
		local isPlayerSetup = pcall(gamemode.setupPlayer, player)
		if not isPlayerSetup then
			error("Failed to setup player: " .. player.Name)
		end
	end

	local isPlayerAddedConfigured, errorPlayerAdded = pcall(function()
		playerAddedConnection = Players.PlayerAdded:Connect(gamemode.setupPlayer)
	end)

	if not isPlayerAddedConfigured then
		error("Failed to configure player added event" .. errorPlayerAdded)
	end

	local isRequestKillConnected, errorRequestKill = pcall(function()
		requestKillConnection = RequestKill.Event:Connect(gamemode.handleKill)
	end)

	if not isRequestKillConnected then
		error("Failed to connect RequestKill event" .. errorRequestKill)
	end

	local startTime: number = tick()
	local endTime: number = 30 -- temporary value💀🤓

	local isTimerConnected, errorTimer = pcall(function()
		gameTimer = RunService.Heartbeat:Connect(function()
			updateTimer(startTime, endTime)
		end)
	end)

	if not isTimerConnected then
		error("Failed to connect timer" .. errorTimer)
	end

	return
end

function gamemodeManager.isGamemodeActive(): boolean
	return gamemodeManager.gamemode ~= nil
end

return gamemodeManager
