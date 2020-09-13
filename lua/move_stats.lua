-- Contains all the moves that monsters can use

local move_stats = {}

move_stats.jab = {
	name = "Jab",
	asset_name = "jab",
	type = "Fighting",
	power = 0.90,
	energy = 1,
	animation_frames = 5,
	frame_length = 125,
	sound = "zoonami_slash"
}

move_stats.punch = {
	name = "Punch",
	asset_name = "punch",
	type = "Fighting",
	power = 1.05,
	energy = 2,
	animation = "",
	animation_frames = 6,
	frame_length = 100,
	sound = "zoonami_punch"
}

move_stats.guard = {
	name = "Guard",
	asset_name = "Guard",
	type = "Defense",
	power = 0.2,
	energy = 2,
	animation = "",
	animation_frames = 0,
	animation_length = 0,
	sound = ""
}

move_stats.barricade = {
	name = "Barricade",
	asset_name = "barricade",
	type = "Defense",
	power = 0.3,
	energy = 3,
	animation = "",
	animation_frames = 0,
	animation_length = 0,
	sound = ""
}

return move_stats