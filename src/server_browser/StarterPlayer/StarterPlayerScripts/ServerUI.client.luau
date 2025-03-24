--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GetServerList = ReplicatedStorage.Events.GetServerList
local JoinServer = ReplicatedStorage.Events.JoinServer

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Constants
local REFRESH_INTERVAL = 5
local MAX_SERVERS_DISPLAYED = 10
local UI_COLORS = {
	Background = Color3.fromRGB(36, 36, 36),
	Header = Color3.fromRGB(45, 45, 45),
	Button = Color3.fromRGB(59, 59, 59),
	ButtonHover = Color3.fromRGB(79, 79, 79),
	Text = Color3.fromRGB(255, 255, 255),
	ServerAvailable = Color3.fromRGB(76, 175, 80),
	ServerFull = Color3.fromRGB(244, 67, 54),
	LoadingBar = Color3.fromRGB(52, 152, 219),
}

-- Types
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

-- Create UI
local function createServerBrowserUI()
	local serverBrowserGui = Instance.new("ScreenGui")
	serverBrowserGui.Name = "ServerBrowserGui"
	serverBrowserGui.ResetOnSpawn = false
	serverBrowserGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 700, 0, 500)
	mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
	mainFrame.BackgroundColor3 = UI_COLORS.Background
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = serverBrowserGui

	local cornerRadius = Instance.new("UICorner")
	cornerRadius.CornerRadius = UDim.new(0, 6)
	cornerRadius.Parent = mainFrame

	local headerFrame = Instance.new("Frame")
	headerFrame.Name = "Header"
	headerFrame.Size = UDim2.new(1, 0, 0, 50)
	headerFrame.BackgroundColor3 = UI_COLORS.Header
	headerFrame.BorderSizePixel = 0
	headerFrame.Parent = mainFrame

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 6)
	headerCorner.Parent = headerFrame

	local cornerFix = Instance.new("Frame")
	cornerFix.Name = "CornerFix"
	cornerFix.Size = UDim2.new(1, 0, 0, 20)
	cornerFix.Position = UDim2.new(0, 0, 1, -20)
	cornerFix.BackgroundColor3 = UI_COLORS.Header
	cornerFix.BorderSizePixel = 0
	cornerFix.ZIndex = 0
	cornerFix.Parent = headerFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(0, 200, 0, 50)
	titleLabel.Position = UDim2.new(0, 20, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = "Lapskaus Servers"
	titleLabel.TextColor3 = UI_COLORS.Text
	titleLabel.TextSize = 24
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = headerFrame

	local refreshButton = Instance.new("TextButton")
	refreshButton.Name = "RefreshButton"
	refreshButton.Size = UDim2.new(0, 100, 0, 30)
	refreshButton.Position = UDim2.new(1, -120, 0, 10)
	refreshButton.BackgroundColor3 = UI_COLORS.Button
	refreshButton.BorderSizePixel = 0
	refreshButton.Font = Enum.Font.Gotham
	refreshButton.Text = "Refresh"
	refreshButton.TextColor3 = UI_COLORS.Text
	refreshButton.TextSize = 16
	refreshButton.AutoButtonColor = false
	refreshButton.Parent = headerFrame

	local refreshCorner = Instance.new("UICorner")
	refreshCorner.CornerRadius = UDim.new(0, 4)
	refreshCorner.Parent = refreshButton

	local createServerButton = Instance.new("TextButton")
	createServerButton.Name = "CreateServerButton"
	createServerButton.Size = UDim2.new(0, 120, 0, 30)
	createServerButton.Position = UDim2.new(1, -250, 0, 10)
	createServerButton.BackgroundColor3 = UI_COLORS.Button
	createServerButton.BorderSizePixel = 0
	createServerButton.Font = Enum.Font.Gotham
	createServerButton.Text = "Create Server"
	createServerButton.TextColor3 = UI_COLORS.Text
	createServerButton.TextSize = 16
	createServerButton.AutoButtonColor = false
	createServerButton.Parent = headerFrame

	local createServerCorner = Instance.new("UICorner")
	createServerCorner.CornerRadius = UDim.new(0, 4)
	createServerCorner.Parent = createServerButton

	local serverListFrame = Instance.new("ScrollingFrame")
	serverListFrame.Name = "ServerList"
	serverListFrame.Size = UDim2.new(1, -40, 1, -70)
	serverListFrame.Position = UDim2.new(0, 20, 0, 60)
	serverListFrame.BackgroundTransparency = 1
	serverListFrame.BorderSizePixel = 0
	serverListFrame.ScrollBarThickness = 6
	serverListFrame.ScrollBarImageColor3 = UI_COLORS.Button
	serverListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	serverListFrame.Parent = mainFrame

	local serverListLayout = Instance.new("UIListLayout")
	serverListLayout.Padding = UDim.new(0, 10)
	serverListLayout.Parent = serverListFrame

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, 0, 0, 30)
	statusLabel.Position = UDim2.new(0, 0, 1, -40)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.Text = ""
	statusLabel.TextColor3 = UI_COLORS.Text
	statusLabel.TextSize = 14
	statusLabel.Parent = mainFrame

	serverBrowserGui.Parent = playerGui

	return {
		gui = serverBrowserGui,
		mainFrame = mainFrame,
		serverList = serverListFrame,
		refreshButton = refreshButton,
		statusLabel = statusLabel,
		createServerButton = createServerButton,
	}
end

-- Create a server entry UI element
local function createServerEntry(serverInfo: ServerInfo)
	local serverEntry = Instance.new("Frame")
	serverEntry.Name = "ServerEntry_" .. serverInfo.id
	serverEntry.Size = UDim2.new(1, 0, 0, 80)
	serverEntry.BackgroundColor3 = UI_COLORS.Button
	serverEntry.BorderSizePixel = 0

	local entryCorner = Instance.new("UICorner")
	entryCorner.CornerRadius = UDim.new(0, 4)
	entryCorner.Parent = serverEntry

	local serverName = Instance.new("TextLabel")
	serverName.Name = "ServerName"
	serverName.Size = UDim2.new(0, 350, 0, 30)
	serverName.Position = UDim2.new(0, 15, 0, 10)
	serverName.BackgroundTransparency = 1
	serverName.Font = Enum.Font.GothamBold
	serverName.Text = serverInfo.name
	serverName.TextColor3 = UI_COLORS.Text
	serverName.TextSize = 18
	serverName.TextXAlignment = Enum.TextXAlignment.Left
	serverName.Parent = serverEntry

	local gameInfo = Instance.new("TextLabel")
	gameInfo.Name = "GameInfo"
	gameInfo.Size = UDim2.new(0, 350, 0, 20)
	gameInfo.Position = UDim2.new(0, 15, 0, 40)
	gameInfo.BackgroundTransparency = 1
	gameInfo.Font = Enum.Font.Gotham
	gameInfo.Text = string.format("Map: %s | Mode: %s", serverInfo.mapName, serverInfo.gamemode)
	gameInfo.TextColor3 = UI_COLORS.Text
	gameInfo.TextSize = 14
	gameInfo.TextXAlignment = Enum.TextXAlignment.Left
	gameInfo.TextTransparency = 0.2
	gameInfo.Parent = serverEntry

	local playerCount = Instance.new("TextLabel")
	playerCount.Name = "PlayerCount"
	playerCount.Size = UDim2.new(0, 100, 0, 20)
	playerCount.Position = UDim2.new(1, -205, 0, 15)
	playerCount.BackgroundTransparency = 1
	playerCount.Font = Enum.Font.Gotham
	playerCount.Text = string.format("Players: %d/%d", serverInfo.playerCount, serverInfo.maxPlayers)
	playerCount.TextColor3 = UI_COLORS.Text
	playerCount.TextSize = 14
	playerCount.Parent = serverEntry

	local playerCountColor = (serverInfo.playerCount < serverInfo.maxPlayers) and UI_COLORS.ServerAvailable
		or UI_COLORS.ServerFull

	local playerBar = Instance.new("Frame")
	playerBar.Name = "PlayerBar"
	playerBar.Size = UDim2.new(0, 100, 0, 8)
	playerBar.Position = UDim2.new(1, -205, 0, 40)
	playerBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	playerBar.BorderSizePixel = 0
	playerBar.Parent = serverEntry

	local playerBarCorner = Instance.new("UICorner")
	playerBarCorner.CornerRadius = UDim.new(0, 4)
	playerBarCorner.Parent = playerBar

	local playerBarFill = Instance.new("Frame")
	playerBarFill.Name = "PlayerBarFill"
	playerBarFill.Size = UDim2.new(serverInfo.playerCount / serverInfo.maxPlayers, 0, 1, 0)
	playerBarFill.BackgroundColor3 = playerCountColor
	playerBarFill.BorderSizePixel = 0
	playerBarFill.Parent = playerBar

	local playerBarFillCorner = Instance.new("UICorner")
	playerBarFillCorner.CornerRadius = UDim.new(0, 4)
	playerBarFillCorner.Parent = playerBarFill

	local joinButton = Instance.new("TextButton")
	joinButton.Name = "JoinButton"
	joinButton.Size = UDim2.new(0, 80, 0, 30)
	joinButton.Position = UDim2.new(1, -90, 0, 25)
	joinButton.BackgroundColor3 = UI_COLORS.Button
	joinButton.BorderSizePixel = 0
	joinButton.Font = Enum.Font.GothamBold
	joinButton.Text = "JOIN"
	joinButton.TextColor3 = UI_COLORS.Text
	joinButton.TextSize = 14
	joinButton.AutoButtonColor = false
	joinButton.Parent = serverEntry

	local joinButtonCorner = Instance.new("UICorner")
	joinButtonCorner.CornerRadius = UDim.new(0, 4)
	joinButtonCorner.Parent = joinButton

	-- Button hover effect
	joinButton.MouseEnter:Connect(function()
		TweenService:Create(joinButton, TweenInfo.new(0.2), { BackgroundColor3 = UI_COLORS.ButtonHover }):Play()
	end)

	joinButton.MouseLeave:Connect(function()
		TweenService:Create(joinButton, TweenInfo.new(0.2), { BackgroundColor3 = UI_COLORS.Button }):Play()
	end)

	-- Join server functionality
	joinButton.MouseButton1Click:Connect(function()
		local success, message = JoinServer:InvokeServer(serverInfo.id)
		if success then
			-- Show loading indicator
			joinButton.Text = "..."
		else
			error(message)
		end
	end)

	return serverEntry
end

-- Refresh the server list
local function refreshServerList(ui: any)
	-- Show loading indicator
	ui.statusLabel.Text = "Loading servers..."

	-- Clear existing server entries
	for _, child in ipairs(ui.serverList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Get the server list from the server
	local success, result = pcall(function()
		return GetServerList:InvokeServer()
	end)

	if not success then
		ui.statusLabel.Text = "Failed to load server list"
		task.delay(3, function()
			ui.statusLabel.Text = ""
		end)
		return
	end

	-- Sort servers (by player count descending)
	table.sort(result, function(a, b)
		return a.playerCount > b.playerCount
	end)

	-- Create server entries
	for i, serverInfo in ipairs(result) do
		if i <= MAX_SERVERS_DISPLAYED then
			local serverEntry = createServerEntry(serverInfo)
			serverEntry.Parent = ui.serverList
		end
	end

	-- Update scrolling frame canvas size
	ui.serverList.CanvasSize = UDim2.new(0, 0, 0, ui.serverList.UIListLayout.AbsoluteContentSize.Y)

	-- Clear loading indicator
	ui.statusLabel.Text = string.format("Found %d servers", #result)
	task.delay(3, function()
		ui.statusLabel.Text = ""
	end)
end

-- Main function
local function main()
	local ui = createServerBrowserUI()

	-- Set up refresh button
	ui.refreshButton.MouseEnter:Connect(function()
		TweenService:Create(ui.refreshButton, TweenInfo.new(0.2), { BackgroundColor3 = UI_COLORS.ButtonHover }):Play()
	end)

	ui.refreshButton.MouseLeave:Connect(function()
		TweenService:Create(ui.refreshButton, TweenInfo.new(0.2), { BackgroundColor3 = UI_COLORS.Button }):Play()
	end)

	ui.refreshButton.MouseButton1Click:Connect(function()
		refreshServerList(ui)
	end)

	ui.createServerButton.MouseEnter:Connect(function()
		TweenService:Create(ui.createServerButton, TweenInfo.new(0.2), { BackgroundColor3 = UI_COLORS.ButtonHover })
			:Play()
	end)

	ui.createServerButton.MouseLeave:Connect(function()
		TweenService:Create(ui.createServerButton, TweenInfo.new(0.2), { BackgroundColor3 = UI_COLORS.Button }):Play()
	end)

	ui.createServerButton.MouseButton1Click:Connect(function()
		-- Create a simple dialog for server creation
		local createDialog = Instance.new("Frame")
		createDialog.Name = "CreateServerDialog"
		createDialog.Size = UDim2.new(0, 300, 0, 200)
		createDialog.Position = UDim2.new(0.5, -150, 0.5, -100)
		createDialog.BackgroundColor3 = UI_COLORS.Background
		createDialog.BorderSizePixel = 0
		createDialog.ZIndex = 10
		createDialog.Parent = ui.gui

		local dialogCorner = Instance.new("UICorner")
		dialogCorner.CornerRadius = UDim.new(0, 6)
		dialogCorner.Parent = createDialog

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, 0, 0, 40)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.Text = "Create New Server"
		titleLabel.TextColor3 = UI_COLORS.Text
		titleLabel.TextSize = 18
		titleLabel.Parent = createDialog

		local serverNameLabel = Instance.new("TextLabel")
		serverNameLabel.Size = UDim2.new(0, 100, 0, 30)
		serverNameLabel.Position = UDim2.new(0, 20, 0, 50)
		serverNameLabel.BackgroundTransparency = 1
		serverNameLabel.Font = Enum.Font.Gotham
		serverNameLabel.Text = "Server Name:"
		serverNameLabel.TextColor3 = UI_COLORS.Text
		serverNameLabel.TextSize = 14
		serverNameLabel.TextXAlignment = Enum.TextXAlignment.Left
		serverNameLabel.Parent = createDialog

		local serverNameInput = Instance.new("TextBox")
		serverNameInput.Size = UDim2.new(0, 200, 0, 30)
		serverNameInput.Position = UDim2.new(0, 50, 0, 80)
		serverNameInput.BackgroundColor3 = UI_COLORS.Button
		serverNameInput.BorderSizePixel = 0
		serverNameInput.Font = Enum.Font.Gotham
		serverNameInput.PlaceholderText = "Enter server name..."
		serverNameInput.Text = player.Name .. "'s Server"
		serverNameInput.TextColor3 = UI_COLORS.Text
		serverNameInput.TextSize = 14
		serverNameInput.Parent = createDialog

		local inputCorner = Instance.new("UICorner")
		inputCorner.CornerRadius = UDim.new(0, 4)
		inputCorner.Parent = serverNameInput

		local createButton = Instance.new("TextButton")
		createButton.Size = UDim2.new(0, 100, 0, 30)
		createButton.Position = UDim2.new(0.5, -50, 1, -50)
		createButton.BackgroundColor3 = UI_COLORS.Button
		createButton.BorderSizePixel = 0
		createButton.Font = Enum.Font.GothamBold
		createButton.Text = "CREATE"
		createButton.TextColor3 = UI_COLORS.Text
		createButton.TextSize = 14
		createButton.Parent = createDialog

		local createButtonCorner = Instance.new("UICorner")
		createButtonCorner.CornerRadius = UDim.new(0, 4)
		createButtonCorner.Parent = createButton

		local cancelButton = Instance.new("TextButton")
		cancelButton.Size = UDim2.new(0, 80, 0, 25)
		cancelButton.Position = UDim2.new(1, -90, 0, 10)
		cancelButton.BackgroundTransparency = 1
		cancelButton.Font = Enum.Font.Gotham
		cancelButton.Text = "Cancel"
		cancelButton.TextColor3 = UI_COLORS.Text
		cancelButton.TextSize = 14
		cancelButton.Parent = createDialog

		-- Button functionality
		createButton.MouseEnter:Connect(function()
			TweenService:Create(createButton, TweenInfo.new(0.2), { BackgroundColor3 = UI_COLORS.ButtonHover }):Play()
		end)

		createButton.MouseLeave:Connect(function()
			TweenService:Create(createButton, TweenInfo.new(0.2), { BackgroundColor3 = UI_COLORS.Button }):Play()
		end)

		cancelButton.MouseButton1Click:Connect(function()
			createDialog:Destroy()
		end)

		createButton.MouseButton1Click:Connect(function()
			local serverName = serverNameInput.Text
			if serverName:len() < 3 then
				serverNameInput.PlaceholderText = "Name too short!"
				serverNameInput.Text = ""
				return
			end

			createDialog:Destroy()
			ui.statusLabel.Text = "Creating server..."

			local CreateServer = ReplicatedStorage.Events.CreateServer
			local success, message = CreateServer:InvokeServer(serverName, "CaptureTheLapskaus")

			if not success then
				ui.statusLabel.Text = message or "Failed to create server"
				task.delay(3, function()
					ui.statusLabel.Text = ""
				end)
			end
		end)
	end)

	-- Initial refresh
	refreshServerList(ui)

	-- Auto refresh timer
	task.spawn(function()
		while true do
			task.wait(REFRESH_INTERVAL)
			refreshServerList(ui)
		end
	end)
end

main()
