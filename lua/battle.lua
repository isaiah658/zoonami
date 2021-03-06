-- Handles battles between player vs. computer and player vs. player

-- Import functions from other files
local battle = {}
local monster_stats = dofile(minetest.get_modpath("zoonami") .. "/lua/monster_stats.lua")
local move_stats = dofile(minetest.get_modpath("zoonami") .. "/lua/move_stats.lua")
local item_stats = dofile(minetest.get_modpath("zoonami") .. "/lua/item_stats.lua")
local computer = dofile(minetest.get_modpath("zoonami") .. "/lua/computer.lua")
local fs = dofile(minetest.get_modpath("zoonami") .. "/lua/formspec.lua")
local biome = dofile(minetest.get_modpath("zoonami") .. "/lua/biome.lua")

-- Prevents crashes if player leaves during battle and prevents malicious input
function battle.player_check(mt_player_name, battle_context, check_context_lock)
	local mt_player_obj = minetest.get_player_by_name(mt_player_name)
	if not mt_player_obj then return false end
	local meta = mt_player_obj:get_meta()
	local battle_session_id = meta:get_string("zoonami_battle_session_id")
	if check_context_lock then
		check_context_lock = battle_context.locked
	end
	if next(battle_context) == nil or battle_context.session_id ~= battle_session_id or check_context_lock then
		return false
	else
		return mt_player_obj
	end
end

-- Clear music handler and battle session id when player leaves game
minetest.register_on_leaveplayer(function(player)
	local meta = player:get_meta()
	meta:set_string("zoonami_music_handler", "false")
	meta:set_string("zoonami_battle_session_id", 0)
end)

-- Global function to allow starting a battle from mobs mod
function zoonami.start_battle(mt_player_name, enemy_type, enemy_monsters)
	battle.initialize(mt_player_name, enemy_type, enemy_monsters)
end

-- Callback from fsc mod
function battle.fsc_callback(mt_player_obj, fields, battle_context)
	local mt_player_name = mt_player_obj:get_player_name()
	if fields.quit then
		battle.stop(mt_player_name, battle_context)
		return true
	else
		return battle.update(mt_player_name, fields, battle_context)
	end
end

-- Prepares needed components for battling
function battle.initialize(mt_player_name, enemy_type, enemy_monsters)
	local mt_player_obj = minetest.get_player_by_name(mt_player_name)
	if not mt_player_obj then return end
	local meta = mt_player_obj:get_meta()
	fs.player_zoom = meta:get_float("zoonami_gui_zoom")
	local battle_context = {}
	battle_context.player_current_monster = 1
	battle_context.enemy_current_monster = 1
	battle_context.enemy_monsters = enemy_monsters
	battle_context.player_monsters = {}
	battle_context.locked = false
	battle_context.fields_whitelist = nil
	battle_context.biome_background = biome.background(mt_player_obj)
	
	-- Generate battle session id to track when player leaves battle
	local SRNG = SecureRandom()
	assert(SRNG)
	battle_context.session_id = SRNG:next_bytes(16)
	meta:set_string("zoonami_battle_session_id", battle_context.session_id)
	
	-- Loads player's monsters
	local meta = mt_player_obj:get_meta()
	for i = 1, 5 do
		local monster_string = meta:get_string("zoonami_monster_"..i)
		if monster_string then
			battle_context.player_monsters["monster_"..i] = minetest.deserialize(monster_string)
		end
	end
	
	-- Start music for the player
	meta:set_string("zoonami_music_handler", minetest.sound_play("zoonami_battle", {to_player = mt_player_name, gain = 0.6, loop = true}))
	
	-- Show the intro animation
	local formspec = 
		fs.header(6, 6)..
		fs.animated_image(0, 0, 6, 6, "intro_animation", "zoonami_battle_intro_animation.png", 8, 100, 1)
	fsc.show(mt_player_name, formspec, false, function()end)
	
	-- Show battle formspec
	minetest.after(0.85, battle.update, mt_player_name, false, battle_context)
end

-- The main function that handles user input
function battle.update(mt_player_name, fields, battle_context)
	local mt_player_obj = battle.player_check(mt_player_name, battle_context, true)
	if not mt_player_obj then return end
	local player = battle_context.player_monsters["monster_"..battle_context.player_current_monster]
	local enemy = battle_context.enemy_monsters["monster_"..battle_context.enemy_current_monster]
	battle_context.menu, battle_context.animation, battle_context.textbox = "", "", ""
	fields = fields or {}
	
	-- This allows limiting what fields can be sent via a whitelist
	if battle_context.fields_whitelist and next(fields) ~= nil then
		for i, v in pairs (fields) do
			if not battle_context.fields_whitelist[i] then
				fields[i] = nil
			end
		end
	end
	
	-- Play button press if fields isn't empty
	if next(fields) ~= nil then
		minetest.sound_play("zoonami_select", {to_player = mt_player_name, gain = 0.7})
	end
	
	if fields.battle then
		battle.fields_battle(player, battle_context)
	elseif fields.party then
		battle.fields_party(battle_context)
	elseif fields.items then
		battle.fields_items(mt_player_name, battle_context)
	elseif fields.item_1 or fields.item_2 or fields.item_3 or fields.item_4 or fields.item_5 or fields.item_6 or fields.item_7 or fields.item_8 or fields.item_9 or fields.item_10 or fields.item_11 or fields.item_12 then
		battle.fields_item(mt_player_name, player, enemy, fields, battle_context)
	elseif fields.move_1 or fields.move_2 or fields.move_3 or fields.move_4 or fields.move_skip then
		battle.fields_move(mt_player_name, player, enemy, fields, battle_context)
	elseif fields.monster_1 or fields.monster_2 or fields.monster_3 or fields.monster_4 or fields.monster_5 then
		battle.fields_monster(mt_player_name, player, enemy, fields, battle_context)
	else
		battle.fields_main_menu(battle_context)
	end
	
	-- Redraw formspec except when battle sequence starts
	if next(fields) == nil or fields.battle or fields.party or fields.items or fields.main_menu then
		battle.redraw_formspec(mt_player_name, player, enemy, battle_context)
	end
end

-- Shows the battle menu where the player can select a move
function battle.fields_battle(player, battle_context)
	battle_context.menu = battle_context.menu..
		fs.menu_image_button(4.5, 4.5, 1.5, 0.5, 2, "main_menu", "Back")
	for i, v in ipairs (player.moves) do
		battle_context.menu = battle_context.menu..
			fs.menu_image_button((i-1)*(1.5), 5, 1.5, 1, 1, "move_"..i, move_stats[v].name)..
			fs.tooltip("move_"..i, "Attack: "..move_stats[v].power * (100).."%\nEnergy: "..move_stats[v].energy, "#ffffff", "#000000")
	end
end

-- Shows the party menu where the player can select a monster
function battle.fields_party(battle_context)
	battle_context.menu = battle_context.menu..
		fs.image(0, 0, 6, 6, "zoonami_battle_party_background.png")
	if not battle_context.fields_whitelist then
		battle_context.menu = battle_context.menu..
			fs.menu_image_button(4.5, 5.5, 1.5, 0.5, 2, "main_menu", "Back")
	end
	for i = 1, 5 do
		if battle_context.player_monsters["monster_"..i] then
			local monster = battle_context.player_monsters["monster_"..i]
			battle_context.menu = battle_context.menu..
				fs.box(0.25, 0.1+i-0.9, 0.7, 0.7, monster_stats[monster.asset_name].color)..
				fs.menu_image_button(0, 0.1+i-1, 6, 0.92, 3, "monster_"..i, monster.name.."\nH:"..monster.health.."/"..monster.max_health.."  E:"..monster.energy.."/"..monster.max_energy)
		end
	end
end

-- Shows the items menu where the player can select an item
function battle.fields_items(mt_player_name, battle_context)
	local mt_player_obj = battle.player_check(mt_player_name, battle_context, true)
	if not mt_player_obj then return end
	local inv = mt_player_obj:get_inventory()
	local menu_slot_number = 0
	battle_context.menu = fs.image(0, 0, 6, 6, "zoonami_battle_party_background.png")..
		fs.scroll_container(0, 0.1, 6, 5, "items_scroll_container", "vertical", "0.1")
	for i = 1, 12 do
		local stack = inv:get_stack("zoonami_backpack_items", i)
		local stack_name = stack:get_name()
		stack_name = stack_name:gsub("zoonami:", "")
		if item_stats[stack_name] then
			battle_context.menu = battle_context.menu..
			fs.box(0.25, 0.2 + menu_slot_number, 0.7, 0.7, item_stats[stack_name].color)..
			fs.menu_image_button(0, 0.1 + menu_slot_number, 6, 0.92, 3, "item_"..i, item_stats[stack_name].name.."  x"..stack:get_count())
			menu_slot_number = menu_slot_number + 1
		end
	end
	battle_context.menu = battle_context.menu..
		"scroll_container_end[]"..
		"scrollbaroptions[min=0;max=50]"..
		fs.scrollbar(5.75, 0, 0.25, 5, "vertical", "items_scroll_container", "0")..
		fs.menu_image_button(4.5, 5.5, 1.5, 0.5, 2, "main_menu", "Back")
end

-- Called when a player selects an item
function battle.fields_item(mt_player_name, player, enemy, fields, battle_context)
	local mt_player_obj = battle.player_check(mt_player_name, battle_context, true)
	if not mt_player_obj then return end
	battle_context.locked = true
	local inv = mt_player_obj:get_inventory()
	local player_item_index = nil
	for i = 1, 12 do
		if fields["item_"..i] then
			player_item_index = i
		end
	end
	local stack = inv:get_stack("zoonami_backpack_items", player_item_index)
	local stack_name = stack:get_name()
	stack_name = stack_name:gsub("zoonami:", "")
	if item_stats[stack_name] then
		local player_move = item_stats[stack_name]
		local enemy_move = computer.choose_move(mt_player_name, player, enemy)
		enemy_move = move_stats[enemy_move] or enemy_move
		battle.sequence(mt_player_name, player, enemy, battle_context, player_move, enemy_move)
	end
end

-- Called when a player selects a move or skips and checks if it can be used
function battle.fields_move(mt_player_name, player, enemy, fields, battle_context)
	battle_context.locked = true
	local player_move_name = "skip"
	for i = 1, 12 do
		if fields["move_"..i] then
			player_move_name = player.moves[i]
		end
	end
	if move_stats[player_move_name].energy <= player.energy then
		local player_move = move_stats[player_move_name]
		local enemy_move = computer.choose_move(mt_player_name, player, enemy)
		enemy_move = move_stats[enemy_move] or enemy_move
		battle.sequence(mt_player_name, player, enemy, battle_context, player_move, enemy_move)
	else
		battle_context.textbox = fs.dialogue("Not enough energy to use that move.")
		battle.redraw_formspec(mt_player_name, player, enemy, battle_context)
		minetest.after(3, function()
			local new_fields = {battle = true}
			battle_context.locked = false
			battle.update(mt_player_name, new_fields, battle_context)
		end)
	end
end

-- Called when a player wants to switch monsters
function battle.fields_monster(mt_player_name, player, enemy, fields, battle_context)
	battle_context.locked = true
	local player_new_monster = 1
	for i = 1, 5 do
		if fields["monster_"..i] then
			player_new_monster = i
		end
	end
	if battle_context.player_monsters["monster_"..player_new_monster].health > 0 then
		local player_move = {type = "monster", new_monster = player_new_monster}
		local enemy_move = computer.choose_move(mt_player_name, player, enemy)
		enemy_move = move_stats[enemy_move] or enemy_move
		if battle_context.fields_whitelist then
			battle_context.fields_whitelist = nil
			battle_context.player_current_monster = player_new_monster
			player = battle_context.player_monsters["monster_"..player_new_monster]
			local new_fields = {main_menu = true}
			battle_context.locked = false
			battle.update(mt_player_name, new_fields, battle_context)
		else
			battle.sequence(mt_player_name, player, enemy, battle_context, player_move, enemy_move)
		end
	else
		battle_context.textbox = fs.dialogue("That monster is too tired to battle.")
		battle.fields_party(battle_context)
		battle.redraw_formspec(mt_player_name, player, enemy, battle_context)
		minetest.after(3, function()
			local new_fields = {party = true}
			battle_context.locked = false
			battle.update(mt_player_name, new_fields, battle_context)
		end)
	end
end

-- Displays the main menu
function battle.fields_main_menu(battle_context)
	battle_context.menu = fs.menu_image_button(0, 5, 1.5, 1, 1, "battle", "Battle")..
	fs.menu_image_button(1.5, 5, 1.51, 1, 1, "party", "Party")..
	fs.menu_image_button(3, 5, 1.5, 1, 1, "items", "Items")..
	fs.menu_image_button(4.5, 5, 1.51, 1, 1, "move_skip", "Skip")
end

-- Ends the battle and saves the monster stats
function battle.stop(mt_player_name, battle_context)
	local mt_player_obj = battle.player_check(mt_player_name, battle_context, false)
	if not mt_player_obj then return end
	local meta = mt_player_obj:get_meta()
	for i = 1, 5 do
		local monster = battle_context.player_monsters["monster_"..i]
		if monster then
			monster.energy = monster.max_energy
			meta:set_string("zoonami_monster_"..i, minetest.serialize(monster))
		end
	end
	minetest.sound_stop(tonumber(meta:get_string("zoonami_music_handler")))
	meta:set_string("zoonami_battle_session_id", 0)
	-- Ideally I need to rework my code to return true to the fsc mod to close the formspec; this is temporary
	minetest.close_formspec(mt_player_name, "")
end

-- Battle sequence after both the player and enemy have chosen a move
function battle.sequence(mt_player_name, player, enemy, battle_context, player_move, enemy_move)
	local function attack(attacker, defender, move, prefix, animation_name, damage_pos_x, damage_pos_y)
		local mt_player_obj = battle.player_check(mt_player_name, battle_context, false)
		if not mt_player_obj then return end
		attacker.energy = attacker.energy - move.energy
		local damage_dealt = math.floor(math.max((move.power * attacker.attack) - defender.defense, 1))
		defender.health = math.max(defender.health - damage_dealt, 0)
		
		battle_context.animation = 
			fs.animated_image(0, 0, 6, 6, "move_animation", "zoonami_"..animation_name.."_"..move.asset_name.."_animation.png", move.animation_frames, move.frame_length, 1)..
			fs.style_type_fonts("label", "mono,bold", 28, "#FF2407")..
			fs.label(damage_pos_x, damage_pos_y, damage_dealt*-1)
		minetest.sound_play(move.sound, {to_player = mt_player_name, gain = 1})
		battle_context.textbox = fs.dialogue(prefix..attacker.name.." used "..move.name..".")
		battle.redraw_formspec(mt_player_name, player, enemy, battle_context)
	end
	
	local function death()
		local mt_player_obj = battle.player_check(mt_player_name, battle_context, false)
		if not mt_player_obj then return end
		local dead = {}
		if player.health < enemy.health then
			dead.monster = player
			dead.owner = "player"
		else
			dead.monster = enemy
			dead.owner = "enemy"
		end
		battle_context.animation = ""
		local another_monster = false
		for i = 1, 5 do
			local monster_string = battle_context[dead.owner.."_monsters"]["monster_"..i]
			if monster_string and monster_string.health > 0 then
				another_monster = true
			end
		end
		if another_monster then
			battle_context.fields_whitelist = {party = true, monster_1 = true, monster_2 = true, monster_3 = true, monster_4 = true, monster_5 = true}
			battle_context.textbox = fs.dialogue(dead.monster.name.." is too weak to battle.")
			minetest.after(3, function()
				local new_fields = {party = true}
				battle_context.locked = false
				battle.update(mt_player_name, new_fields, battle_context)
			end)
		else
			battle_context.textbox = fs.dialogue(dead.monster.name.." is too weak to battle.")
			minetest.after(3, battle.stop, mt_player_name, battle_context)
		end
		battle.redraw_formspec(mt_player_name, player, enemy, battle_context)
	end
	
	local function end_sequence()
		if player.health > 0 and enemy.health > 0 then
			player.energy = math.min(player.energy + 1, player.max_energy)
			enemy.energy = math.min(enemy.energy + 1, enemy.max_energy)
			battle_context.locked = false
			battle.update(mt_player_name, false, battle_context)
		else
			death()
		end
	end
	
	local attacker = {player, player_move, "Your ", "player", 2, 0.4}
	local defender = {enemy, enemy_move, "Enemy ", "enemy", 4.415, 3}
	if enemy.agility > player.agility or enemy.agility == player.agility and math.random(2) == 1 then
		attacker, defender = defender, attacker
	end
	if attacker[2].type == "skip" then
		battle_context.textbox = fs.dialogue(attacker[3]..attacker[1].name.." used Skip.")
		battle.redraw_formspec(mt_player_name, player, enemy, battle_context)
	elseif attacker[2].type == "healing" then
		local mt_player_obj = battle.player_check(mt_player_name, battle_context, false)
		if not mt_player_obj then return end
		local stack = ItemStack("zoonami:"..attacker[2].asset_name.." 1")
		local inv = mt_player_obj:get_inventory()
		inv:remove_item("zoonami_backpack_items", stack)
		battle_context.textbox = fs.dialogue(attacker[3]..attacker[1].name.." used "..attacker[2].name..".")
		battle_context.animation = fs.style_type_fonts("label", "mono,bold", 28, "#0D720D")..
			fs.label(defender[5], defender[6], "+"..attacker[2].amount)
		attacker[1].health = math.min(attacker[1].health + attacker[2].amount, attacker[1].max_health)
		battle.redraw_formspec(mt_player_name, player, enemy, battle_context)
	elseif attacker[2].type == "monster" then
		battle_context[attacker[4].."_current_monster"] = attacker[2].new_monster
		if attacker[4] == "player" then
			player = battle_context.player_monsters["monster_"..battle_context.player_current_monster]
			attacker[1] = player
		else
			enemy = battle_context.enemy_monsters["monster_"..battle_context.enemy_current_monster]
			attacker[1] = enemy
		end
		battle_context.textbox = fs.dialogue(attacker[3]..attacker[1].name.." switched in.")
		battle.redraw_formspec(mt_player_name, player, enemy, battle_context)
	else
		attack(attacker[1], defender[1], attacker[2], attacker[3], attacker[4], attacker[5], attacker[6])
	end
	if player.health > 0 and enemy.health > 0 then
		minetest.after(3, function()
			battle_context.animation = ""
			if defender[2].type == "skip" then
				battle_context.textbox = fs.dialogue(defender[3]..defender[1].name.." used Skip.")
				battle.redraw_formspec(mt_player_name, player, enemy, battle_context)
			elseif defender[2].type == "healing" then
				local mt_player_obj = battle.player_check(mt_player_name, battle_context, false)
				if not mt_player_obj then return end
				local stack = ItemStack("zoonami:"..attacker[2].asset_name.." 1")
				local inv = mt_player_obj:get_inventory()
				inv:remove_item("zoonami_backpack_items", stack)
				battle_context.textbox = fs.dialogue(defender[3]..defender[1].name.." used "..defender[2].name..".")
				battle_context.animation = fs.style_type_fonts("label", "mono,bold", 28, "#0D720D")..
					fs.label(attacker[5], attacker[6], "+"..defender[2].amount)
				defender[1].health = math.min(defender[1].health + defender[2].amount, defender[1].max_health)
				battle.redraw_formspec(mt_player_name, player, enemy, battle_context)
			elseif defender[2].type == "monster" then
				battle_context[defender[4].."_current_monster"] = defender[2].new_monster
				if defender[4] == "player" then
					player = battle_context.player_monsters["monster_"..battle_context.player_current_monster]
					defender[1] = player
				else
					enemy = battle_context.enemy_monsters["monster_"..battle_context.enemy_current_monster]
					defender[1] = enemy
				end
				battle_context.textbox = fs.dialogue(attacker[3]..defender[1].name.." switched in.")
				battle.redraw_formspec(mt_player_name, player, enemy, battle_context)
			else
				attack(defender[1], attacker[1], defender[2], defender[3], defender[4], defender[5], defender[6])
			end
		end)
		minetest.after(6, end_sequence)
	else
		minetest.after(3, death)
	end
end

-- Creates the formspec and shows it to the player
function battle.redraw_formspec(mt_player_name, player, enemy, battle_context)
	local mt_player_obj = battle.player_check(mt_player_name, battle_context, false)
	if not mt_player_obj then return end
	local formspec = 
        fs.header(6, 6)..
		fs.background(0, 0, 6, 6, battle_context.biome_background)..
		fs.style_type_fonts("button,image_button,tooltip,label", "mono,bold", 16, "#000000")..
		fs.style_type_fonts("textarea", "mono,bold", 15, "#000000")..
		fs.label(0.1, 0.3, enemy.name)..
		fs.label(0.1, 0.6, "Level: "..enemy.level)..
		fs.box(1.5, 0.75, enemy.health/enemy.max_health*2, 0.25, "#25C425FF")..
		fs.label(0.1, 0.9, "Health: "..enemy.health.."/"..enemy.max_health)..
		fs.box(1.5, 1.05, enemy.energy/enemy.max_energy*2, 0.25, "#29B4DBFF")..
		fs.label(0.1, 1.2, "Energy: "..enemy.energy.."/"..enemy.max_energy)..
		fs.image(3.585, 0, 2.4151, 2.4151, "zoonami_"..enemy.asset_name.."_front.png")..
		fs.label(2.515, 2.875, player.name)..
		fs.label(2.515, 3.175, "Level: "..player.level)..
		fs.box(3.915, 3.325, player.health/player.max_health*2, 0.25, "#25C425FF")..
		fs.label(2.515, 3.475, "Health: "..player.health.."/"..player.max_health)..
		fs.box(3.915, 3.625, player.energy/player.max_energy*2, 0.25, "#29B4DBFF")..
		fs.label(2.515, 3.775, "Energy: "..player.energy.."/"..player.max_energy)..
		fs.image(0, 2.4151, 2.4151, 2.4151, "zoonami_"..player.asset_name.."_back.png")..
		battle_context.menu..
		battle_context.animation..
		battle_context.textbox
	fsc.show(mt_player_name, formspec, battle_context, battle.fsc_callback)
end
