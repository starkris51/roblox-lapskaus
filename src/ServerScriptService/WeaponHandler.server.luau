--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local WeaponConfig = require(ReplicatedStorage.Config.WeaponConfig)
local PlayerKillHandler = require(ServerScriptService.Modules.PlayerKillHandler)

local FireEvent: RemoteEvent = ReplicatedStorage.Events.FireWeapon :: RemoteEvent
local RequestKill: BindableEvent = ServerStorage.ServerEvents.RequestKill :: BindableEvent

local function createParticle(origin: Vector3, direction: Vector3, distance: number)
	-- Create a part to represent the ray particle
	local particle: Part = Instance.new("Part")
	particle.Anchored = true
	particle.CanCollide = false
	particle.Transparency = 0
	particle.Color = Color3.new(1, 0, 0)
	particle.Material = Enum.Material.Neon
	particle.Size = Vector3.new(0.2, 0.2, distance)

	particle.CFrame = CFrame.new(origin, origin + direction) * CFrame.new(0, 0, -distance / 2)
	particle.Parent = workspace

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(particle, tweenInfo, { Transparency = 1 })
	tween:Play()
	tween.Completed:Connect(function()
		particle:Destroy()
	end)
end

local function raycastFire(player: Player, origin: Vector3, direction: Vector3)
	if PlayerKillHandler.isPlayerKilled(player) then
		print("Player is dead")
		return
	end

	local raycastParams = RaycastParams.new()
	local character: Model? = player.Character
	if not character then
		return
	end

	raycastParams.FilterDescendantsInstances = { character }

	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local result: RaycastResult? = workspace:Raycast(origin, direction * WeaponConfig.range, raycastParams)
	local length: number = WeaponConfig.range

	if result then
		local hitPart: Instance = result.Instance
		local hitCharacter: Instance? = hitPart.Parent
		local hitPlayer: Player? = Players:GetPlayerFromCharacter(hitCharacter :: Model)

		if hitPlayer then
			RequestKill:Fire(player, hitPlayer)
		end

		length = (result.Position - origin).Magnitude
	end

	createParticle(origin, direction, length)
end

FireEvent.OnServerEvent:Connect(raycastFire)
