--!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local RespawnPlayers: RemoteEvent = ReplicatedStorage.Events.RespawnPlayer

local PlayerKillHandler = require(ServerScriptService.Modules.PlayerKillHandler)
--local Types = require(ReplicatedStorage.Types.Server)

local RespawnHandler = {}
local respawnTimers: { [Player]: number | nil } = {}
local connections: { [Player]: RBXScriptConnection } = {}
local respawnPoints: { Instance } = {}

local function startTimer(player: Player, startTime: number, respawnTime: number)
	local currentTime: number = tick()
	if currentTime - startTime >= respawnTime then
		RespawnHandler.respawn(player)
	end
end

function RespawnHandler.startRespawnTimer(player: Player, respawnTime: number)
	if respawnTimers[player] then
		return
	end

	local startTime: number = tick()
	respawnTimers[player] = startTime

	connections[player] = RunService.Heartbeat:Connect(function()
		startTimer(player, startTime, respawnTime)
	end)
end

function RespawnHandler.isRespawning(player: Player): boolean
	return respawnTimers[player] ~= nil
end

function RespawnHandler.setupRespawnPoints()
	respawnPoints = CollectionService:GetTagged("RespawnPoint") :: { Instance }
end

function RespawnHandler.getRespawnPoint(): Instance?
	return respawnPoints[math.random(1, #respawnPoints)]
end

function RespawnHandler.cleanup()
	for player, _ in pairs(respawnTimers) do
		if connections[player] then
			connections[player]:Disconnect()
			connections[player] = nil
		end
	end
	respawnTimers = {}
end

function RespawnHandler.respawn(player: Player)
	if respawnTimers[player] then
		respawnTimers[player] = nil
		PlayerKillHandler.removeKilledPlayer(player)
		RespawnPlayers:FireClient(player)
		if connections[player] then
			connections[player]:Disconnect()
			connections[player] = nil
		end
	end

	local respawnPoint: Instance? = RespawnHandler.getRespawnPoint()
	local character: Model? = player.Character or player.CharacterAdded:Wait()

	if respawnPoint and character and respawnPoint:IsA("Part") then
		character:MoveTo(respawnPoint.Position + Vector3.new(0, 5, 0))
	end
end

return RespawnHandler
