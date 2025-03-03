--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local GamemodeManager = require(ServerScriptService.Gameplay.GamemodeManager)
local Types = require(ReplicatedStorage.Types.Server)

Players.CharacterAutoLoads = false

local gameState: Types.GameState

function serverGameLoopAsync()
	while true do
		gameState = "Waiting"
		repeat
			wait(1)
		until #Players:GetPlayers() >= 1

		local isGamemodeSetup = pcall(function()
			GamemodeManager.setupGamemode("CaptureTheLapskaus")
		end)

		if not isGamemodeSetup then
			error("Failed to setup gamemode")
		end

		print("game started, gamemode setup")

		gameState = "Playing"

		repeat
			wait(1)
		until not GamemodeManager.isGamemodeActive()

		gameState = "Ended"

		print("Game ended, new gamemode starting")
	end
end

task.spawn(serverGameLoopAsync)
