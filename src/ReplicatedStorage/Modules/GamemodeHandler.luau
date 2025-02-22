local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Types = require(ReplicatedStorage.Types.Server)
local ServerStorage = game:GetService("ServerStorage")
local RequestKill: BindableEvent = ServerStorage.ServerEvents.RequestKill

local Gamemodes = {
	CaptureTheLapskaus = require(ReplicatedStorage.Modules.Gamemodes.CaptureTheLapskaus),
	Deathmatch = require(ReplicatedStorage.Modules.Gamemodes.Deathmatch),
}

local gameModeManager = {
	gameMode = nil,
	currentGamemode = "",
}

function gameModeManager.setupGamemode(gamemodeName: string)
	local gamemode: Types.Gamemode = Gamemodes[gamemodeName]
	gameModeManager.currentGamemode = gamemode.name
	gameModeManager.gamemode = gamemode
	if gamemode then
		gamemode.setup()
		gamemode.setupPlayers(Players:GetPlayers())
		RequestKill.Event:Connect(function(killer: Player, victim: Player)
			gamemode.handleKill(killer, victim)
		end)
	else
		warn("Gamemode not found: " .. gamemodeName)
	end
end

return gameModeManager
