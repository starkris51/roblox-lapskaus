export type Gamemode = {
	name: string,
	metadata: any?,
	setup: () -> (),
	setupPlayers: (players: { Player }) -> (),
	handleKill: (killer: Player, victim: Player) -> (),
}

local Types = {}

return Types
