local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIMainFolder = ReplicatedStorage.UI.TestMain
local MainUI: ScreenGui = UIMainFolder.TestMain:Clone() :: ScreenGui
MainUI.Parent = Players.LocalPlayer.PlayerGui
local UIScript: LocalScript = UIMainFolder.TestUI:Clone() :: LocalScript
UIScript.Parent = MainUI
