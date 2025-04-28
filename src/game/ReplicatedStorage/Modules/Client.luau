--!strict
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MovementConfig = require(ReplicatedStorage.Config.MovementConfig)

local player = Players.LocalPlayer :: Player
local character: Model = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
local root: Part = character:WaitForChild("HumanoidRootPart") :: Part
local rootAttachment: Attachment = root:FindFirstChild("RootAttachment") :: Attachment
local camera = Workspace.CurrentCamera :: Camera

local rifle: Model = ReplicatedStorage.Assets.Lapskaus_Rifle:Clone()
local rifleBasePart = rifle.PrimaryPart :: BasePart
rifle.Parent = workspace
rifle.Name = "viewmodel"

local rifleOffset: CFrame = CFrame.new(2, -1, -3.5) * CFrame.Angles(0, math.rad(-5), 0)

local linearVelocity = Instance.new("LinearVelocity", root) :: LinearVelocity
linearVelocity.Attachment0 = rootAttachment
linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
linearVelocity.PrimaryTangentAxis = MovementConfig.PrimaryTangentAxis
linearVelocity.SecondaryTangentAxis = MovementConfig.SecondaryTangentAxis
linearVelocity.MaxForce = MovementConfig.MaxForce

local movementEnabled: boolean = true

local function updateViewmodel(dt: number)
	rifleBasePart.CFrame = camera.CFrame * rifleOffset
end

local function updateMovement(dt: number)
	if not movementEnabled then
		return
	end

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

local ClientController = {}

function ClientController.update(dt: number)
	updateMovement(dt)
	updateViewmodel(dt)
end

function ClientController.handleDeath()
	movementEnabled = false
	rifle.Parent = nil
	camera.CameraType = Enum.CameraType.Scriptable
	local thirdPersonOffset: CFrame = CFrame.new(0, 5, 24)
	camera.CFrame = root.CFrame * thirdPersonOffset
	--UserInputService.MouseIcon = nil
end

function ClientController.respawn()
	movementEnabled = true

	camera.CameraType = Enum.CameraType.Custom
	camera.CFrame = root.CFrame
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	UserInputService.MouseIcon = "rbxassetid://105533423449519"
end

return ClientController
