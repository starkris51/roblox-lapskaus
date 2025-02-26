--!strict
local Types = require(game.ReplicatedStorage.Types.Server)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KillPlayer: RemoteEvent = ReplicatedStorage.Events.KillPlayer
local RespawnHandler = require(game.ServerScriptService.Modules.RespawnHandler)

local Deathmatch: Types.Gamemode = {
	name = "Deathmatch",
	metadata = {
		playerScore = {},
		playerDeaths = {},
	},
	setup = function() end,
	setupPlayer = function() end,
	handleKill = function() end,
	handleWin = function() end,
}

local metadata: Types.DeathmatchMetadata = Deathmatch.metadata :: Types.DeathmatchMetadata

function Deathmatch.setup()
	print("Setting up Deathmatch")
	-- Add your setup logic here
end

function Deathmatch.setupPlayer(player: Player)
	metadata.playerScore[player] = 0
	metadata.playerDeaths[player] = 0

	RespawnHandler.respawn(player)
end

function Deathmatch.handleKill(killer: Player, victim: Player)
	metadata.playerScore[killer] += 1
	metadata.playerDeaths[victim] += 1

	KillPlayer:FireClient(victim, killer)
end

function Deathmatch.handleWin()
	local highestScore: number = 0
	local winner: Player = nil

	for player: Player, score: number in pairs(metadata.playerScore) do
		if score > highestScore then
			highestScore = score
			winner = player
		end
	end

	print(winner.Name .. " won the Deathmatch with " .. highestScore .. " kills!")
end

return Deathmatch
