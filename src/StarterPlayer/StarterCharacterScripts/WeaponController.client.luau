local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponConfig = require(ReplicatedStorage.Config.WeaponConfig)
local Players = game:GetService("Players")

local player: Player = Players.LocalPlayer
local character: Model = player.Character or player.CharacterAdded:Wait()
local mouse: Mouse = player:GetMouse()

local FireEvent: RemoteEvent = ReplicatedStorage.Events.FireWeapon :: RemoteEvent

local function fire()
	local viewmodel: Model = workspace:FindFirstChild("viewmodel") :: Model
	local arm: BasePart = viewmodel:FindFirstChild("RightArm") :: BasePart
	local origin: Vector3 = arm.Position
	local direction: Vector3 = (mouse.Hit.Position - origin).Unit
	local humanoidRootPart: BasePart = character:FindFirstChild("HumanoidRootPart") :: BasePart

	local linearVel: LinearVelocity? = humanoidRootPart:FindFirstChildOfClass("LinearVelocity")
	if linearVel and direction.Y > -0.7 then
		local horizontalDirection: Vector2 = -Vector2.new(direction.X, direction.Z).Unit
		linearVel.PlaneVelocity = linearVel.PlaneVelocity + horizontalDirection * WeaponConfig.knockbackForce
	else
		humanoidRootPart:ApplyImpulse(-direction.Unit * WeaponConfig.knockbackForce * 2)
	end

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
