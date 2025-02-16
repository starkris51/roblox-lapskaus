local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player: Player = Players.LocalPlayer
local mouse: Mouse = player:GetMouse()

local FireEvent: RemoteEvent = ReplicatedStorage.Events.FireWeapon :: RemoteEvent

local function fire()
	local viewmodel: Model = workspace:FindFirstChild("viewmodel") :: Model
	local arm: BasePart = viewmodel:FindFirstChild("RightArm") :: BasePart
	local origin: Vector3 = arm.Position
	local direction: Vector3 = (mouse.Hit.Position - origin).Unit

	FireEvent:FireServer(origin, direction)
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		fire()
	end
end)
