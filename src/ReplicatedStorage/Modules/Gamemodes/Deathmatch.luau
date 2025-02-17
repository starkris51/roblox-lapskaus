local Types = require(game.ReplicatedStorage.Types.Server)

export type DeathmatchMetadata = {
	PlayerScore: { [string]: number },
	PlayerDeaths: { [string]: number },
}

local Deathmatch: Types.Gamemode = {
	name = "Deathmatch",
	metadata = {
		PlayerScore = {},
		PlayerDeaths = {},
	} :: DeathmatchMetadata,
} :: Types.Gamemode

function Deathmatch.setup()
	print("Setting up Deathmatch")
	-- Add your setup logic here
end

function Deathmatch.setupPlayers(players: { Player })
	for _, player in ipairs(players) do
		player.Team = nil
	end
end

function Deathmatch.handleKill(killer: Player, victim: Player)
	-- Add your kill handling logic here
end

return Deathmatch
