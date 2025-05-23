--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerKill = require(ServerScriptService.Gameplay.Utils.PlayerKill)
local WeaponConfig = require(ReplicatedStorage.Config.WeaponConfig)
local ReloadFinished: RemoteEvent = ReplicatedStorage.Events:FindFirstChild("ReloadFinished") :: RemoteEvent

type ReloadState = {
	isReloading: boolean,
	lastFireTime: number,
	doubleShot: boolean,
	shotsFired: number,
	maxShots: number,
}

type WeaponStateManager = {
	playerReloadState: { [Player]: ReloadState },
	initPlayerReloadState: (player: Player) -> (),
	cleanupPlayerReloadState: (player: Player) -> (),
	cleanup: () -> (),
	canPlayerFire: (player: Player) -> boolean,
	startReload: (player: Player) -> (),
}

local WeaponStateManager: WeaponStateManager = {} :: WeaponStateManager

local function reloadFinished(player: Player)
	if WeaponStateManager.playerReloadState[player] then
		print("reloadFinished")
		WeaponStateManager.playerReloadState[player].isReloading = false
		if ReloadFinished then
			ReloadFinished:FireClient(player)
		end
	end
end

function WeaponStateManager.initPlayerReloadState(player: Player)
	WeaponStateManager.playerReloadState[player] = {
		isReloading = false,
		lastFireTime = 0,
		doubleShot = false,
		shotsFired = 0,
		maxShots = 1,
	}
end

function WeaponStateManager.cleanupPlayerReloadState(player: Player)
	WeaponStateManager.playerReloadState[player] = nil
end

function WeaponStateManager.cleanup()
	for player, _ in pairs(WeaponStateManager.playerReloadState) do
		WeaponStateManager.cleanupPlayerReloadState(player)
	end
end

function WeaponStateManager.canPlayerFire(player: Player): boolean
	if not player or not WeaponStateManager.playerReloadState[player] then
		return false
	end

	if PlayerKill.isPlayerKilled(player) then
		return false
	end

	if WeaponStateManager.playerReloadState[player].isReloading then
		return false
	end

	local currentTime: number = tick()
	local timeSinceLastShot: number = currentTime - WeaponStateManager.playerReloadState[player].lastFireTime

	if timeSinceLastShot < WeaponConfig.reloadTime then
		return false
	end

	return true
end

function WeaponStateManager.startReload(player: Player)
	if not player or not WeaponStateManager.playerReloadState[player] then
		return
	end

	WeaponStateManager.playerReloadState[player].isReloading = true
	WeaponStateManager.playerReloadState[player].lastFireTime = tick()

	task.delay(WeaponConfig.reloadTime, function()
		reloadFinished(player)
	end)
end

WeaponStateManager.playerReloadState = {}

return WeaponStateManager
