--!strict

-- Gamemode types

export type GamemodesName = "CaptureTheLapskaus" | "Deathmatch" | "TeamDeathmatch"

export type Team = { [Player]: Player }

export type Teams = { [string]: Team }

export type TeamStatistics = { [string]: number }

export type PlayerStatistics = { [Player]: number }

export type HoldingFlags = { [string]: Player }

export type CaptureTheLapskausMetadata = {
	teams: Teams,
	teamScores: TeamStatistics,
	holdingFlags: HoldingFlags,
}

export type DeathmatchMetadata = {
	playerScore: PlayerStatistics,
	playerDeaths: PlayerStatistics,
}

export type TeamDeathmatchMetadata = {
	teams: Teams,
	teamScores: TeamStatistics,
	teamDeaths: TeamStatistics,
}

export type Gamemode = {
	name: GamemodesName,
	metadata: DeathmatchMetadata | CaptureTheLapskausMetadata | TeamDeathmatchMetadata,
	setup: () -> (),
	setupPlayer: (player: Player) -> (),
	playerLeave: (player: Player) -> (),
	handleKill: (killer: Player, victim: Player) -> (),
	handleWin: (any) -> (),
}

export type GameState = "Waiting" | "Playing" | "Ended"

-- Game Object types

export type GameObjectTag = "Lapskaus" | "Potion"

local ServerTypes = {}

return ServerTypes
