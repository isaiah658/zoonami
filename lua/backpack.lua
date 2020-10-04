-- Manages everything involving the backpack formspec

local backpack = {}
local fs = dofile(minetest.get_modpath("zoonami") .. "/lua/formspec.lua")

function backpack.fields_items(mt_player_obj)
	local inv = mt_player_obj:get_inventory()
	inv:set_size("zoonami_backpack_items", 12)
	return fs.list("current_player", "zoonami_backpack_items", 1, 2.2, 6, 2, 0)..
		fs.backpack_header("player_stats", "monsters", "Items")..
		fs.listring("current_player", "main")..
		fs.listring("current_player", "zoonami_backpack_items")
end

function backpack.fields_monsters(mt_player_obj)
	return fs.backpack_header("items", "settings", "Monsters")
end

function backpack.fields_settings(mt_player_obj)
	return fs.backpack_header("monsters", "player_stats", "Settings")
end

function backpack.fields_player_stats(mt_player_obj)
	return fs.backpack_header("settings", "items", "Player Stats")
end

function backpack.receive_fields(mt_player_obj, fields)
	local meta = mt_player_obj:get_meta()
	if fields.items then
		meta:set_string("zoonami_backpack_page", "items")
	elseif fields.monsters then
		meta:set_string("zoonami_backpack_page", "monsters")
	elseif fields.settings then
		meta:set_string("zoonami_backpack_page", "settings")
	elseif fields.player_stats then
		meta:set_string("zoonami_backpack_page", "player_stats")
	end
end

function backpack.show_formspec(mt_player_obj)
	fs.player_zoom = 1
	local mt_player_name = mt_player_obj:get_player_name()
	local meta = mt_player_obj:get_meta()
	local page = meta:get_string("zoonami_backpack_page")
	if page == "" then
		page = "items"
	end
	local formspec = "formspec_version[1]"..
		"size[8,9.1]"..
		fs.list("current_player", "main", 0, 5.2, 8, 1, 0)..
		fs.list("current_player", "main", 0, 6.35, 8, 3, 8)..
		backpack["fields_"..page](mt_player_obj)
	minetest.show_formspec(mt_player_name, "zoonami:backpack", formspec)
end

minetest.register_on_player_receive_fields(function(mt_player_obj, formname, fields)
	if formname == "zoonami:backpack" then
		backpack.receive_fields(mt_player_obj, fields)
		backpack.show_formspec(mt_player_obj)
	end
end)

minetest.register_craftitem("zoonami:backpack", {
	description = "Backpack",
	inventory_image = "zoonami_backpack.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		backpack.show_formspec(user)
	end,
})

if minetest.get_modpath("sfinv") ~= nil then
	sfinv.register_page("zoonami:backpack", {
		title = "Zoonami",
		get = function(self, mt_player_obj, context)
			fs.player_zoom = 1
			local meta = mt_player_obj:get_meta()
			local page = meta:get_string("zoonami_backpack_page")
			if page == "" then
				page = "items"
			end
			local formspec = backpack["fields_"..page](mt_player_obj)
			return sfinv.make_formspec(mt_player_obj, context, formspec, true)
		end,
		on_player_receive_fields = function(self, mt_player_obj, context, fields)
			backpack.receive_fields(mt_player_obj, fields)
			sfinv.set_page(mt_player_obj, "zoonami:backpack")
		end,
	})
end
