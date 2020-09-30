-- Handles the busy work of determining which battle background should be chosen based off of biomes or heat, humidty, and nodes

local biome = {}

biome.grassland = "grassland"
biome.savanna = "grassland"
biome.coniferous_forest = "forest"
biome.deciduous_forest = "forest"
biome.rainforest = "forest"
biome.icesheet = "snowy"
biome.icesheet_ocean = "snowy"
biome.tundra = "snowy"
biome.tundra_beach = "snowy"
biome.taiga = "snowy"
biome.snowy_grassland = "snowy"
biome.grassland_dunes = "beach"
biome.coniferous_forest_dunes = "beach"
biome.desert = "desert"
biome.sandstone_desert = "desert"
biome.cold_desert = "desert"
biome.tundra_ocean = "underwater"
biome.grassland_ocean = "underwater"
biome.taiga_ocean = "underwater"
biome.coniferous_forest_ocean = "underwater"
biome.snowy_grassland_ocean = "underwater"
biome.deciduous_forest_shore = "underwater"
biome.deciduous_forest_ocean = "underwater"
biome.rainforest_swamp = "underwater"
biome.rainforest_ocean = "underwater"
biome.savanna_shore = "underwater"
biome.savanna_ocean = "underwater"
biome.cold_desert_ocean = "underwater"
biome.sandstone_desert_ocean = "underwater"
biome.desert_ocean = "underwater"
biome.underground = "underground"

function biome.background(mt_player_obj)
	local player_pos = mt_player_obj:get_pos()
	player_pos.y = player_pos.y - 0.5
	local biome_data = minetest.get_biome_data(player_pos)
	local biome_name = minetest.get_biome_name(biome_data.biome)
	if biome[biome_name] then
		return "zoonami_"..biome[biome_name].."_background.png"
	else
		local node = minetest.get_node(player_pos)
		if string.find(node.name, "grass") and biome_data.humidty and biome_data.humidty < 70 then
			return "zoonami_grassland_background.png"
		elseif string.find(node.name, "grass") and biome_data.humidty and biome_data.humidty >= 70 then
			return "zoonami_forest_background.png"
		elseif string.find(node.name, "grass") then
			return "zoonami_grassland_background.png"
		elseif string.find(node.name, "snow") then
			return "zoonami_snowy_background.png"
		elseif string.find(node.name, "sand") and biome_data.humidty and biome_data.humidty < 40 then
			return "zoonami_desert_background.png"
		elseif string.find(node.name, "sand") and biome_data.humidty and biome_data.humidty > 40 then
			return "zoonami_beach_background.png"
		elseif string.find(node.name, "sand") then
			return "zoonami_desert_background.png"
		elseif string.find(node.name, "water") then
			return "zoonami_underwater_background.png"
		elseif string.find(node.name, "stone") and player_pos.y <= -10 then
			return "zoonami_underground_background.png"
		else
			return "zoonami_grassland_background.png"
		end
	end
end

return biome