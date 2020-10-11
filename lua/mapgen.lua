-- Handles basic mapgen features of Zoonami

minetest.register_decoration({
	name = "zoonami:red_berry_bush_2",
	deco_type = "simple",
	place_on = {"group:soil"},
	sidelen = 16,
	noise_params = {
		offset = -0.004,
		scale = 0.0015,
		spread = {x = 100, y = 100, z = 100},
		seed = 8434,
		octaves = 3,
		persist = 0.7
	},
	biomes = {"grassland", "deciduous_forest"},
	y_max = 31000,
	y_min = 0,
	decoration = "zoonami:red_berry_bush_2",
})

minetest.register_decoration({
	name = "zoonami:blue_berry_bush_2",
	deco_type = "simple",
	place_on = {"group:soil"},
	sidelen = 16,
	noise_params = {
		offset = -0.004,
		scale = 0.0015,
		spread = {x = 100, y = 100, z = 100},
		seed = 8414,
		octaves = 3,
		persist = 0.7
	},
	biomes = {"grassland", "deciduous_forest"},
	y_max = 31000,
	y_min = 0,
	decoration = "zoonami:blue_berry_bush_2",
})
