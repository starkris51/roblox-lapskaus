--!strict
local PlayerControllerModule = require(game.ReplicatedStorage.Modules.PlayerController)
--local UserInputService: UserInputService = game:GetService("UserInputService")
local RunService: RunService = game:GetService("RunService")

type PlayerController = PlayerControllerModule.PlayerController

local playerController: PlayerController = PlayerControllerModule.new()

RunService.RenderStepped:Connect(function(dt: number)
	playerController:update(dt)
end)
