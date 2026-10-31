local Moves = {}

-- Move format
-- name = {
--   name = "Tackle",
--   basePower = 8,        -- base power
--   accuracy = 0.95,  -- chance to hit (0..1)
--   energyCost = 5,     -- energy cost to use
--   description = "A basic physical attack."
-- }

Moves.Tackle = {
	name = "Tackle",
	basePower = 8,
	accuracy = 0.98,
	energyCost = 5,
	description = "A simple physical attack."
}

Moves.Slam = {
	name = "Slam",
	basePower = 12,
	accuracy = 0.8,
	energyCost = 8,
	description = "A heavier hit with more power but lower accuracy."
}

Moves.VineWhip = {
	name = "VineWhip",
	basePower = 9,
	accuracy = 0.95,
	energyCost = 9,
	description = "A whip of vines."
}

Moves.PetalDance = {
	name = "PetalDance",
	basePower = 11,
	accuracy = 0.85,
	energyCost = 10,
	description = "A flurry of petal strikes."
}

function Moves:Get(name)
	return Moves[name]
end

return Moves
