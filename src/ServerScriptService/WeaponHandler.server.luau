local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local WeaponConfig = require(ReplicatedStorage.Config.WeaponConfig)

local FireEvent: RemoteEvent = ReplicatedStorage.Events.FireWeapon :: RemoteEvent

local function raycastFire(player: Player, origin: Vector3, direction: Vector3)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { player.Character }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true

	local result: RaycastResult? = workspace:Raycast(origin, direction * WeaponConfig.range, raycastParams)
end

FireEvent.OnServerEvent:Connect(raycastFire)
