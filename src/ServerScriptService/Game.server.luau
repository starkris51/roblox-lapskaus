--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local GamemodeManager = require(ServerScriptService.Gameplay.GamemodeManager)
local Types = require(ReplicatedStorage.Types.Server)

local GamemodeFinished: BindableEvent = ServerScriptService.Events.GamemodeFinished

Players.CharacterAutoLoads = false

local gameState: Types.GameState

function serverGameLoopAsync()
	while true do
		gameState = "Waiting"
		repeat
			wait(1)
		until #Players:GetPlayers() >= 1

		local isGamemodeSetup: boolean, message: any = pcall(function()
			GamemodeManager.setupGamemode("TeamDeathmatch")
		end)

		if not isGamemodeSetup then
			error("Failed to setup gamemode" .. message)
		end

		print("game started, gamemode setup")

		gameState = "Playing"

		GamemodeFinished.Event:Wait()

		gameState = "Ended"

		print("Game ended, new gamemode starting")
	end
end

task.spawn(serverGameLoopAsync)
