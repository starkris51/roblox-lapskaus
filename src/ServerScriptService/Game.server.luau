--!strict
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local gamemodeHandler = require(ServerScriptService.Modules.GamemodeHandler)

Players.CharacterAutoLoads = false

repeat
	wait()
until #Players:GetPlayers() >= 1

gamemodeHandler.setupGamemode("CaptureTheLapskaus")
