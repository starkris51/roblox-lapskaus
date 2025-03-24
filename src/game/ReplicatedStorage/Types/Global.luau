--!strict
export type PotionCategory = "Upgrade" | "Ability" | "Weapon"

export type PotionName = "DoubleShot" | "Speed" | "Dash" | "Jump"

export type PotionType = {
	name: PotionName,
	category: PotionCategory,
	maxLevel: number,
	onApply: (player: Player, level: number) -> (),
	onRemove: (player: Player) -> (),
}

export type PlayerPotions = {
	Upgrade: { [PotionName]: number },
	Ability: { [PotionName]: number },
	Weapon: { [PotionName]: number },
	upgradeCount: number,
	abilityCount: number,
	weaponCount: number,
}

local Global = {}

return Global
