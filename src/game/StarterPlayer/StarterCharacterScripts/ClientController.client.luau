--!strict
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientController = require(ReplicatedStorage.Modules.Client)
local ClientGamemodeManager = require(ReplicatedStorage.Modules.ClientGamemodeManager)

--local GivePlayerLapskaus: RemoteEvent = ReplicatedStorage.Events.GivePlayerLapskaus
local KillPlayer: RemoteEvent = ReplicatedStorage.Events.KillPlayer
local RespawnPlayers: RemoteEvent = ReplicatedStorage.Events.RespawnPlayer
local GamemodeSetup: RemoteEvent = ReplicatedStorage.Events.GamemodeSetup

RunService.RenderStepped:Connect(ClientController.update)

KillPlayer.OnClientEvent:Connect(ClientController.handleDeath)
RespawnPlayers.OnClientEvent:Connect(ClientController.respawn)
GamemodeSetup.OnClientEvent:Connect(ClientGamemodeManager.setupGamemode)
