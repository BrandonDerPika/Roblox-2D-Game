local TileData_PlayerHouse = {}

TileData_PlayerHouse.TILE_SIZE = 64

TileData_PlayerHouse.TYPES = {
	[1] = { image = "rbxassetid://111479324512448", walkable = true,  z = 1 }, -- wooden floor
	[2] = { image = "rbxassetid://100122920666186", walkable = false, z = 1 }, -- wall
	[3] = { image = "rbxassetid://115258352078837", walkable = true,  z = 2 }, -- stairs
	[4] = { image = "rbxassetid://121803319905255", walkable = true, z = 3 ,  portalTarget = "VelocityHills"}, -- stairs down teleport
	[5] = { image = "rbxassetid://85619336692223", walkable = false, z = 100 }, -- left railing
	[6] = { image = "rbxassetid://133043079002175", walkable = false, z = 100 }, -- right railing
}

TileData_PlayerHouse.MAP = {
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,0,1,1,1,1,1,1,1,1,1,1,1,1},
}
TileData_PlayerHouse.MAP2 = {
	{2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
	{2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,5,3,6,0,0,0,0,0,0,0,0,0,0,0},
	{0,5,4,6,0,0,0,0,0,0,0,0,0,0,0},
}

TileData_PlayerHouse.NPCs = {
	{
		Name = "Alice",
		X = 8,
		Y = 6,
		SpriteId = "rbxassetid://96983044175239",
		Dialogue = {
			{
				CharacterName = "Alice",
				Text = "Oh! You met Bob already?",
				Image = "rbxassetid://96983044175239"
			},
			{
				CharacterName = "Alice",
				Text = "He's always sending travelers my way. He's sweet like that.",
				Image = "rbxassetid://96983044175239"
			}
		}
	}
}

-- Creatures unique to this map
TileData_PlayerHouse.Creatures = {
	{
		Name = "Slime",
		Position = Vector2.new(5, 5),
		SpriteId = "rbxassetid://12394466540",
		Stats = { maxHP=20, attack=8, defense=4, speed=3, moves={"Tackle","Slam"}, size=64, maxEnergy=25 }
	},
	{
		Name = "Bloomby",
		Position = Vector2.new(9, 6),
		SpriteId = "rbxassetid://12394466540",
		Stats = { maxHP=22, attack=7, defense=5, speed=4, moves={"VineWhip","PetalDance"}, size=64, maxEnergy=30 }
	}
}

function TileData_PlayerHouse:GetTileType(x, y)
	if y < 1 or y > #self.MAP then return nil end
	local row = self.MAP[y]
	if x < 1 or x > #row then return nil end
	return row[x]
end

function TileData_PlayerHouse:IsWalkable(x, y)
	local t = self:GetTileType(x, y)
	if not t then return false end
	local def = self.TYPES[t]
	return def and def.walkable
end

return TileData_PlayerHouse
