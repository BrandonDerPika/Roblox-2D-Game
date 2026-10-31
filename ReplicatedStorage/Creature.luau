local Players = game:GetService("Players")

local Creature = {}
Creature.__index = Creature

-- Constructor
-- name: string
-- position: Vector2 in pixels (for GUI placement)
-- spriteId: string
-- stats: table (optional) { maxHP, attack, defense, speed, moves = { "MoveName", ... } }
function Creature.new(name, position, spriteId, stats)
	local self = setmetatable({}, Creature)

	self.Name = name or "Creature"
	self.Position = position or Vector2.new(0, 0)
	self.SpriteId = spriteId or "rbxassetid://12394466540"
	self.Speed = (stats and stats.speed) or 1
	self.Size = (stats and stats.size) or 64
	self.Active = true
	self.Instance = nil

	-- battle stats
	self.MaxHP = (stats and stats.maxHP) or 20
	self.HP = self.MaxHP
	self.Attack = (stats and stats.attack) or 5
	self.Defense = (stats and stats.defense) or 3
	self.Moves = (stats and stats.moves) or {}

	-- energy system
	self.MaxEnergy = (stats and stats.maxEnergy) or 30
	self.Energy = self.MaxEnergy
	
	return self
end

-- Spawns the creature as an ImageLabel on the map container
function Creature:Spawn(parent)
	if not parent then return end
	local image = Instance.new("ImageLabel")
	image.Name = self.Name
	image.Size = UDim2.fromOffset(self.Size, self.Size)
	image.AnchorPoint = Vector2.new(0.5, 0.5)
	image.Position = UDim2.fromOffset(self.Position.X, self.Position.Y)
	image.Image = self.SpriteId
	image.BackgroundTransparency = 1
	image.Parent = parent

	self.Instance = image
end

-- collision
function Creature:CheckCollision(playerPos, playerSize)
	if not self.Active then return false end
	local half = self.Size / 2
	local playerHalf = playerSize / 2

	local dx = math.abs(playerPos.X - self.Position.X)
	local dy = math.abs(playerPos.Y - self.Position.Y)

	return (dx < half + playerHalf) and (dy < half + playerHalf)
end

-- Called when the player collides with the creature
-- mark inactive and call Battle
function Creature:OnEncounter()
	if not self.Active then return end
	self.Active = false
	print("Encounter triggered with " .. self.Name)
end

function Creature:ResetHP()
	self.HP = self.MaxHP
end

return Creature
