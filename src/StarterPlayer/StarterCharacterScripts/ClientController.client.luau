--!strict
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientController = require(ReplicatedStorage.Modules.Client)
local GivePlayerLapskaus: RemoteEvent = ReplicatedStorage.Events.GivePlayerLapskaus

RunService.RenderStepped:Connect(ClientController.update)

GivePlayerLapskaus.OnClientEvent:Connect(ClientController.captureLapskaus)
