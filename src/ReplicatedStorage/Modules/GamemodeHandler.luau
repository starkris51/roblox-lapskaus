local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Types = require(ReplicatedStorage.Types.Server)
local ServerStorage = game:GetService("ServerStorage")
local RequestKill: BindableEvent = ServerStorage.ServerEvents.RequestKill
-- local CaptureTheLapskaus = require(ReplicatedStorage.Modules.Gamemodes.CaptureTheLapskaus)
-- local Deathmatch = require(ReplicatedStorage.Modules.Gamemodes.Deathmatch)

local gameTimer: RBXScriptConnection

local Gamemodes: { [Types.GamemodesName]: Types.Gamemode } = {
	CaptureTheLapskaus = require(ReplicatedStorage.Modules.Gamemodes.CaptureTheLapskaus),
	Deathmatch = require(ReplicatedStorage.Modules.Gamemodes.Deathmatch),
}

local gameModeManager = {
	gameMode = nil,
	currentGamemode = "",
}

function gameModeManager.setupGamemode(gamemodeName: Types.GamemodesName)
	local gamemode: Types.Gamemode = Gamemodes[gamemodeName]
	gameModeManager.currentGamemode = gamemode.name
	gameModeManager.gamemode = gamemode
	if gamemode then
		gamemode.setup()
		gamemode.setupPlayers(Players:GetPlayers())
		RequestKill.Event:Connect(function(killer: Player, victim: Player)
			gamemode.handleKill(killer, victim)
		end)
		gameTimer = RunService.Heartbeat:Connect(function() end)
	else
		warn("Gamemode not found: " .. gamemodeName)
	end
end

return gameModeManager
