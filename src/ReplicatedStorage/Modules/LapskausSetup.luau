local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lapskausScript = ReplicatedStorage.GameObjectsScripts.Lapskaus

export type Lapskaus = {
	setupLapskaus: () -> (),
}

local lapskaus: Lapskaus = {} :: Lapskaus

local function addLapskausScript(model: Model, team: string)
	local script = lapskausScript:Clone()
	script:SetAttribute("Team", team)
	script.Parent = model
end

local function onFlagAdded(flag)
	local team: string = flag:GetAttribute("Team") :: string
	if team then
		addLapskausScript(flag, team)
	end
end

function lapskaus.setupLapskaus()
	local flags: { Model } = CollectionService:GetTagged("Lapskaus") :: { Model }
	for _, flag: Model in ipairs(flags) do
		onFlagAdded(flag)
	end
end

return lapskaus :: Lapskaus
