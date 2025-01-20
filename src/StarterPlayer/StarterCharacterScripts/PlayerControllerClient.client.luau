--!strict
local PlayerControllerModule = require(game.ReplicatedStorage.Modules.PlayerController)
local UserInputService: UserInputService = game:GetService("UserInputService")
local RunService: RunService = game:GetService("RunService")

type PlayerController = PlayerControllerModule.PlayerController

local playerController: PlayerController = PlayerControllerModule.new()

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		playerController:equipWeapon()
	end
end)

RunService.RenderStepped:Connect(function(dt: number)
	playerController:update(dt)
end)
