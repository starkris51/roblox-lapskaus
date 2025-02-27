--!strict
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local RequestLapskaus: BindableFunction = ServerScriptService.Events.RequestLapskaus

local model: any = script.Parent
local surface: Part = model.Surface :: Part
local lapskaus: Part = model.Lapskaus :: Part
local team: string = model:GetAttribute("Team") :: string

local function onTouched(hit: BasePart)
	local player: Player? = Players:GetPlayerFromCharacter(hit.Parent :: Model)
	if player then
		local canTake: boolean = RequestLapskaus:Invoke(player, team) :: boolean
		if canTake then
			lapskaus.Transparency = 100
		end
	end
end

surface.Touched:Connect(onTouched)
