--!strict
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local RequestLapskaus: BindableFunction = ServerScriptService.Events.RequestLapskaus
local ResetLapskaus: BindableEvent = ServerScriptService.Events.ResetLapskaus

local model: any = script.Parent
local surface: Part = model.Surface :: Part
local lapskaus: Part = model.Lapskaus :: Part
local team: string = model:GetAttribute("Team") :: string

-- this shit will get replaced with a better area detection system, tempoary stuff💀
-- if u do open source stuff please make a replacement to this im lazy

local function onTouched(hit: BasePart)
	local player: Player? = Players:GetPlayerFromCharacter(hit.Parent :: Model)
	if player then
		local canTake: boolean = RequestLapskaus:Invoke(player, team) :: boolean
		if canTake then
			lapskaus.Transparency = 100
		end
	end
end

local function reset(requestTeam: string)
	if team == requestTeam then
		lapskaus.Transparency = 0
	end
end

surface.Touched:Connect(onTouched)
ResetLapskaus.Event:Connect(reset)
