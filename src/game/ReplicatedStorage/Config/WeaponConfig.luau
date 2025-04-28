--!strict
export type WeaponConfigType = {
	reloadTime: number,
	range: number,
	knockbackForce: number,
}

local WeaponConfig: WeaponConfigType = {
	reloadTime = 1.3,
	range = 1000,
	knockbackForce = 100,
} :: WeaponConfigType

return WeaponConfig
