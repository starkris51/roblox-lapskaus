--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local viewmodel: Model = ReplicatedStorage:WaitForChild("viewmodel"):Clone() :: Model
viewmodel.Parent = Workspace
local humanoidRootPart: Part = viewmodel:WaitForChild("HumanoidRootPart") :: Part

local function updateViewmodel()
	humanoidRootPart.CFrame = Workspace.Camera.CFrame
end

RunService.RenderStepped:Connect(updateViewmodel)
