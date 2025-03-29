--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local Players = game:GetService("Players")
--local player = Players.LocalPlayer
local Types = require(ReplicatedStorage.Types.Server)

local ClientGamemodeManager = {}

local gamemodeHandlers = {
	CaptureTheLapskaus = {
		setup = function()
			print("Setting up client-side CaptureTheLapskaus")
		end,

		cleanup = function()
			print("Cleaning up client-side CaptureTheLapskaus")
		end,
	},

	Deathmatch = {
		setup = function()
			print("Setting up client-side Deathmatch")
		end,

		cleanup = function() end,
	},

	TeamDeathmatch = {
		setup = function()
			print("Setting up client-side TeamDeathmatch")
		end,

		cleanup = function()
			print("Cleaning up client-side TeamDeathmatch")
		end,
	},
}

function ClientGamemodeManager.setupGamemode(gamemodeName: Types.GamemodesName)
	local gamemodeHandler = gamemodeHandlers[gamemodeName]
	if not gamemodeHandler then
		warn("Unknown gamemode:", gamemodeName)
		return
	end

	gamemodeHandlers[gamemodeName].cleanup()

	gamemodeHandlers[gamemodeName].setup()
end

return ClientGamemodeManager
