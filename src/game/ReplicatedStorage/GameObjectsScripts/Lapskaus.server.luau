--!strict
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local RequestLapskaus: BindableFunction = ServerScriptService.Events.RequestLapskaus
local ResetLapskaus: BindableEvent = ServerScriptService.Events.ResetLapskaus

local model: any = script.Parent
local surface: Part = model.Surface :: Part
local team: string = model:GetAttribute("Team") :: string
local lapskaus: Model = model["Lapskaus" .. team] :: Model

local AllignPositionSetup: AlignPosition = Instance.new("AlignPosition")
AllignPositionSetup.Name = "LapskausAlignPosition"
AllignPositionSetup.MaxForce = 10000
AllignPositionSetup.Responsiveness = 100
AllignPositionSetup.ApplyAtCenterOfMass = false
AllignPositionSetup.RigidityEnabled = false

-- Configuration
local DETECTION_RANGE: number = 7
local FOLLOW_HEIGHT_OFFSET: number = 5

local playersInArea = {}
local currentCarrier: Player? = nil
local alignPosition: AlignPosition? = nil
local lapskausPrimaryPart: MeshPart? = nil

local function setupLapskausFollowing(player: Player)
	if not player.Character then
		warn("Player character not found")
		return
	end

	if not lapskaus.PrimaryPart then
		warn("Lapskaus model does not have a PrimaryPart")
		return
	end

	lapskausPrimaryPart = lapskaus.PrimaryPart :: MeshPart
	if not lapskausPrimaryPart then
		warn("Lapskaus primary part not found")
		return
	end

	local lapskausAttachment: Attachment? = lapskausPrimaryPart:FindFirstChild("LapskausAttachment") :: Attachment
	if not lapskausAttachment then
		warn("LapskausAttachment not found in Lapskaus")
		return
	end

	local humanoidRootPart: Part = player.Character:FindFirstChild("HumanoidRootPart") :: Part
	if not humanoidRootPart then
		warn("HumanoidRootPart not found in character")
		return
	end

	local playerAttachment: Attachment = humanoidRootPart:FindFirstChild("PlayerLapskausAttachment") :: Attachment
	if not playerAttachment then
		warn("PlayerLapskausAttachment not found in HumanoidRootPart")
		return
	end

	playerAttachment.Position = Vector3.new(0, FOLLOW_HEIGHT_OFFSET, 0)

	alignPosition = AllignPositionSetup:Clone()
	if not alignPosition then
		warn("Failed to clone AlignPosition")
		return
	end

	alignPosition.Attachment0 = lapskausAttachment
	alignPosition.Attachment1 = playerAttachment
	alignPosition.Parent = lapskausPrimaryPart

	for _, part: Instance in pairs(lapskaus:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
			part.Anchored = false
		end
	end

	currentCarrier = player
	lapskaus.Parent = workspace

	return true
end

local function resetLapskaus()
	if alignPosition then
		alignPosition:Destroy()
		alignPosition = nil
	end

	for _, part: Instance in pairs(lapskaus:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = true
			part.Anchored = true
		end
	end

	lapskaus:PivotTo(surface.CFrame)

	lapskaus.Parent = model
	currentCarrier = nil
end

local function isPlayerInArea(player: Player): boolean
	local character: Model? = player.Character
	if not character then
		return false
	end

	local humanoidRootPart: BasePart? = character:FindFirstChild("HumanoidRootPart") :: BasePart
	if not humanoidRootPart then
		return false
	end

	local distance: number = (humanoidRootPart.Position - surface.Position).Magnitude
	return distance <= DETECTION_RANGE
end

local function checkArea()
	for _, player in ipairs(Players:GetPlayers()) do
		local inArea: boolean = isPlayerInArea(player)

		if inArea and not playersInArea[player] then
			playersInArea[player] = true
			local canTake: boolean = RequestLapskaus:Invoke(player, team) :: boolean
			if canTake then
				setupLapskausFollowing(player)
			end
		elseif not inArea and playersInArea[player] then
			playersInArea[player] = nil
		end
	end
end

local function onPlayerRemoving(player: Player)
	playersInArea[player] = nil

	if currentCarrier == player then
		resetLapskaus()
	end
end

local areaCheckConnection: RBXScriptConnection = RunService.Heartbeat:Connect(function()
	checkArea()
end)

Players.PlayerRemoving:Connect(onPlayerRemoving)
ResetLapskaus.Event:Connect(function(resetTeam: string)
	if resetTeam == team then
		resetLapskaus()
	end
end)

script.Destroying:Connect(function()
	areaCheckConnection:Disconnect()
	resetLapskaus()
end)
