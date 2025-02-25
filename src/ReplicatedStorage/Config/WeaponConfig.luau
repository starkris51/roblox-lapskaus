--!strict
export type WeaponConfigType = {
	reloadTime: number,
	range: number,
	knockbackForce: number,
}

local WeaponConfig: WeaponConfigType = {
	reloadTime = 2.0,
	range = 1000,
	knockbackForce = 100,
} :: WeaponConfigType

return WeaponConfig
