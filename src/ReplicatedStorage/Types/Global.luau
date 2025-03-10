--!strict

export type PotionType = "Speed" | "Jump" | "Double Shot"

export type SpeedData = {
	speedMultiplier: number,
}

export type JumpData = {
	jumpMultiplier: number,
}

export type ExtraShotData = {
	shots: number,
}

export type PotionEffect = {
	type: PotionType,
	level: number,
	data: SpeedData | JumpData | ExtraShotData,
	persistThroughDeath: boolean,
}

local Global = {}

return Global
