local TileData = {}

-- Pixel size for each tile
TileData.TILE_SIZE = 64

-- Tile definitions
TileData.TYPES = {
	[1] = { image = "rbxassetid://111479324512448", walkable = true,  z = 1 }, -- grass
	[2] = { image = "rbxassetid://100122920666186", walkable = false, z = 1 }, -- water
	[3] = { image = "rbxassetid://12394466114", walkable = true,  z = 2 }, -- dirt
	[4] = { image = "rbxassetid://12394466540", walkable = false, z = 3 }, -- rock/obstacle
	[5] = { image = "rbxassetid://115258352078837", walkable = true, z = 2, portalTarget = "VelocityHills" },
}

-- Example base map
TileData.MAP = {
	--{1,1,1,1,...}
}

-- Optional second layer
TileData.LAYER2 = {
	--{0, 0, 4, 0, ...} 
}

-- Get tile type at a position
-- layer2 takes precedence
function TileData:GetTileType(x, y)
	-- Check LAYER2 first
	if self.LAYER2 and y >= 1 and y <= #self.LAYER2 then
		local row2 = self.LAYER2[y]
		if row2 and x >= 1 and x <= #row2 and row2[x] then
			return row2[x]
		end
	end

	-- fallback to base layer
	if not self.MAP or y < 1 or y > #self.MAP then return nil end
	local row = self.MAP[y]
	if x < 1 or x > #row then return nil end
	return row[x]
end

-- Check walkability
function TileData:IsWalkable(x, y)
	local tile = self:GetTileType(x, y)
	if not tile then return false end
	local def = self.TYPES[tile]
	return def and def.walkable or false
end

function TileData:GetTileZ(x, y)
	local tile = self:GetTileType(x, y)
	if not tile then return 0 end
	local def = self.TYPES[tile]
	return def and def.z or 0
end

return TileData
