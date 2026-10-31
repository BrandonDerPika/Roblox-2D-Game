local TileData_VelocityHills = {}

TileData_VelocityHills.TILE_SIZE = 64

TileData_VelocityHills.TYPES = {
	[1] = { image = "rbxassetid://111479324512448", walkable = true,  z = 1 },
	[2] = { image = "rbxassetid://100122920666186", walkable = false, z = 1 },
	[3] = { image = "rbxassetid://12394466114", walkable = true,  z = 2 },
	[4] = { image = "rbxassetid://12394466540", walkable = false, z = 3 },
	[5] = { image = "rbxassetid://115258352078837", walkable = true, z = 2, portalTarget = "PlayerHouse" }, -- return portal
}

TileData_VelocityHills.MAP = {
	{2,2,2,2,2,2,2,2,2,2,2},
	{2,1,1,1,1,1,1,1,1,1,2},
	{2,1,3,3,3,1,1,1,1,1,2},
	{2,1,3,5,3,1,1,1,1,1,2},
	{2,1,1,1,1,1,1,1,1,1,2},
	{2,2,2,2,2,2,2,2,2,2,2},
}

function TileData_VelocityHills:GetTileType(x, y)
	if y < 1 or y > #self.MAP then return nil end
	local row = self.MAP[y]
	if x < 1 or x > #row then return nil end
	return row[x]
end

function TileData_VelocityHills:IsWalkable(x, y)
	local t = self:GetTileType(x, y)
	if not t then return false end
	local def = self.TYPES[t]
	return def and def.walkable
end

return TileData_VelocityHills
