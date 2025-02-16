--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local MovementConfig = require(game.ReplicatedStorage.Config.MovementConfig)

local player = Players.LocalPlayer :: Player
local character: Model = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
local root: Part = character:WaitForChild("HumanoidRootPart") :: Part
local rootAttachment: Attachment = root:FindFirstChild("RootAttachment") :: Attachment
local camera = Workspace.CurrentCamera :: Camera

local viewmodel: Model = ReplicatedStorage:FindFirstChild("viewmodel"):Clone() :: Model
local humanoidRootPart: Part = viewmodel:FindFirstChild("HumanoidRootPart") :: Part
viewmodel.Parent = Workspace

local linearVelocity = Instance.new("LinearVelocity", root) :: LinearVelocity
linearVelocity.Attachment0 = rootAttachment
linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
linearVelocity.PrimaryTangentAxis = MovementConfig.PrimaryTangentAxis
linearVelocity.SecondaryTangentAxis = MovementConfig.SecondaryTangentAxis
linearVelocity.MaxForce = MovementConfig.MaxForce

UserInputService.MouseIconEnabled = false
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
player.CameraMode = Enum.CameraMode.LockFirstPerson

local function updateViewmodel(dt: number)
	humanoidRootPart.CFrame = camera.CFrame
end

local function updateMovement(dt: number)
	-- Calculate the target velocity based on the humanoid's move direction
	local moveDirection: Vector3 = humanoid.MoveDirection
	local targetVelocity: Vector2 = Vector2.new(moveDirection.X, moveDirection.Z)
		* MovementConfig.TargetVelocityMultiplier

	-- Calculate the difference from current plane velocity
	local deltaVelocity: Vector2 = targetVelocity - linearVelocity.PlaneVelocity

	-- Choose an acceleration rate depending on whether there is input
	local accelerationRate: number = (moveDirection.Magnitude > 0) and MovementConfig.AccelerationRateMoving
		or MovementConfig.AccelerationRateStopping

	-- Update the plane velocity over time
	linearVelocity.PlaneVelocity = linearVelocity.PlaneVelocity + deltaVelocity * accelerationRate * dt
end

function update(dt: number)
	updateMovement(dt)
	updateViewmodel(dt)
end

RunService.RenderStepped:Connect(update)
