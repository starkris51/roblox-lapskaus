local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player: Player = Players.LocalPlayer
local character: Model = player.Character or player.CharacterAdded:Wait()
local mouse: Mouse = player:GetMouse()

local FireEvent: RemoteEvent = ReplicatedStorage.Events.FireWeapon :: RemoteEvent

local function fire()
	local head: MeshPart = character:FindFirstChild("Head") :: MeshPart
	local origin: Vector3 = head.Position
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
