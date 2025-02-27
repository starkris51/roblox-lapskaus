--!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local types = require(ReplicatedStorage.Types.Server)

local GameObjects = {}

function GameObjects.initializeGameObject(tag: types.GameObjectTag, attributes: { [string]: any }?)
	local scriptTemplate: Instance? = ReplicatedStorage.GameObjectsScripts:FindFirstChild(tag)
	if not scriptTemplate then
		warn("Script with name '" .. tag .. "' not found in GameObjectsScripts")
		return
	end

	local objects: { Instance } = CollectionService:GetTagged(tag)
	for _, object: Instance in ipairs(objects) do
		local clonedScript: Script = scriptTemplate:Clone() :: Script
		if attributes then
			for attrName: string, attrValue: any in pairs(attributes) do
				clonedScript:SetAttribute(attrName, attrValue)
			end
		end
		clonedScript.Parent = object
	end
end

function GameObjects.cleanup(tag: types.GameObjectTag)
	local objects: { Instance } = CollectionService:GetTagged(tag)
	for _, object: Instance in ipairs(objects) do
		object:Destroy()
	end
end

return GameObjects
