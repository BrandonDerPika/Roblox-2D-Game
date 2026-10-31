-- local Players = game:GetService("Players")
-- local RunService = game:GetService("RunService")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local Workspace = game:GetService("Workspace")

-- local LocalPlayer = Players.LocalPlayer

-- local function setupPlayerController()
--     local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
--     local camera = Workspace.CurrentCamera
--     camera.CameraType = Enum.CameraType.Scriptable

--     -- Clone the PlayerSprite template from ReplicatedStorage
--     local spriteTemplate = ReplicatedStorage:FindFirstChild("PlayerSprite")
--     local playerSprite
--     if spriteTemplate then
--         playerSprite = spriteTemplate:Clone()
--         playerSprite.Name = "PlayerSprite_" .. LocalPlayer.Name
--         playerSprite.Parent = Workspace
--         playerSprite.Anchored = true
--         playerSprite.CanCollide = false
--         playerSprite.Size = Vector3.new(2, 2, 2)
--     end

--     RunService.RenderStepped:Connect(function()
--         if character and character.Parent then
--             local pivot = character:GetPivot()
--             -- Camera lock
--             local topDownPosition = pivot.Position + Vector3.new(0, 5, 0)
--             camera.CFrame = CFrame.new(topDownPosition, pivot.Position)
--             -- Sprite follow
--             if playerSprite and playerSprite.Parent then
--                 playerSprite.Position = pivot.Position
--             end
--         end
--     end)
-- end

-- if LocalPlayer.Character then
--     setupPlayerController()
-- end

-- LocalPlayer.CharacterAdded:Connect(function()
--     setupPlayerController()
-- end)

