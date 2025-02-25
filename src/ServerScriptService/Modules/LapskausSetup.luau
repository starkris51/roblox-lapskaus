--!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lapskausScript: Script = ReplicatedStorage.GameObjectsScripts.Lapskaus

local lapskaus = {}

local function addLapskausScript(model: Instance, team: string)
	local script = lapskausScript:Clone()
	script:SetAttribute("Team", team)
	script.Parent = model
end

local function onFlagAdded(flag: Instance)
	local team: string = flag:GetAttribute("Team") :: string
	if team then
		addLapskausScript(flag, team)
	end
end

function lapskaus.setupLapskaus()
	local flags: { Instance } = CollectionService:GetTagged("Lapskaus") :: { Instance }
	for _, flag: Instance in ipairs(flags) do
		onFlagAdded(flag)
	end
end

return lapskaus
