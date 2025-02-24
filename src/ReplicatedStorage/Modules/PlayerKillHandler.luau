local PlayerKillHandler = {}

local killedPlayers: { [Player]: boolean } = {}

-- Function to check if a player is already killed
function PlayerKillHandler.isPlayerKilled(player)
	return killedPlayers[player] or false
end

-- Function to mark a player as killed
function PlayerKillHandler.addKilledPlayer(player)
	killedPlayers[player] = true
end

-- Function to remove a player from the killed list
function PlayerKillHandler.removeKilledPlayer(player)
	killedPlayers[player] = nil
end

return PlayerKillHandler
