local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- ui
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TopDownMapGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local container = Instance.new("Frame")
container.Name = "TileContainer"
container.BackgroundTransparency = 1
container.Parent = screenGui

local playerSprite = Instance.new("ImageLabel")
playerSprite.Name = "PlayerSprite"
playerSprite.Size = UDim2.new(0, 64 * 2.25, 0, 64 * 2.25)
playerSprite.AnchorPoint = Vector2.new(0.5, 0.5)
playerSprite.Position = UDim2.new(0.5, 0, 0.5, 0)
playerSprite.BackgroundTransparency = 1
playerSprite.ZIndex = 50
playerSprite.Image = "rbxassetid://119281678070983"
playerSprite.Parent = screenGui

local fadeFrame = Instance.new("Frame")
fadeFrame.Name = "ScreenFade"
fadeFrame.Size = UDim2.fromScale(1.5, 1.5)
fadeFrame.Position = UDim2.fromScale(-0.25, -0.25)
fadeFrame.AnchorPoint = Vector2.new(0, 0)
fadeFrame.BackgroundColor3 = Color3.new(0, 0, 0)
fadeFrame.BackgroundTransparency = 1
fadeFrame.ZIndex = 10000
fadeFrame.Parent = screenGui

-- keep it always covering the full screen on resize
screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	fadeFrame.Size = UDim2.fromScale(1.5, 1.5)
	fadeFrame.Position = UDim2.fromScale(-0.25, -0.25)
end)


-- Internal state
local allTiles = {}
local currentMapData = nil

local function clearTiles()
	for _, tile in pairs(allTiles) do
		if tile and tile.Parent then
			tile:Destroy()
		end
	end
	table.clear(allTiles)
end

local function renderMap(mapData)
	if not mapData then return end
	clearTiles()
	currentMapData = mapData

	local MAP1 = mapData.MAP or {}
	local MAP2 = mapData.MAP2 or mapData.LAYER2 or {}
	local TILE = mapData.TILE_SIZE or mapData.TILE or 64
	local MAP_HEIGHT = #MAP1
	local MAP_WIDTH = (MAP_HEIGHT > 0 and #MAP1[1]) or 0

	-- resize container to fit map
	container.Size = UDim2.fromOffset(MAP_WIDTH * TILE, MAP_HEIGHT * TILE)

	-- Base layer
	for y = 1, MAP_HEIGHT do
		local row = MAP1[y] or {}
		for x = 1, #row do
			local tIndex = row[x]
			if tIndex and tIndex ~= 0 then
				local def = mapData.TYPES and mapData.TYPES[tIndex]
				if def then
					local img = Instance.new("ImageLabel")
					img.Size = UDim2.fromOffset(TILE, TILE)
					img.Position = UDim2.fromOffset((x - 1) * TILE, (y - 1) * TILE)
					img.BackgroundTransparency = 1
					img.Image = def.image
					img.ZIndex = def.z or 1
					img.Parent = container
					allTiles["base_"..x.."_"..y] = img
				end
			end
		end
	end

	-- Overlay layer
	for y = 1, #MAP2 do
		local row = MAP2[y] or {}
		for x = 1, #row do
			local tIndex = row[x]
			if tIndex and tIndex ~= 0 then
				local def = mapData.TYPES and mapData.TYPES[tIndex]
				if def then
					local img = Instance.new("ImageLabel")
					img.Size = UDim2.fromOffset(TILE, TILE)
					img.Position = UDim2.fromOffset((x - 1) * TILE, (y - 1) * TILE)
					img.BackgroundTransparency = 1
					img.Image = def.image
					-- ensure overlay renders above player; base def.z can be used but we keep overlay above player
					img.ZIndex = (def.z or 1) + 100
					img.Parent = container
					allTiles["overlay_"..x.."_"..y] = img
				end
			end
		end
	end
end

local function updateCamera(playerWorldX, playerWorldY)
	if not currentMapData then return end
	local TILE = currentMapData.TILE_SIZE or 64
	local camera = workspace.CurrentCamera
	if not camera then return end
	local viewport = camera.ViewportSize
	local px = (playerWorldX - 0.5) * TILE
	local py = (playerWorldY - 0.5) * TILE
	container.Position = UDim2.fromOffset(viewport.X / 2 - px, viewport.Y / 2 - py)
end

local Renderer = {}

function Renderer.GetScreenGui()
	return screenGui
end

function Renderer.GetContainer()
	return container
end

function Renderer.GetPlayerSprite()
	return playerSprite
end

function Renderer.GetFadeFrame()
	return fadeFrame
end

function Renderer.RenderMap(mapData)
	renderMap(mapData)
end

function Renderer.UpdateCamera(x, y)
	updateCamera(x, y)
end

return Renderer
