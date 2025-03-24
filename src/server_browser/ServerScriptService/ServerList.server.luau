--!strict
local HttpService: HttpService = game:GetService("HttpService")
local MessagingService: MessagingService = game:GetService("MessagingService")
local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService: TeleportService = game:GetService("TeleportService")
local DataStoreService: DataStoreService = game:GetService("DataStoreService")

local GetServerList: RemoteFunction = ReplicatedStorage.Events.GetServerList
local JoinServer: RemoteFunction = ReplicatedStorage.Events.JoinServer
local CreateServer: RemoteFunction = ReplicatedStorage.Events.CreateServer

local SERVER_LIST_TOPIC: string = "LapskausServerList"
local SERVER_HEARTBEAT_INTERVAL: number = 30
local SERVER_TIMEOUT: number = 60
local GAME_PLACE_ID: number = 79705228739922
local IS_BROWSER: boolean = game.PlaceId ~= GAME_PLACE_ID
local DEBUG: boolean = true

local teleportStore: DataStore = DataStoreService:GetDataStore("LapskausTeleportData")

type ServerInfo = {
	id: string,
	name: string,
	playerCount: number,
	maxPlayers: number,
	gamemode: string,
	mapName: string,
	lastUpdate: number,
	placeId: number,
	accessCode: string?,
}

type ServerList = { [string]: ServerInfo }

type TeleportData = {
	sourceServerId: string,
	timestamp: number,
	playerName: string,
}

type MessageData = {
	Data: string,
}

local serverId: string = HttpService:GenerateGUID(false)
local placeId: number = GAME_PLACE_ID
local serverInfo: ServerInfo = {
	id = serverId,
	name = "Lapskaus Server",
	playerCount = 0,
	maxPlayers = 16,
	gamemode = "CaptureTheLapskaus",
	mapName = "ctl_sandefjord",
	lastUpdate = os.time(),
	placeId = placeId,
	accessCode = nil,
}

local serverList: ServerList = {}

local function updateServerInfo(): ()
	if IS_BROWSER then
		return
	end

	serverInfo.playerCount = #Players:GetPlayers()
	serverInfo.lastUpdate = os.time()

	local success: boolean, error: string? = pcall(function()
		MessagingService:PublishAsync(SERVER_LIST_TOPIC, HttpService:JSONEncode(serverInfo))
	end)

	if not success and DEBUG then
		warn("Failed to publish server info: " .. (error or ""))
	end
end

local function onServerInfoReceived(message: MessageData): ()
	local success: boolean, receivedServer: ServerInfo? = pcall(function()
		return HttpService:JSONDecode(message.Data)
	end)

	if not success then
		if DEBUG then
			warn("Failed to decode server info")
		end
		return
	end

	if receivedServer and receivedServer.id == serverId then
		return
	end

	if receivedServer then
		serverList[receivedServer.id] = receivedServer
	end
end

local function cleanupInactiveServers(): ()
	local currentTime: number = os.time()
	for id: string, server: ServerInfo in pairs(serverList) do
		if currentTime - server.lastUpdate > SERVER_TIMEOUT then
			serverList[id] = nil
			if DEBUG then
				print("Removed inactive server: " .. id)
			end
		end
	end
end

local function getServerList(): { ServerInfo }
	cleanupInactiveServers()

	local servers: { ServerInfo } = {}
	for _, server: ServerInfo in pairs(serverList) do
		table.insert(servers, server)
	end

	if not IS_BROWSER then
		table.insert(servers, serverInfo)
	end
	return servers
end

local function joinServer(player: Player, serverIdToJoin: string): (boolean, string)
	local targetServer: ServerInfo? = nil
	for _, server: ServerInfo in pairs(serverList) do
		if server.id == serverIdToJoin then
			targetServer = server
			break
		end
	end

	if not targetServer then
		return false, "Server not found or no longer available"
	end

	local teleportData: TeleportData = {
		sourceServerId = serverId,
		timestamp = os.time(),
		playerName = player.Name,
	}

	local teleportOptions: TeleportOptions = Instance.new("TeleportOptions")

	if targetServer.accessCode then
		teleportOptions.ServerInstanceId = targetServer.accessCode
	end

	local reservationId: string = HttpService:GenerateGUID(false)
	local success: boolean, errorMsg: string? = pcall(function()
		teleportStore:SetAsync("teleport_" .. reservationId, teleportData, { player.UserId })
	end)

	if not success then
		warn("Failed to save teleport data: " .. (errorMsg or ""))
		return false, "Could not prepare teleport data"
	end

	teleportOptions:SetTeleportData({
		reservationId = reservationId,
		targetServerId = targetServer.id,
	})

	local teleportSuccess: boolean, teleportResult: TeleportAsyncResult? = pcall(function()
		return TeleportService:TeleportAsync(targetServer.placeId, { player }, teleportOptions)
	end)

	if teleportSuccess then
		return true, "Teleporting to server..."
	else
		return false, "Failed to teleport: " .. tostring(teleportResult or "")
	end
end

local function createGameServer(player: Player, serverName: string?, gamemode: string?): (boolean, string)
	local newServerName = serverName or player.Name .. "'s Server"
	local newGamemode = gamemode or "CaptureTheLapskaus"

	local teleportOptions = Instance.new("TeleportOptions")
	local reservationId = HttpService:GenerateGUID(false)

	local creationData = {
		reservationId = reservationId,
		creatorId = player.UserId,
		serverName = newServerName,
		gamemode = newGamemode,
		isNewServer = true,
		timestamp = os.time(),
	}

	local success, errorMsg = pcall(function()
		teleportStore:SetAsync("create_" .. reservationId, creationData, { player.UserId })
	end)

	if not success then
		warn("Failed to save server creation data: " .. (errorMsg or ""))
		return false, "Could not prepare server creation data"
	end

	teleportOptions:SetTeleportData(creationData)

	local teleportSuccess, teleportResult = pcall(function()
		return TeleportService:TeleportAsync(GAME_PLACE_ID, { player }, teleportOptions)
	end)

	if teleportSuccess then
		return true, "Creating and joining new server..."
	else
		return false, "Failed to create server: " .. tostring(teleportResult or "")
	end
end

GetServerList.OnServerInvoke = getServerList
JoinServer.OnServerInvoke = joinServer
CreateServer.OnServerInvoke = createGameServer

local function subscribeToMessagingService(): ()
	local success: boolean, error: string? = pcall(function()
		MessagingService:SubscribeAsync(SERVER_LIST_TOPIC, onServerInfoReceived)
	end)

	if not success then
		if DEBUG then
			warn("Failed to subscribe to messaging service: " .. (error or ""))
		end
		task.delay(5, subscribeToMessagingService)
	else
		if DEBUG then
			print("Successfully subscribed to messaging service")
		end
	end
end

task.spawn(function()
	subscribeToMessagingService()
end)

task.spawn(function()
	while true do
		updateServerInfo()
		cleanupInactiveServers()
		task.wait(SERVER_HEARTBEAT_INTERVAL)
	end
end)

Players.PlayerAdded:Connect(function()
	updateServerInfo()
end)

Players.PlayerRemoving:Connect(function()
	updateServerInfo()
end)

if DEBUG then
	print("Server browser initialized with ID: " .. serverId)
end
