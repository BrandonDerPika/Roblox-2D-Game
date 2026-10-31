local MapManager = {}

-- load maps
local PlayerHouse = require(script.Parent.TileData_PlayerHouse)
local VelocityHills = require(script.Parent.TileData_VelocityHills)

-- Current map reference
MapManager.CurrentMap = PlayerHouse

-- A list of all maps for quick access
MapManager.Maps = {
	PlayerHouse = PlayerHouse,
	VelocityHills = VelocityHills,
}

-- load a new map by name
function MapManager:LoadMap(mapName)
	local map = self.Maps[mapName]
	if not map then
		warn("No map found with name:", mapName)
		return false
	end

	self.CurrentMap = map
	print("Switched to map:", mapName)
	return true
end

local function readGrid(grid, x, y)
	if not grid then return nil end
	if y < 1 or y > #grid then return nil end
	local row = grid[y]
	if not row then return nil end
	if x < 1 or x > #row then return nil end
	return row[x]
end

function MapManager:GetTileType(x, y)
	local map = self.CurrentMap
	if not map then return nil end

	-- check overlay first
	local overlay = map.MAP2 or map.LAYER2
	local valOverlay = readGrid(overlay, x, y)
	if valOverlay ~= nil and valOverlay ~= 0 then
		return valOverlay
	end

	-- fallback to base layer
	local baseVal = readGrid(map.MAP, x, y)
	if baseVal ~= nil and baseVal ~= 0 then
		return baseVal
	end

	return nil
end

-- Check walkability at tile (x,y) Overlay takes precedence
function MapManager:IsWalkable(x, y)
	local map = self.CurrentMap
	if not map then return false end

	local tileIndex = self:GetTileType(x, y)
	if not tileIndex then
		return false
	end

	local def = map.TYPES and map.TYPES[tileIndex]
	if not def then
		-- If the map's TYPES table isn't present or missing the tile index,
		-- fall back to a conservative "not walkable" behavior.
		return false
	end

	return def.walkable == true
end

-- Check special tile interactions
function MapManager:CheckSpecialTile(x, y)
	local map = self.CurrentMap
	if not map then return false end

	local tileIndex = self:GetTileType(x, y)
	if not tileIndex then return false end

	local def = map.TYPES and map.TYPES[tileIndex]
	if def and def.portalTarget then
		-- attempt to load target map
		local ok = self:LoadMap(def.portalTarget)
		return ok
	end

	return false
end

return MapManager
