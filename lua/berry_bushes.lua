-- Handles all the berry bushes and growing

local sounds = dofile(minetest.get_modpath("zoonami") .. "/lua/sounds.lua")

function zoonami.register_berry_bush(def)
	minetest.register_node("zoonami:"..def.name.."_bush_1", {
		description = def.description,
		drawtype = "plantlike",
		visual_scale = 1,
		waving = 1,
		tiles = {"zoonami_"..def.name.."_bush_1.png"},
		inventory_image = "zoonami_"..def.name.."_bush_2.png",
		wield_image = "zoonami_"..def.name.."_bush_2.png",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		buildable_to = true,
		groups = {snappy = 3, flammable = 3, flora = 1, attached_node = 1, zoonami_berry_bush = 1},
		sounds = sounds.node_sound_leaves(),
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		},
	})
	minetest.register_node("zoonami:"..def.name.."_bush_2", {
		description = def.description,
		drawtype = "plantlike",
		visual_scale = 1,
		waving = 1,
		tiles = {"zoonami_"..def.name.."_bush_2.png"},
		inventory_image = "zoonami_"..def.name.."_bush_2.png",
		wield_image = "zoonami_"..def.name.."_bush_2.png",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		buildable_to = true,
		groups = {snappy = 3, flammable = 3, flora = 1, attached_node = 1, not_in_creative_inventory = 1},
		sounds = sounds.node_sound_leaves(),
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		},
		drop = {
			items = {
				{items = {"zoonami:"..def.name, "zoonami:"..def.name.."_bush_1"}}
			}
		},
		on_rightclick = function(pos, node, player, itemstack, pointed_thing)
			local newnode = ("zoonami:"..def.name.."_bush_1")
			minetest.swap_node(pos, {name = newnode})
			local inv = player:get_inventory()
			local itemdrop = ItemStack("zoonami:"..def.name)
			minetest.after(0, function() 
				local leftover = inv:add_item("main", itemdrop)
				if leftover:get_count() > 0 then
					local droppos = pos
					local xposrandom = math.random() * math.random(-0.9, 0.9)
					local zposrandom = math.random() * math.random(-0.9, 0.9)
					droppos.x = droppos.x + xposrandom
					droppos.z = droppos.z + zposrandom
					minetest.add_item(droppos, itemdrop)
				end
			end)
		end,
	})
end

-- Berry Bush Growth
minetest.register_abm({
	nodenames = {"group:zoonami_berry_bush"},
	neighbors = {"group:soil"},
	interval = 45,
	chance = 15,
	action = function(pos, node)
		local berry_bush_name = node.name:gsub("_1", "")
		minetest.set_node(pos, {name = berry_bush_name.."_2"})
	end
})

-- Red Berry Bush
zoonami.register_berry_bush({
	name = "red_berry",
	description = "Red Berry Bush",
})

-- Blue Berry Bush
zoonami.register_berry_bush({
	name = "blue_berry",
	description = "Blue Berry Bush",
})
