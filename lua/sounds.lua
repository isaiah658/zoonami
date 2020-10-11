-- Uses default mod sounds if they are installed otherwise fallsback to Zoonami sounds

local sounds = {}

-- Snappy
function sounds.node_sound_snappy(sound_table)
	if minetest.get_modpath("default") ~= nil then
		sound_table = default.node_sound_snappy()
	else
		sound_table = sound_table or {}
	end
	sound_table.footstep = sound_table.footstep or
			{name = "zoonami_grass_footstep", gain = 1.0}
	sound_table.dug = sound_table.dug or
			{name = "zoonami_grass_footstep", gain = 1.0}
	sound_table.place = sound_table.place or
			{name = "zoonami_node_place", gain = 1.0}
	return sound_table
end