--!strict
local PlayerKillHandler = {}

local killedPlayers: { [Player]: boolean } = {}

function PlayerKillHandler.isPlayerKilled(player)
	return killedPlayers[player] or false
end

function PlayerKillHandler.addKilledPlayer(player)
	killedPlayers[player] = true
end

function PlayerKillHandler.removeKilledPlayer(player)
	killedPlayers[player] = false
end

return PlayerKillHandler
