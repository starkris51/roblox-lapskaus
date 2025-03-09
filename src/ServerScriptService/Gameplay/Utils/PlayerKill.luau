--!strict
type PlayerKill = {
	killedPlayers: { [number]: boolean },
	isPlayerKilled: (player: Player) -> boolean,
	addKilledPlayer: (player: Player) -> (),
	removeKilledPlayer: (player: Player) -> (),
	cleanup: () -> (),
}

local PlayerKill: PlayerKill = {} :: PlayerKill

function PlayerKill.isPlayerKilled(player)
	return PlayerKill.killedPlayers[player.UserId] or false
end

function PlayerKill.addKilledPlayer(player)
	PlayerKill.killedPlayers[player.UserId] = true
end

function PlayerKill.removeKilledPlayer(player)
	PlayerKill.killedPlayers[player.UserId] = false
end

function PlayerKill.cleanup()
	PlayerKill.killedPlayers = {}
end

PlayerKill.killedPlayers = {}

return PlayerKill
