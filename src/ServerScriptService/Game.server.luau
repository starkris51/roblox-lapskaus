--!strict
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local GamemodeManager = require(ServerScriptService.Gameplay.GamemodeManager)

Players.CharacterAutoLoads = false

repeat
	wait()
until #Players:GetPlayers() >= 1

GamemodeManager.setupGamemode("CaptureTheLapskaus")
