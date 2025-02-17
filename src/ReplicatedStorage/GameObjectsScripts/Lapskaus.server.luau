local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RequestLapskaus = ReplicatedStorage.BindebaleFunctions.RequestLapskaus

local model = script.Parent
local surface = model.Surface :: Part
local lapskaus = model.Lapskaus :: Part
local team = model:GetAttribute("Team")

local function onTouched(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if player then
		local canTake = RequestLapskaus:Invoke(player, team) :: boolean
		if canTake then
			lapskaus.Transparency = 100
		end
	end
end

surface.Touched:Connect(onTouched)
