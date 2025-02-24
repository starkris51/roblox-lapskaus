local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local RespawnPlayers: RemoteEvent = ReplicatedStorage.Events.RespawnPlayer

local PlayerKillHandler = require(ReplicatedStorage.Modules.PlayerKillHandler)
--local Types = require(ReplicatedStorage.Types.Server)

local RespawnHandler = {}
local respawnTimers: { [Player]: number } = {}
local connections: { [Player]: RBXScriptConnection } = {}
local respawnPoints: { Part } = {}

local function startTimer(player: Player, startTime: number, respawnTime: number)
	if tick() - startTime >= respawnTime then
		RespawnHandler.respawn(player)
	end
end

function RespawnHandler.startRespawnTimer(player: Player, respawnTime: number)
	if respawnTimers[player] then
		return
	end

	local startTime = tick()
	respawnTimers[player] = startTime

	connections[player] = RunService.Heartbeat:Connect(function()
		startTimer(player, startTime, respawnTime)
	end)
end

function RespawnHandler.isRespawning(player: Player): boolean
	return respawnTimers[player] ~= nil
end

function RespawnHandler.setupRespawnPoints()
	respawnPoints = CollectionService:GetTagged("RespawnPoint") :: { Part }
end

function RespawnHandler.getRespawnPoint(): Part
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

		local respawnPoint = RespawnHandler.getRespawnPoint()
		if respawnPoint then
			local character = player.Character
			if character then
				character:SetPrimaryPartCFrame(respawnPoint.CFrame)
			end
		end
	end
end

return RespawnHandler
