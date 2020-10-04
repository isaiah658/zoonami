-- Makes formspec code easier to read and write

local fs = {}

function fs.zoom(number)
	return number * fs.player_zoom
end

function fs.dialogue(text)
	local dialogue = fs.box(0, 5, 6, 1, "#000000FF")..
		fs.box(0.1, 5.1, 5.8, 0.8, "#F5F5F5FF")..
		fs.textarea(0.15, 5.15, 5.85, 0.85, text)
	return dialogue
end

function fs.animated_image(x, y, width, height, field_name, file_name, frame_count, frame_duration, frame_start)
	return "animated_image["..fs.zoom(x)..","..fs.zoom(y)..";"..fs.zoom(width)..","..fs.zoom(height)..";"..field_name..";"..file_name..";"..frame_count..";"..frame_duration..";"..frame_start.."]"
end

function fs.arrow_image_button(x, y, width, height, button_type_id, direction, field_name, text)
	return "image_button["..fs.zoom(x)..","..fs.zoom(y)..";"..fs.zoom(width)..","..fs.zoom(height)..";zoonami_arrow"..button_type_id.."_"..direction..".png;"..field_name..";"..text..";false;false;zoonami_arrow"..button_type_id.."_"..direction.."_pressed.png]"
end

function fs.background(x, y, width, height, file_name)
	return "background["..fs.zoom(x)..","..fs.zoom(y)..";"..fs.zoom(width)..","..fs.zoom(height)..";"..file_name.."]"
end

function fs.backpack_header(left_page, right_page, label)
	return "real_coordinates[true]"..
		"bgcolor[#00000000]"..
		fs.style_type_fonts("button,image_button,tooltip,label", "mono,bold", 16, "#000000")..
		fs.background(0.25, 0.25, 10, 5.785, "zoonami_backpack_background.png")..
		fs.image_button(2.56, 0.7, 0.87, 0.59, "zoonami_arrow1_left", left_page, "")..
		fs.image_button(7.11, 0.7, 0.87, 0.59, "zoonami_arrow1_right", right_page, "")..
		fs.image_button(3.56, 0.7, 3.42, 0.59, "zoonami_label1", "label", label)..
		fs.box(2.59, 0.3, 2.94, 0.64, "#00000000")
end

function fs.box(x, y, width, height, color)
	return "box["..fs.zoom(x)..","..fs.zoom(y)..";"..fs.zoom(width)..","..fs.zoom(height)..";"..color.."]"
end

function fs.header(width, height)
	return "formspec_version[3]"..
		"size["..fs.zoom(width)..","..fs.zoom(height)..",true]"..
		"no_prepend[true]"..
		"bgcolor[#F5F5F5]"
end

function fs.image(x, y, width, height, file_name)
	return "image["..fs.zoom(x)..","..fs.zoom(y)..";"..fs.zoom(width)..","..fs.zoom(height)..";"..file_name.."]"
end

function fs.image_button(x, y, width, height, file_name, field_name, text)
	return "image_button["..fs.zoom(x)..","..fs.zoom(y)..";"..fs.zoom(width)..","..fs.zoom(height)..";"..file_name..".png;"..field_name..";"..text..";false;false;"..file_name.."_pressed.png]"
end

function fs.label(x, y, text)
	return "label["..fs.zoom(x)..","..fs.zoom(y)..";"..text.."]"
end

function fs.list(inventory_location, list_name, x, y, width, height)
	return "list["..inventory_location..";"..list_name..";"..x..","..y..";"..width..","..height..";]"
end

function fs.listring(inventory_location, list_name)
	return "listring["..inventory_location..";"..list_name.."]"
end

function fs.menu_image_button(x, y, width, height, button_type_id, field_name, text)
	return "image_button["..fs.zoom(x)..","..fs.zoom(y)..";"..fs.zoom(width)..","..fs.zoom(height)..";zoonami_menu_button"..button_type_id..".png;"..field_name..";"..text..";false;false;zoonami_menu_button"..button_type_id.."_pressed.png]"
end

function fs.style_type_fonts(elements, font_type, font_size, font_color)
	return "style_type["..elements..";font="..font_type..";font_size="..fs.zoom(font_size)..";textcolor="..font_color.."]"
end

function fs.textarea(x, y, width, height, text)
	return "textarea["..fs.zoom(x)..","..fs.zoom(y)..";"..fs.zoom(width)..","..fs.zoom(height)..";;;"..text.."]"
end

function fs.tooltip(field_name, text, background_color, text_color)
	return "tooltip["..field_name..";"..text..";"..background_color..";"..text_color.."]"
end

return fs
