--!strict

export type WeaponConfigType = {
	reloadTime: number,
	range: number,
}

local WeaponConfig: WeaponConfigType = {
	reloadTime = 2.0,
	range = 1000,
} :: WeaponConfigType

return WeaponConfig
