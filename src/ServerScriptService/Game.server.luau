local replicatedStorage = game:GetService("ReplicatedStorage")
local gamemodeHandler = require(replicatedStorage.Modules.GamemodeHandler)

repeat
	wait()
until #game.Players:GetPlayers() >= 1

gamemodeHandler.setupGamemode("CaptureTheLapskaus")
