--!strict
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace: Workspace = game:GetService("Workspace")
local Players: Players = game:GetService("Players")
local UserInputService: UserInputService = game:GetService("UserInputService")
local MovementConfig = require(game.ReplicatedStorage.Config.MovementConfig)

export type PlayerControllerProperties = {
	--PlayerModel
	viewmodel: Model,
	humanoidRootPart: Part,
	character: Model,
	humanoid: Humanoid,
	root: Part,
	rootAttachment: Attachment,
	linearVelocity: LinearVelocity,
	camera: Camera,
	--PlayerData
}

export type PlayerControllerImpl = {
	__index: PlayerControllerImpl,
	new: () -> PlayerController,
	updateViewmodel: (self: PlayerController, dt: number) -> (),
	updateMovement: (self: PlayerController, dt: number) -> (),
	updateCamera: (self: PlayerController, dt: number) -> (),
	equipWeapon: (self: PlayerController) -> (),
	update: (self: PlayerController, dt: number) -> (),
}

export type PlayerController = typeof(setmetatable({} :: PlayerControllerProperties, {} :: PlayerControllerImpl))

local PlayerController: PlayerControllerImpl = {} :: PlayerControllerImpl
PlayerController.__index = PlayerController

function PlayerController.new(): PlayerController
	local self: PlayerControllerProperties = {} :: PlayerControllerProperties
	self.viewmodel = ReplicatedStorage:WaitForChild("viewmodel"):Clone() :: Model
	self.humanoidRootPart = self.viewmodel:WaitForChild("HumanoidRootPart") :: Part
	self.viewmodel.Parent = Workspace

	local player: Player = Players.LocalPlayer :: Player
	self.character = player.Character or player.CharacterAdded:Wait()
	self.humanoid = self.character:WaitForChild("Humanoid") :: Humanoid
	self.root = self.character:WaitForChild("HumanoidRootPart") :: Part
	self.rootAttachment = self.root:WaitForChild("RootAttachment") :: Attachment
	self.camera = Workspace.CurrentCamera :: Camera

	self.linearVelocity = Instance.new("LinearVelocity", self.root) :: LinearVelocity
	self.linearVelocity.Attachment0 = self.rootAttachment
	self.linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	self.linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	self.linearVelocity.PrimaryTangentAxis = MovementConfig.PrimaryTangentAxis
	self.linearVelocity.SecondaryTangentAxis = MovementConfig.SecondaryTangentAxis
	self.linearVelocity.MaxForce = MovementConfig.MaxForce

	UserInputService.MouseIconEnabled = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	player.CameraMode = Enum.CameraMode.LockFirstPerson

	return setmetatable(self, PlayerController)
end

function PlayerController:updateViewmodel(dt: number)
	self.humanoidRootPart.CFrame = self.camera.CFrame
end

function PlayerController:updateMovement(dt: number)
	local moveDirection: Vector3 = self.humanoid.MoveDirection
	local targetVelocity: Vector2 = Vector2.new(moveDirection.X, moveDirection.Z)
		* MovementConfig.TargetVelocityMultiplier
	local deltaVelocity: Vector2 = targetVelocity - self.linearVelocity.PlaneVelocity
	local accelerationRate: number = if moveDirection.Magnitude > 0
		then MovementConfig.AccelerationRateMoving
		else MovementConfig.AccelerationRateStopping

	self.linearVelocity.PlaneVelocity += deltaVelocity * accelerationRate * dt
end

function PlayerController:update(dt: number)
	self:updateMovement(dt)
	self:updateViewmodel(dt)
end

return PlayerController
