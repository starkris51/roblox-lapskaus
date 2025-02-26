--!strict
local ScreenGui: any = script.Parent
local Timer: TextLabel = ScreenGui.Timer :: TextLabel
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TimerUpdated: UnreliableRemoteEvent = ReplicatedStorage.Events.TimerUpdated

TimerUpdated.OnClientEvent:Connect(function(time: number)
	Timer.Text = "Time: " .. time
end)
