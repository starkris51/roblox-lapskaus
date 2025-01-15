--!strict
export type WeaponProperties = {
	name: string,
	model: Model,
	powerups: { [string]: boolean },
}

export type WeaponImpl = {
	__index: WeaponImpl,
	new: (name: string, model: Model) -> Weapon,
	fire: (self: Weapon) -> (),
}

type WeaponModel = {
	Handle: Part,
	Barrel: Part,
}

export type Weapon = typeof(setmetatable({} :: WeaponProperties, {} :: WeaponImpl))

local Weapon: WeaponImpl = {} :: WeaponImpl
Weapon.__index = Weapon

function Weapon.new(name: string, model: Model): Weapon
	local self: WeaponProperties = {} :: WeaponProperties
	self.name = name
	self.model = model
	self.powerups = {}
	return setmetatable(self, Weapon)
end

return Weapon
