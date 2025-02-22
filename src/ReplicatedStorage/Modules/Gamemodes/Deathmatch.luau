local Types = require(game.ReplicatedStorage.Types.Server)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KillPlayer: RemoteEvent = ReplicatedStorage.Events.KillPlayer

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
	local metadata: DeathmatchMetadata = Deathmatch.metadata :: DeathmatchMetadata

	for _, player in ipairs(players) do
		metadata.PlayerScore[player.Name] = 0
		metadata.PlayerDeaths[player.Name] = 0
	end
end

function Deathmatch.handleKill(killer: Player, victim: Player)
	local metadata: DeathmatchMetadata = Deathmatch.metadata :: DeathmatchMetadata

	metadata.PlayerScore[killer.Name] += 1
	metadata.PlayerDeaths[victim.Name] += 1

	KillPlayer:FireClient(victim, killer)
end

return Deathmatch
