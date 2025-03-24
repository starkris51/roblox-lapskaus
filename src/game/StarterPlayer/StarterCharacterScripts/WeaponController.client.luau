--!strict
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local WeaponConfig = require(ReplicatedStorage.Config.WeaponConfig)
local Players = game:GetService("Players")

-- local KillPlayer: RemoteEvent = ReplicatedStorage.Events.KillPlayer
-- local RespawnPlayers: RemoteEvent = ReplicatedStorage.Events.RespawnPlayer

local player: Player = Players.LocalPlayer
--local character: Model = player.Character or player.CharacterAdded:Wait()
local mouse: Mouse = player:GetMouse()

local FireEvent: RemoteEvent = ReplicatedStorage.Events.FireWeapon :: RemoteEvent

local canFire: boolean = true

local function fire()
	if not canFire then
		return
	end

	local viewmodel: Model = workspace:FindFirstChild("viewmodel") :: Model
	local arm: BasePart = viewmodel:FindFirstChild("RightArm") :: BasePart
	local origin: Vector3 = arm.Position
	local direction: Vector3 = (mouse.Hit.Position - origin).Unit
	-- local humanoidRootPart: BasePart = character:FindFirstChild("HumanoidRootPart") :: BasePart

	-- local linearVel: LinearVelocity? = humanoidRootPart:FindFirstChildOfClass("LinearVelocity")
	-- if linearVel and direction.Y > -0.5 then
	-- 	local horizontalDirection: Vector2 = -Vector2.new(direction.X, direction.Z).Unit
	-- 	linearVel.PlaneVelocity = linearVel.PlaneVelocity + horizontalDirection * WeaponConfig.knockbackForce
	-- end

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

-- KillPlayer.OnClientEvent:Connect(function()
-- 	canFire = false
-- end)

-- RespawnPlayers.OnClientEvent:Connect(function()
-- 	canFire = true
-- end)
