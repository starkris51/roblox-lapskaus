--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local viewmodel = ReplicatedStorage:WaitForChild("viewmodel"):Clone()
viewmodel.Parent = Workspace.Camera :: any

local function updateViewmodel()
	viewmodel.HumanoidRootPart.CFrame = Workspace.Camera.CFrame
end

RunService.RenderStepped:Connect(updateViewmodel)
