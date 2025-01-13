--!strict
local Types = require(game.ReplicatedStorage.Modules.Weapon)

type Weapon = Types.Weapon

local Inventory = {}
Inventory.__index = Inventory

type InventoryImpl = {
	__index: InventoryImpl,
	new: (player: Player) -> Inventory,
	addWeapon: (self: Inventory, weapon: Weapon) -> (),
	equipWeapon: (self: Inventory, weaponName: string) -> (),
}

export type Inventory = typeof(setmetatable(
	{} :: { player: Player, weapons: { [string]: Weapon } },
	{} :: InventoryImpl
))

function Inventory.new(player: Player): Inventory
	local self = setmetatable({}, Inventory)
	self.player = player
	self.weapons = {}
	return self
end

function Inventory:addWeapon(weapon: Weapon)
	self.weapons[weapon.name] = weapon
end

function Inventory:equipWeapon(weaponName: string)
	local weapon = self.weapons[weaponName]
	print(weapon.name)
end

return Inventory
