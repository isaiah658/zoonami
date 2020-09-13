-- Spawns the monster mobs via mobs redo mod and also gives new players a starter monster

-- Import monster stats
local monster_stats = dofile(minetest.get_modpath("zoonami") .. "/lua/monster_stats.lua")

-- Temporary way to give players some inital monsters
minetest.register_on_newplayer(function(player)
	local meta = player:get_meta()
	local monster = {monster_stats.ruffalo, monster_stats.kackaburr, monster_stats.chickadee}
	local stat_groups = {"health", "attack", "defense", "agility"}
	for i = 1, #monster do
		local random_level = math.random(5, 9)
		local random_stat_distribution = {health = 0, attack = 0, defense = 0, agility = 0}
		for i = 1, monster[i].random_stat_pool do
			local random_stat_group = stat_groups[math.random(1, 4)]
			random_stat_distribution[random_stat_group] = random_stat_distribution[random_stat_group] + 1
		end
		local chosen_monster = {
			name = monster[i].name,
			asset_name = monster[i].asset_name,
			type = monster[i].type,
			level = random_level,
			max_health = monster[i].health + math.floor(monster[i].health_per_level * random_level) + random_stat_distribution.health,
			health = monster[i].health + math.floor(monster[i].health_per_level * random_level) + random_stat_distribution.health,
			max_energy = monster[i].energy + math.floor(monster[i].energy_per_level * random_level),
			energy = monster[i].energy + math.floor(monster[i].energy_per_level * random_level),
			attack = monster[i].attack + math.floor(monster[i].attack_per_level * random_level) + random_stat_distribution.attack,
			defense = monster[i].defense + math.floor(monster[i].defense_per_level * random_level) + random_stat_distribution.defense,
			agility = monster[i].agility + math.floor(monster[i].agility_per_level * random_level) + random_stat_distribution.agility,
			moves = {[1] = "jab", [2] = "punch"}
		}
		meta:set_string("zoonami_monster_"..i, minetest.serialize(chosen_monster))
	end
	meta:set_string("zoonami_battle_session_id", 0)
	meta:set_float("zoonami_gui_zoom", 1)
end)

-- Register all mobs with mobs redo
for k, v in pairs(monster_stats) do
	local monster = v
	mobs:register_mob("zoonami:"..monster.asset_name, {
		stepheight = 0.6,
		type = "animal",
		passive = true,
		hp_min = 1,
		hp_max = 1,
		armor = 1,
		immune_to = {"all"},
		collisionbox = monster.spawn_collisionbox,
		selectionbox = monster.spawn_collisionbox,
		visual = "upright_sprite",
		visual_size = monster.spawn_visual_size,
		textures = {"zoonami_"..monster.asset_name.."_front.png"},
		makes_footstep_sound = true,
		walk_velocity = monster.spawn_walk_velocity,
		run_velocity = 3,
		drops = {},
		water_damage = 0,
		lava_damage = 0,
		fall_speed = -10,
		fear_height = 5,
		view_range = 5,
		pushable = true,
		on_rightclick = function(self, clicker)
			mobs:remove(self)
			local mt_player_name = clicker:get_player_name()
			local random_level = math.random(monster.spawn_min_level, monster.spawn_max_level)
			local stat_groups = {"health", "attack", "defense", "agility"}
			local random_stat_distribution = {health = 0, attack = 0, defense = 0, agility = 0}
			for i = 1, monster.random_stat_pool do
				local random_stat_group = stat_groups[math.random(1, 4)]
				random_stat_distribution[random_stat_group] = random_stat_distribution[random_stat_group] + 1
			end
			local enemy_monsters = {}
			enemy_monsters.monster_1 = {
				name = monster.name,
				asset_name = monster.asset_name,
				type = monster.type,
				level = random_level,
				max_health = monster.health + math.floor(monster.health_per_level * random_level) + random_stat_distribution.health,
				health = monster.health + math.floor(monster.health_per_level * random_level) + random_stat_distribution.health,
				max_energy = monster.energy + math.floor(monster.energy_per_level * random_level),
				energy = monster.energy + math.floor(monster.energy_per_level * random_level),
				attack = monster.attack + math.floor(monster.attack_per_level * random_level) + random_stat_distribution.attack,
				defense = monster.defense + math.floor(monster.defense_per_level * random_level) + random_stat_distribution.defense,
				agility = monster.agility + math.floor(monster.agility_per_level * random_level) + random_stat_distribution.agility,
				moves = monster.spawn_moves
			}
			zoonami.start_battle(mt_player_name, "computer", enemy_monsters)
		end,
	})

	mobs:spawn({
		name = "zoonami:"..monster.asset_name,
		nodes = monster.spawn_on,
		min_light = monster.spawn_min_light,
		interval = monster.spawn_interval,
		chance = monster.spawn_chance,
		min_height = monster.spawn_min_height,
		max_height = monster.spawn_max_height,
		day_toggle = monster.spawn_day_toggle,
	})

	mobs:register_egg("zoonami:"..monster.asset_name, "Spawn "..monster.name, "zoonami_"..monster.asset_name.."_front.png", 0, false)
end
