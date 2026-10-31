local Creature = require(game:GetService("ReplicatedStorage"):WaitForChild("Creature"))
local MapManager = require(game:GetService("ReplicatedStorage"):WaitForChild("MapManager"))

local CreatureData = {}

-- Spawn all creatures for the current map only
function CreatureData.SpawnAll(parent)
	local currentMap = MapManager.CurrentMap
	if not currentMap or not currentMap.Creatures then
		warn("No creatures defined for current map.")
		return {}
	end

	local instances = {}
	local TILE = currentMap.TILE_SIZE or 64

	for _, data in ipairs(currentMap.Creatures) do
		local pos = data.Position
		if typeof(pos) == "Vector2" then
			pos = Vector2.new((pos.X - 0.5) * TILE, (pos.Y - 0.5) * TILE)
		end

		local creature = Creature.new(data.Name, pos, data.SpriteId, data.Stats)
		creature:Spawn(parent)
		table.insert(instances, creature)
	end

	return instances
end

return CreatureData
