--!strict
local player: Player = game:GetService("Players").LocalPlayer;

player.CharacterAdded:Connect(function(a0: Model)  
    print(a0.Name)
end)