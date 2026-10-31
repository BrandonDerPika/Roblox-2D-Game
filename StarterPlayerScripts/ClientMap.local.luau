local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Modules
local MapManager = require(ReplicatedStorage:WaitForChild("MapManager"))
local MapRenderer = require(script.Parent:WaitForChild("MapRenderer"))
local CreatureData = require(ReplicatedStorage:WaitForChild("CreatureData"))
local Battle = require(ReplicatedStorage:WaitForChild("Battle"))
local NPCsModule = require(ReplicatedStorage:WaitForChild("NPCs"))

-- Local map refs
local currentMap = MapManager.CurrentMap
local TILE = currentMap and currentMap.TILE_SIZE or 32
local MAP = currentMap and currentMap.MAP or {}
local MAP_HEIGHT = #MAP
local MAP_WIDTH = (MAP_HEIGHT > 0 and #MAP[1]) or 0

-- movement tuning
local speedTilesPerSecond = 4

-- Player position in tile-space
local playerWorldX = math.floor(MAP_WIDTH / 2)
local playerWorldY = math.floor(MAP_HEIGHT / 2)

local encounterActive = false
local isTransitioning = false

-- GUI
MapRenderer.RenderMap(currentMap)
local playerSprite = MapRenderer.GetPlayerSprite()
local container = MapRenderer.GetContainer()
local fadeFrame = MapRenderer.GetFadeFrame()

-- Spawn creatures && NPCs for current map
local creatures = CreatureData.SpawnAll(container)
local npcs = nil
if NPCsModule and NPCsModule.SpawnAll then
	local ok, spawned = pcall(function() return NPCsModule.SpawnAll(container, TILE) end)
	if ok then npcs = spawned end
end
npcs = npcs or {}

-- Refresh Map Vars
local function refreshMapVars(centerOnMap)
	currentMap = MapManager.CurrentMap
	TILE = currentMap.TILE_SIZE or TILE
	MAP = currentMap.MAP or {}
	MAP_HEIGHT = #MAP
	MAP_WIDTH = (MAP_HEIGHT > 0 and #MAP[1]) or 0

	-- Re render map
	MapRenderer.RenderMap(currentMap)

	-- Reposition player
	if centerOnMap then
		playerWorldX = math.max(1, math.floor(MAP_WIDTH / 2))
		playerWorldY = math.max(1, math.floor(MAP_HEIGHT / 2))
	else
		playerWorldX = math.clamp(playerWorldX, 1, math.max(1, MAP_WIDTH))
		playerWorldY = math.clamp(playerWorldY, 1, math.max(1, MAP_HEIGHT))
	end

	-- Refresh creatures
	if creatures then
		for _, c in ipairs(creatures) do
			if c.Instance and c.Instance.Parent then
				c.Instance:Destroy()
			end
		end
	end
	creatures = CreatureData.SpawnAll(container)

	-- Refresh NPCs
	if npcs then
		for _, n in ipairs(npcs) do
			if n.Instance and n.Instance.Parent then
				n.Instance:Destroy()
			end
		end
	end
	local ok, spawned = pcall(function() return NPCsModule.SpawnAll(container, TILE) end)
	if ok and spawned then npcs = spawned else npcs = {} end
end

-- Animations
local animations = {
	South = { "rbxassetid://96983044175239", "rbxassetid://85758723686033", "rbxassetid://113822105436922", "rbxassetid://71862948567078" },
	North = { "rbxassetid://80187913067974", "rbxassetid://117437978786917", "rbxassetid://115207840527464", "rbxassetid://137211068007737" },
	East  = { "rbxassetid://87694382712283", "rbxassetid://125881552909286", "rbxassetid://85827416905064",  "rbxassetid://106011397855782" },
	West  = { "rbxassetid://72405989905381", "rbxassetid://135750742727031", "rbxassetid://91005988074975",  "rbxassetid://88222653526230" },
}
local frameDuration = 0.167
local animToken = 0
local currentAnim = nil

local function playAnimation(frames)
	if currentAnim == frames then return end
	currentAnim = frames
	animToken = animToken + 1
	local token = animToken
	task.spawn(function()
		local idx = 1
		while token == animToken do
			if playerSprite and frames[idx] then
				playerSprite.Image = frames[idx]
			end
			idx = (idx % #frames) + 1
			task.wait(frameDuration)
		end
	end)
end

local function stopAnimation()
	animToken = animToken + 1
	currentAnim = nil
	if playerSprite then
		playerSprite.Image = "rbxassetid://119281678070983"
	end
end

-- Input
local keys = {}
local function onKeyDown(name)
	if name == "W" or name == "Up" then keys.W = true end
	if name == "S" or name == "Down" then keys.S = true end
	if name == "A" or name == "Left" then keys.A = true end
	if name == "D" or name == "Right" then keys.D = true end
end
local function onKeyUp(name)
	if name == "W" or name == "Up" then keys.W = false end
	if name == "S" or name == "Down" then keys.S = false end
	if name == "A" or name == "Left" then keys.A = false end
	if name == "D" or name == "Right" then keys.D = false end
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local name = input.KeyCode.Name
		onKeyDown(name)
		if input.KeyCode == Enum.KeyCode.E then
			local px, py = math.floor(playerWorldX + 0.5), math.floor(playerWorldY + 0.5)
			if NPCsModule and NPCsModule.CheckProximity then
				local ok, nearby = pcall(function() return NPCsModule.CheckProximity(npcs, px, py) end)
				if ok and nearby and #nearby > 0 then
					for _, npc in ipairs(nearby) do
						if npc.OnInteract then
							pcall(npc.OnInteract)
						elseif npc.Interact then
							pcall(function() npc:Interact() end)
						end
					end
				end
			else
				local playerPos = Vector2.new(playerWorldX * TILE, playerWorldY * TILE)
				for _, npc in ipairs(npcs) do
					local success, isNear = pcall(function()
						if npc.IsNear then
							return npc:IsNear(playerPos, TILE * 1.5)
						else
							return false
						end
					end)
					if success and isNear then
						pcall(function()
							if npc.Interact then npc:Interact() elseif npc.OnInteract then npc.OnInteract() end
						end)
						break
					end
				end
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local name = input.KeyCode.Name
		onKeyUp(name)
	end
end)

local function getInputVector()
	local vx, vy = 0, 0
	if keys.W then vy = vy - 1 end
	if keys.S then vy = vy + 1 end
	if keys.A then vx = vx - 1 end
	if keys.D then vx = vx + 1 end
	if vx == 0 and vy == 0 then return 0, 0 end
	local mag = math.sqrt(vx * vx + vy * vy)
	return vx / mag, vy / mag
end

local function tileIndexFromPos(v)
	return math.floor(v + 0.5)
end

-- Fade
local function tweenWait(tween)
	local completed = false
	tween.Completed:Connect(function() completed = true end)
	tween:Play()
	while not completed do task.wait() end
end

local function fadeOut(duration)
	duration = duration or 0.35
	if fadeFrame then
		fadeFrame.BackgroundTransparency = 1
		local tween = TweenService:Create(fadeFrame, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })
		tweenWait(tween)
	end
end

local function fadeIn(duration)
	duration = duration or 0.35
	if fadeFrame then
		local tween = TweenService:Create(fadeFrame, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { BackgroundTransparency = 1 })
		tweenWait(tween)
	end
end

-- Portal Transition
local function handlePortalTo(targetMapName)
	if isTransitioning then return end
	isTransitioning = true
	fadeOut(0.4)

	local ok = MapManager:LoadMap(targetMapName)
	if ok then
		refreshMapVars(true)
	else
		refreshMapVars(false)
	end

	task.wait(0.06)
	fadeIn(0.4)
	isTransitioning = false
end

-- Main update loop
RunService.RenderStepped:Connect(function(dt)
	-- animation
	local vx, vy = getInputVector()
	local moving = (vx ~= 0 or vy ~= 0)
	if not moving then
		stopAnimation()
	else
		if math.abs(vy) > math.abs(vx) then
			playAnimation(vy > 0 and animations.South or animations.North)
		else
			playAnimation(vx > 0 and animations.East or animations.West)
		end
	end

	-- movement + collision
	if moving and not isTransitioning then
		local move = speedTilesPerSecond * dt
		local nextX = playerWorldX + vx * move
		local nextY = playerWorldY + vy * move
		local curX, curY = tileIndexFromPos(playerWorldX), tileIndexFromPos(playerWorldY)
		local tgtX, tgtY = tileIndexFromPos(nextX), tileIndexFromPos(nextY)

		if MapManager:IsWalkable(tgtX, tgtY) then
			playerWorldX, playerWorldY = nextX, nextY
		else
			local minX, maxX = curX - 0.499, curX + 0.499
			local minY, maxY = curY - 0.499, curY + 0.499
			playerWorldX = math.clamp(nextX, minX, maxX)
			playerWorldY = math.clamp(nextY, minY, maxY)
		end
	end

	-- camera follow
	MapRenderer.UpdateCamera(playerWorldX, playerWorldY)

	-- portal detection on current tile
	local curTileX, curTileY = tileIndexFromPos(playerWorldX), tileIndexFromPos(playerWorldY)
	local tileIndex = MapManager:GetTileType(curTileX, curTileY)
	if tileIndex then
		local def = currentMap and currentMap.TYPES and currentMap.TYPES[tileIndex]
		if def and def.portalTarget and not isTransitioning then
			handlePortalTo(def.portalTarget)
		end
	end

	-- Creature encounters
	if not encounterActive and creatures then
		local playerPos = Vector2.new(playerWorldX * TILE, playerWorldY * TILE)
		local playerSize = TILE * 2
		for _, creature in ipairs(creatures) do
			if creature and creature.CheckCollision and creature.Instance then
				if creature:CheckCollision(playerPos, playerSize) then
					encounterActive = true
					pcall(function()
						if creature.OnEncounter then creature:OnEncounter() end
						Battle.Start(creature)
					end)
					task.delay(3, function() encounterActive = false end)
					break
				end
			end
		end
	end
end)
