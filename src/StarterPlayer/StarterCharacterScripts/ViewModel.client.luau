--!strict
local RunService: RunService = game:GetService("RunService")
-- local PhysicsService: PhysicsService = game:GetService("PhysicsService")
local Players: Players = game:GetService("Players")
local player: Player = Players.LocalPlayer :: Player

local parent = script.Parent
if not parent:IsA("Model") then
	error("Parent is not a Model")
end

local characterModel: Model = parent :: Model
--local humanoid: Humanoid = characterModel:WaitForChild("Humanoid") :: Humanoid

--local Animator: Animator = humanoid:WaitForChild("Animator") :: Animator

local camera: Camera = workspace:WaitForChild("Camera") :: Camera
local oldViewModel: Model = camera:FindFirstChild("ViewModel") :: Model
if oldViewModel then
	oldViewModel:Destroy()
end

characterModel.Archivable = true
local viewModel: Model = characterModel:Clone() :: Model
viewModel.Parent = camera
viewModel.Name = "viewModel"
characterModel.Archivable = false

local viewModelHumanoid: Humanoid = viewModel:WaitForChild("Humanoid") :: Humanoid

--local ViewModelAnimator: Animator = viewModelHumanoid:WaitForChild("Animator") :: Animator
viewModelHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
viewModelHumanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
viewModelHumanoid.BreakJointsOnDeath = false

viewModel:PivotTo(CFrame.new(0, 5, 0))

for _, Part in pairs(viewModel:GetDescendants()) do
	if Part:IsA("BasePart") then
		Part.CastShadow = false

		local LowerName: string = Part.Name:lower()
		if LowerName:match("leg") or LowerName:match("foot") then
			Part:Destroy()
		elseif not (LowerName:match("arm") or LowerName:match("hand")) then
			Part.Transparency = 1
		end
	elseif Part:IsA("Decal") then
		Part:Destroy()
	elseif Part:IsA("Accessory") then
		Part:Destroy()
	elseif Part:IsA("LocalScript") then
		Part:Destroy()
	end
end

local function updateViewModel(dt: number)
	viewModel.PivotTo(viewModel, camera.CFrame)
end

RunService.RenderStepped:Connect(updateViewModel)
