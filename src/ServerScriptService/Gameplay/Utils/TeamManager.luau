--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Types.Server)

local BaseTeamHightlight: Highlight = Instance.new("Highlight")

BaseTeamHightlight.FillTransparency = 1
BaseTeamHightlight.DepthMode = Enum.HighlightDepthMode.Occluded

local TeamManager = {}

type Team = Types.Team
type Teams = Types.Teams

local function countTeam(team: Team): number
	local count: number = 0
	for _ in pairs(team) do
		count += 1
	end
	return count
end

local function getHighlightColor(team: string): Color3
	if team == "Blue" then
		return Color3.fromRGB(0, 0, 255)
	elseif team == "Red" then
		return Color3.fromRGB(255, 0, 0)
	else
		local random: Random = Random.new(os.clock())
		return Color3.fromRGB(random:NextNumber(), random:NextNumber(), random:NextNumber())
	end
end

function TeamManager.highlightPlayer(player: Player, team: string)
	local character: Model? = player.Character
	if not character then
		return
	end

	local highlight: Highlight = BaseTeamHightlight:Clone()
	highlight.OutlineColor = getHighlightColor(team)
	highlight.Parent = character
end

function TeamManager.initializeTeamData(...: string): Teams
	local teams: Teams = {}
	for _, teamName: string in ipairs({ ... }) do
		teams[teamName] = {}
	end
	return teams
end

function TeamManager.assignPlayerToTeam(teams: Teams, player: Player)
	local smallestTeamName: string? = nil
	local smallestCount: number = math.huge
	for teamName: string, team: Team in pairs(teams) do
		local count: number = countTeam(team)
		if count < smallestCount then
			smallestCount = count
			smallestTeamName = teamName
		end
	end
	if smallestTeamName then
		teams[smallestTeamName][player] = player
	end
end

return TeamManager
