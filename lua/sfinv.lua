-- Manages everything involving the sfinv mod

if minetest.get_modpath("sfinv") ~= nil then
	sfinv.register_page("zoonami:settings", {
		title = "Zoonami",
		get = function(self, player, context)
			local meta = player:get_meta()
			local zoonami_gui_zoom = meta:get_float("zoonami_gui_zoom")
			local formspec = 
				"formspec_version[3]"..
				"style_type[button,image_button,tooltip,label;font=mono,bold;font_size=16;textcolor=#ffffff]"..
				"button[0,0;1,1;decrease;-]"..
				"button[1,0;1,1;increase;+]"..
				"label[2,0.2;Battle GUI Size: "..zoonami_gui_zoom.."]"
			return sfinv.make_formspec(player, context, formspec, true)
		end,
		on_player_receive_fields = function(self, player, context, fields)
			local meta = player:get_meta()
			local zoonami_gui_zoom = meta:get_float("zoonami_gui_zoom")
			if fields.increase then
				zoonami_gui_zoom = math.min(zoonami_gui_zoom + 0.5, 3)
				meta:set_float("zoonami_gui_zoom", zoonami_gui_zoom)
			elseif fields.decrease then
				zoonami_gui_zoom = math.max(zoonami_gui_zoom - 0.5, 1)
				meta:set_float("zoonami_gui_zoom", zoonami_gui_zoom)
			end
			sfinv.set_page(player, "zoonami:settings")
		end,
	})
end