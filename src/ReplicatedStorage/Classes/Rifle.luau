local Weapon = require(game.ReplicatedStorage.Classes.Weapon)

type WeaponImpl = Weapon.WeaponImpl

type GunImpl = {
	__index: GunImpl,
	new: () -> Gun,
	reload: (self: Gun) -> (),
}

export type Gun = typeof(setmetatable({} :: {}, {} :: GunImpl))

local Gun: GunImpl = {} :: GunImpl
Gun.__index = Gun

function Gun.new(): Gun
	local self = {}
	return setmetatable(self, Gun)
end

return Gun
