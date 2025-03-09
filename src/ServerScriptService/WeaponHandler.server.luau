--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local WeaponConfig = require(ReplicatedStorage.Config.WeaponConfig)
local PlayerKill = require(ServerScriptService.Gameplay.Utils.PlayerKill)
local WeaponStateManager = require(ServerScriptService.Gameplay.Utils.WeaponStateManager)

local FireEvent: RemoteEvent = ReplicatedStorage.Events.FireWeapon :: RemoteEvent
local RequestKill: BindableEvent = ServerScriptService.Events.RequestKill :: BindableEvent

local rayParticleFolder: Folder = Instance.new("Folder")
rayParticleFolder.Name = "RayParticles"
rayParticleFolder.Parent = workspace

local function createParticle(origin: Vector3, direction: Vector3, distance: number)
	-- Create a part to represent the ray particle
	local particle: Part = Instance.new("Part")
	particle.Anchored = true
	particle.CanCollide = false
	particle.Transparency = 0
	particle.Color = Color3.new(1, 0, 0)
	particle.Material = Enum.Material.Neon
	particle.Size = Vector3.new(0.2, 0.2, distance)
	particle.Name = "RayParticle"

	particle.CFrame = CFrame.new(origin, origin + direction) * CFrame.new(0, 0, -distance / 2)
	particle.Parent = rayParticleFolder

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(particle, tweenInfo, { Transparency = 1 })
	tween:Play()
	tween.Completed:Connect(function()
		particle:Destroy()
	end)
end

local function raycastFire(player: Player, origin: Vector3, direction: Vector3)
	if not WeaponStateManager.canPlayerFire(player) then
		return
	end

	local raycastParams = RaycastParams.new()
	local character: Model? = player.Character
	if not character then
		return
	end

	raycastParams.FilterDescendantsInstances = { character, rayParticleFolder }

	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local result: RaycastResult? = workspace:Raycast(origin, direction * WeaponConfig.range, raycastParams)
	local length: number = WeaponConfig.range
	local hitPlayer: Player? = nil

	if result then
		local hitPart: Instance = result.Instance
		local hitCharacter: Instance? = hitPart.Parent
		hitPlayer = Players:GetPlayerFromCharacter(hitCharacter :: Model)
		length = (result.Position - origin).Magnitude
	end

	if hitPlayer then
		RequestKill:Fire(player, hitPlayer)
	end

	createParticle(origin, direction, length)

	if not WeaponStateManager.playerReloadState[player].hasPowerup then
		WeaponStateManager.startReload(player)
	else
		WeaponStateManager.playerReloadState[player].lastFireTime = tick()
	end
end

FireEvent.OnServerEvent:Connect(raycastFire)
