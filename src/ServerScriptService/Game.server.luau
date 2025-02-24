local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local gamemodeHandler = require(ReplicatedStorage.Modules.GamemodeHandler)

repeat
	wait()
until #Players:GetPlayers() >= 1

gamemodeHandler.setupGamemode("CaptureTheLapskaus")
