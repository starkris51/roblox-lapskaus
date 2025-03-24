--!strict
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientController = require(ReplicatedStorage.Modules.Client)
local GivePlayerLapskaus: RemoteEvent = ReplicatedStorage.Events.GivePlayerLapskaus
local KillPlayer: RemoteEvent = ReplicatedStorage.Events.KillPlayer
local RespawnPlayers: RemoteEvent = ReplicatedStorage.Events.RespawnPlayer

RunService.RenderStepped:Connect(ClientController.update)

GivePlayerLapskaus.OnClientEvent:Connect(ClientController.captureLapskaus)
KillPlayer.OnClientEvent:Connect(ClientController.handleDeath)
RespawnPlayers.OnClientEvent:Connect(ClientController.respawn)
