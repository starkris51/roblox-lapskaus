--!strict
local PlayerKill = {}

local killedPlayers: { [Player]: boolean } = {}

function PlayerKill.isPlayerKilled(player)
	return killedPlayers[player] or false
end

function PlayerKill.addKilledPlayer(player)
	killedPlayers[player] = true
end

function PlayerKill.removeKilledPlayer(player)
	killedPlayers[player] = false
end

return PlayerKill
