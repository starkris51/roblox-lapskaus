--!strict
export type GamemodesName = "CaptureTheLapskaus" | "Deathmatch"
export type Gamemode = {
	name: GamemodesName,
	metadata: any?,
	setup: () -> (),
	setupPlayers: (players: { Player }) -> (),
	handleKill: (killer: Player, victim: Player) -> (),
	handleWin: (any) -> (),
}

local ServerTypes = {}

return ServerTypes
