-- Manages everything involving the backpack formspec

local backpack = {}
local fs = dofile(minetest.get_modpath("zoonami") .. "/lua/formspec.lua")

minetest.register_craftitem("zoonami:backpack", {
	description = "Backpack",
	inventory_image = "zoonami_backpack.png",
	stack_max = 1,
	on_secondary_use = function (itemstack, user, pointed_thing)
		backpack.show_formspec(user)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		backpack.show_formspec(placer)
	end,
})

minetest.register_on_player_receive_fields(function(mt_player_obj, formname, fields)
	if formname == "zoonami:backpack" then
		backpack.receive_fields(mt_player_obj, fields)
		backpack.show_formspec(mt_player_obj)
	end
end)

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

function backpack.receive_fields(mt_player_obj, fields)
	local meta = mt_player_obj:get_meta()
	if fields.items or fields.monsters or fields.settings or fields.player_stats then
		minetest.sound_play("zoonami_select2", {to_player = mt_player_name, gain = 0.5})
	end
	if fields.items then
		meta:set_string("zoonami_backpack_page", "items")
	elseif fields.monsters then
		meta:set_string("zoonami_backpack_page", "monsters")
	elseif fields.settings then
		meta:set_string("zoonami_backpack_page", "settings")
	elseif fields.player_stats then
		meta:set_string("zoonami_backpack_page", "player_stats")
	elseif fields.battle_gui_zoom_increase then
		backpack.fields_battle_gui_zoom_increase(mt_player_obj)
	elseif fields.battle_gui_zoom_decrease then
		backpack.fields_battle_gui_zoom_decrease(mt_player_obj)
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
	local meta = mt_player_obj:get_meta()
	local zoonami_gui_zoom = meta:get_float("zoonami_gui_zoom")
	return fs.backpack_header("monsters", "player_stats", "Settings")..
		fs.image_button(6.75, 1.7, 0.87, 0.59, "zoonami_menu_button4", "battle_gui_zoom_decrease", "-")..
		fs.image_button(7.75, 1.7, 0.87, 0.59, "zoonami_menu_button4", "battle_gui_zoom_increase", "+")..
		fs.label(1.75, 2, "Battle GUI Size: "..zoonami_gui_zoom)
end

function backpack.fields_player_stats(mt_player_obj)
	return fs.backpack_header("settings", "items", "Player Stats")
end

function backpack.fields_battle_gui_zoom_increase(mt_player_obj)
	local meta = mt_player_obj:get_meta()
	local zoonami_gui_zoom = meta:get_float("zoonami_gui_zoom")
	zoonami_gui_zoom = math.min(zoonami_gui_zoom + 0.5, 3)
	meta:set_float("zoonami_gui_zoom", zoonami_gui_zoom)
end

function backpack.fields_battle_gui_zoom_decrease(mt_player_obj)
	local meta = mt_player_obj:get_meta()
	local zoonami_gui_zoom = meta:get_float("zoonami_gui_zoom")
	zoonami_gui_zoom = math.max(zoonami_gui_zoom - 0.5, 1)
	meta:set_float("zoonami_gui_zoom", zoonami_gui_zoom)
end
