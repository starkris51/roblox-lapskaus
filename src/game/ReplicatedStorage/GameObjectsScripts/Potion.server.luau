--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Types = require(ReplicatedStorage.Types.Global)
local PotionManager = require(ServerScriptService.Gameplay.Utils.PotionManager)

local model: any = script.Parent
local effect: Types.PotionName = model:GetAttribute("Effect") :: Types.PotionName

-- this shit will get replaced with a better area detection system, tempoary stuff💀
-- if u do open source stuff please make a replacement to this im lazy

local function onTouched(hit: BasePart)
	local player: Player? = Players:GetPlayerFromCharacter(hit.Parent :: Model)
	if player then
		PotionManager.givePotion(player, effect)
	end
end

model.Touched:Connect(onTouched)
