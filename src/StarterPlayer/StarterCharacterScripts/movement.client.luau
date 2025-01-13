--!strict
local RunService: RunService = game:GetService("RunService")
local Players: Players = game:GetService("Players")

local player: Player = Players.LocalPlayer :: Player
local character: Model = player.Character or player.CharacterAdded:Wait()

local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local root = character:WaitForChild("HumanoidRootPart") :: Part
local rootAttachment = root:WaitForChild("RootAttachment") :: Attachment

local linearVelocity = Instance.new("LinearVelocity", root) :: LinearVelocity

linearVelocity.Attachment0 = rootAttachment
linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
linearVelocity.PrimaryTangentAxis = Vector3.new(1, 0, 0)
linearVelocity.SecondaryTangentAxis = Vector3.new(0, 0, 1)
linearVelocity.MaxForce = 10000

local function updateMovement(dt: number)
	local moveDirection: Vector3 = humanoid.MoveDirection
	local targetVelocity: Vector2 = Vector2.new(moveDirection.X, moveDirection.Z) * 60
	local deltaVelocity: Vector2 = targetVelocity - linearVelocity.PlaneVelocity
	local accelerationRate: number = if moveDirection.Magnitude > 0 then 8 else 6

	linearVelocity.PlaneVelocity += deltaVelocity * accelerationRate * dt
end

RunService.RenderStepped:Connect(updateMovement)
