--[[ Defines all of the base stats for wild monsters. The stats are for 
what the monster would be at in the wild at level 1. The random stat pool
is distributed in whole numbers to other per level stats except energy per 
level. This distribution stays the same after a wild monster has been generated.
This means players can keep capturing a few of the same monsters to try 
getting better random stat distribution. Fractional stats are always rounded 
down after being calculated on each level up.

The max level for all monsters is 100. The max health, attack, defense, 
and agility at level 100 is 1000. The max energy at level 100 is 20. 
Monster stats can be lower but should not exceed these limits.

Exp per level is multiplied by the current level to determine how much
exp is needed before leveling up.]]--

local monster_stats = {}

-- Determines what nodes monsters should spawn on
local soil = "group:soil"
local leaves = "group:leaves"

monster_stats.burrlock = {
	name = "Burrlock",
	asset_name = "burrlock",
	description = "",
	type = "Plant",
	color = "#30D35CFF",
	health = 10,
	health_per_level = 3,
	energy = 2,
	energy_per_level = 0.08,
	attack = 25,
	attack_per_level = 3,
	defense = 12,
	defense_per_level = 3,
	agility = 35,
	agility_per_level = 3,
	random_stat_pool = 2,
	exp_per_level = 100,
	level_up_moves = {[1] = "jab", [5] = "punch"},
	taught_moves = {"slam"},
	changes_into = "cackaburr",
	changes_at_level = 21,
	spawn_min_level = 4,
	spawn_max_level = 9,
	spawn_on = {soil},
	spawn_chance = 5000,
	spawn_interval = 30,
	spawn_day_toggle = true,
	spawn_min_light = 10,
	spawn_min_height = 1,
	spawn_max_height = 200,
	spawn_visual_size = {x = 1, y = 1},
	spawn_collisionbox = {-0.3, -0.39, -0.3, 0.3, 0.1, 0.3},
	spawn_walk_velocity = 1,
	spawn_glow = nil,
	spawn_moves = {[1] = "jab", [2] = "punch"}
}

monster_stats.chickadee = {
	name = "Chickadee",
	asset_name = "chickadee",
	description = "",
	type = "Wind",
	color = "#FFF496FF",
	health = 12,
	health_per_level = 3,
	energy = 2,
	energy_per_level = 0.08,
	attack = 25,
	attack_per_level = 3,
	defense = 12,
	defense_per_level = 3,
	agility = 35,
	agility_per_level = 3,
	random_stat_pool = 2,
	exp_per_level = 100,
	level_up_moves = {[1] = "jab", [5] = "punch"},
	taught_moves = {"slam"},
	changes_into = "birdee",
	changes_at_level = 15,
	spawn_min_level = 4,
	spawn_max_level = 9,
	spawn_on = {soil},
	spawn_chance = 5000,
	spawn_interval = 30,
	spawn_day_toggle = true,
	spawn_min_light = 10,
	spawn_min_height = 1,
	spawn_max_height = 200,
	spawn_visual_size = {x = 1, y = 1},
	spawn_collisionbox = {-0.3, -0.39, -0.3, 0.3, 0.1, 0.3},
	spawn_walk_velocity = 1,
	spawn_glow = nil,
	spawn_moves = {[1] = "jab", [2] = "punch"}
}

monster_stats.ruffalo = {
	name = "Ruffalo",
	asset_name = "ruffalo",
	description = "",
	type = "Beast",
	color = "#493526FF",
	health = 10,
	health_per_level = 3,
	energy = 2,
	energy_per_level = 0.08,
	attack = 25,
	attack_per_level = 3,
	defense = 12,
	defense_per_level = 3,
	agility = 35,
	agility_per_level = 3,
	random_stat_pool = 2,
	exp_per_level = 100,
	level_up_moves = {[1] = "jab", [5] = "punch"},
	taught_moves = {"slam"},
	spawn_min_level = 4,
	spawn_max_level = 9,
	spawn_on = {soil},
	spawn_chance = 5000,
	spawn_interval = 30,
	spawn_day_toggle = true,
	spawn_min_light = 10,
	spawn_min_height = 1,
	spawn_max_height = 200,
	spawn_visual_size = {x = 2, y = 2},
	spawn_collisionbox = {-0.6, -0.91, -0.6, 0.6, 0.3, 0.6},
	spawn_walk_velocity = 0.5,
	spawn_glow = nil,
	spawn_moves = {[1] = "jab", [2] = "punch"}
}

monster_stats.howler = {
	name = "Howler",
	asset_name = "howler",
	description = "",
	type = "Wind",
	color = "#A5733DFF",
	health = 10,
	health_per_level = 3,
	energy = 2,
	energy_per_level = 0.08,
	attack = 25,
	attack_per_level = 3,
	defense = 12,
	defense_per_level = 3,
	agility = 35,
	agility_per_level = 3,
	random_stat_pool = 2,
	exp_per_level = 100,
	level_up_moves = {[1] = "jab", [5] = "punch"},
	taught_moves = {"slam"},
	spawn_min_level = 4,
	spawn_max_level = 9,
	spawn_on = {soil},
	spawn_chance = 5000,
	spawn_interval = 30,
	spawn_day_toggle = true,
	spawn_min_light = 10,
	spawn_min_height = 1,
	spawn_max_height = 200,
	spawn_visual_size = {x = 2, y = 2},
	spawn_collisionbox = {-0.6, -0.91, -0.6, 0.6, 0.3, 0.6},
	spawn_walk_velocity = 0.5,
	spawn_glow = nil,
	spawn_moves = {[1] = "jab", [2] = "punch"}
}

monster_stats.kackaburr = {
	name = "Kackaburr",
	asset_name = "kackaburr",
	description = "",
	type = "Plant",
	color = "#30D35CFF",
	health = 10,
	health_per_level = 3,
	energy = 2,
	energy_per_level = 0.08,
	attack = 25,
	attack_per_level = 3,
	defense = 12,
	defense_per_level = 3,
	agility = 35,
	agility_per_level = 3,
	random_stat_pool = 2,
	exp_per_level = 100,
	level_up_moves = {[1] = "jab", [5] = "punch"},
	taught_moves = {"slam"},
	spawn_min_level = 4,
	spawn_max_level = 9,
	spawn_on = {soil},
	spawn_chance = 5000,
	spawn_interval = 30,
	spawn_day_toggle = true,
	spawn_min_light = 10,
	spawn_min_height = 1,
	spawn_max_height = 200,
	spawn_visual_size = {x = 2, y = 2},
	spawn_collisionbox = {-0.6, -0.91, -0.6, 0.6, 0.3, 0.6},
	spawn_walk_velocity = 0.5,
	spawn_glow = nil,
	spawn_moves = {[1] = "jab", [2] = "punch"}
}

return monster_stats