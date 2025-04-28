--!strict
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local WeaponConfig = require(ReplicatedStorage.Config.WeaponConfig)
local Players = game:GetService("Players")
local ReloadFinished: RemoteEvent = ReplicatedStorage.Events:FindFirstChild("ReloadFinished") :: RemoteEvent

-- local KillPlayer: RemoteEvent = ReplicatedStorage.Events.KillPlayer
-- local RespawnPlayers: RemoteEvent = ReplicatedStorage.Events.RespawnPlayer

local player: Player = Players.LocalPlayer
--local character: Model = player.Character or player.CharacterAdded:Wait()
local mouse: Mouse = player:GetMouse()

local FireEvent: RemoteEvent = ReplicatedStorage.Events.FireWeapon :: RemoteEvent

local canFire: boolean = true

local viewmodel: Model = workspace:WaitForChild("viewmodel") :: Model
local animationController: AnimationController =
	viewmodel:FindFirstChildOfClass("AnimationController") :: AnimationController
local rifle = viewmodel.PrimaryPart :: BasePart
local animator: Animator = animationController:FindFirstChildOfClass("Animator") :: Animator
local reload: Animation = viewmodel:FindFirstChild("Reload") :: Animation
local animationTrack = animator:LoadAnimation(reload) :: AnimationTrack

local function fire()
	if not canFire then
		return
	end

	canFire = false

	local origin: Vector3 = rifle.Position
	local direction: Vector3 = (mouse.Hit.Position - origin).Unit

	FireEvent:FireServer(origin, direction)
	animationTrack:Play()
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		fire()
	end
end)

ReloadFinished.OnClientEvent:Connect(function()
	canFire = true
end)
