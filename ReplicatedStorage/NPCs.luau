local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local MapManager = require(ReplicatedStorage:WaitForChild("MapManager"))

local NPCs = {}

local function findChildRobust(parent, ...)
	for i = 1, select("#", ...) do
		local name = select(i, ...)
		local child = parent:FindFirstChild(name)
		if child then return child end
	end
	return nil
end

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local DialogueUI = PlayerGui:WaitForChild("NPCDialogue")
if DialogueUI and DialogueUI:IsA("ScreenGui") then
	if DialogueUI.DisplayOrder then DialogueUI.DisplayOrder = 1000 end
else
	warn("NPCs.lua: Could not find NPCDialogue ScreenGui under PlayerGui.")
end

local CharacterImage = DialogueUI and findChildRobust(DialogueUI, "Character Image", "CharacterImage", "CharImage")
local DialogueBox    = DialogueUI and findChildRobust(DialogueUI, "Dialogue Box", "DialogueBox", "Box")
local CharacterName  = DialogueBox and findChildRobust(DialogueBox, "CharacterName", "Name")
local DialogueText   = DialogueBox and findChildRobust(DialogueBox, "DialogueText", "Text")

if not (DialogueUI and DialogueBox and CharacterName and DialogueText) then
	warn("NPCs.lua: Dialogue UI structure not fully found. Dialogue will still work but UI updates may be missing.")
end

if DialogueUI then pcall(function() DialogueUI.Enabled = false end) end

-- runtime dialogue state
local activeDialogue = nil
local currentLine = 0

-- when true, ignore the next E key
local suppressNextAdvance = false

-- typing state
local isTyping = false
local typingToken = 0 
local charDelay = 0.03

-- finish current typing immediately
local function finishTypingInstantly(fullText)
	-- cancel typing by advancing typingToken
	typingToken = typingToken + 1
	isTyping = false
	if DialogueText then
		pcall(function() DialogueText.Text = fullText or "" end)
	end
	-- print now that the line is fully visible
	-- activeDialogue and currentLine should be valid when calling this
	local line = activeDialogue and activeDialogue[currentLine]
	if line then
		local who = line.CharacterName or "NPC"
		local text = line.Text or ""
		print(string.format("[Dialogue] %s: %s", who, text))
	end
end

-- start a typing coroutine for the provided text
local function startTyping(text)
	-- cancel previous typing
	typingToken = typingToken + 1
	local myToken = typingToken

	isTyping = true
	if DialogueText then
		pcall(function() DialogueText.Text = "" end)
	end

	-- quickly handle empty text
	if not text or #text == 0 then
		-- immediate finish
		isTyping = false
		local line = activeDialogue and activeDialogue[currentLine]
		if line then
			local who = line.CharacterName or "NPC"
			print(string.format("[Dialogue] %s: %s", who, line.Text or ""))
		end
		return
	end

	-- typing loop
	task.spawn(function()
		local out = ""
		for i = 1, #text do
			if myToken ~= typingToken then
				return
			end
			out = string.sub(text, 1, i)
			if DialogueText then pcall(function() DialogueText.Text = out end) end
			task.wait(charDelay)
		end

		-- finished normally
		if myToken == typingToken then
			isTyping = false
			local line = activeDialogue and activeDialogue[currentLine]
			if line then
				local who = line.CharacterName or "NPC"
				local textShown = line.Text or ""
				print(string.format("[Dialogue] %s: %s", who, textShown))
			end
		end
	end)
end

-- show the current line
local function showDialogueLine()
	if not activeDialogue then
		if DialogueUI then pcall(function() DialogueUI.Enabled = false end) end
		return
	end

	local line = activeDialogue[currentLine]
	if not line then
		-- finished
		if DialogueUI then pcall(function() DialogueUI.Enabled = false end) end
		print("[Dialogue] (ended)")
		activeDialogue = nil
		currentLine = 0
		suppressNextAdvance = false
		-- cancel any typing
		typingToken = typingToken + 1
		isTyping = false
		return
	end

	-- update name && image immediately
	if CharacterName then pcall(function() CharacterName.Text = line.CharacterName or "???" end) end
	if CharacterImage and line.Image then pcall(function() CharacterImage.Image = line.Image end) end

	-- start typing the text
	startTyping(line.Text or "")
end

-- Start dialogue for an npc table
function NPCs.StartDialogue(npc, startedByKey)
	if not npc then return end
	local dlg = npc.Dialogue
	if not dlg or #dlg == 0 then
		warn(("NPC '%s' has no dialogue"):format(npc.Name or "unknown"))
		return
	end

	activeDialogue = dlg
	currentLine = 1
	suppressNextAdvance = startedByKey == true
	if DialogueUI then pcall(function() DialogueUI.Enabled = true end) end
	showDialogueLine()
end

-- advance/dialogue input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not activeDialogue then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

	local kc = input.KeyCode

	-- if this dialogue was started by the E key, ignore the very next E to avoid immediate double advance
	if kc == Enum.KeyCode.E and suppressNextAdvance then
		suppressNextAdvance = false
		return
	end

	-- if currently typing, pressing advance finishes the line instantly (doesn't advance)
	if kc == Enum.KeyCode.Return or kc == Enum.KeyCode.Space or kc == Enum.KeyCode.E then
		if isTyping then
			-- finish instantly
			local line = activeDialogue and activeDialogue[currentLine]
			local fullText = (line and line.Text) or ""
			finishTypingInstantly(fullText)
			return
		else
			-- not typing: move to next line
			currentLine = currentLine + 1
			showDialogueLine()
			return
		end
	end
end)

-- Spawn NPCs
function NPCs.SpawnAll(container, tileSize)
	local currentMap = MapManager.CurrentMap
	if not currentMap or not currentMap.NPCs then return {} end

	local instances = {}
	for _, npcDef in ipairs(currentMap.NPCs) do
		local npc = {}
		for k,v in pairs(npcDef) do npc[k] = v end

		local frame = Instance.new("ImageLabel")
		frame.Name = npc.Name or "NPC"
		local size = math.max(8, tileSize * 2)
		frame.Size = UDim2.fromOffset(size, size)
		local px = ((npc.X or 1) - 1) * tileSize
		local py = ((npc.Y or 1) - 1) * tileSize
		frame.Position = UDim2.fromOffset(px, py)
		frame.BackgroundTransparency = 1
		frame.Image = npc.SpriteId or ""
		frame.ZIndex = 50
		frame.Parent = container

		npc.Instance = frame
		npc._tileSize = tileSize

		function npc:IsNear(playerPos, radius)
			if not playerPos then return false end
			local centerX = ((self.X or 1) - 1) * (self._tileSize or tileSize) + (self._tileSize or tileSize) / 2
			local centerY = ((self.Y or 1) - 1) * (self._tileSize or tileSize) + (self._tileSize or tileSize) / 2
			local dx = centerX - playerPos.X
			local dy = centerY - playerPos.Y
			local distSq = dx * dx + dy * dy
			return distSq <= (radius or (self._tileSize or tileSize))^2
		end

		function npc.OnInteract()
			pcall(function()
				NPCs.StartDialogue(npc, true)
			end)
		end

		table.insert(instances, npc)
	end

	return instances
end

function NPCs.CheckProximity(npcsArray, playerTileX, playerTileY)
	local nearby = {}
	if not npcsArray then return nearby end
	local px = tonumber(playerTileX) or 0
	local py = tonumber(playerTileY) or 0

	for _, npc in ipairs(npcsArray) do
		if npc.X and npc.Y then
			if math.abs(npc.X - px) <= 1 and math.abs(npc.Y - py) <= 1 then
				table.insert(nearby, npc)
			end
		else
			if npc.IsNear then
				local playerPos = Vector2.new(px * (npc._tileSize or 32), py * (npc._tileSize or 32))
				if npc:IsNear(playerPos, (npc._tileSize or 32) * 1.5) then
					table.insert(nearby, npc)
				end
			end
		end
	end

	return nearby
end

NPCs.GetNearbyByTile = NPCs.CheckProximity

return NPCs
