-- Handles battles between player vs. computer and player vs. player

-- Import functions from other files
local battle = {}
local monster_stats = dofile(minetest.get_modpath("zoonami") .. "lua/monster_stats.lua")
local move_stats = dofile(minetest.get_modpath("zoonami") .. "lua/move_stats.lua")
local computer = dofile(minetest.get_modpath("zoonami") .. "lua/computer.lua")

-- Controls formspec zoom amount
local function z(number)
	local zoom = battle.player_zoom
	return number * zoom
end

-- Turns the submitted dialogue into a textbox in formspec format
local function dialogue_write(text)
	local dialogue = "box[0,"..z(5)..";"..z(6)..","..z(1)..";#000000FF]"..
		"box["..z(0.1)..","..z(5.1)..";"..z(5.8)..","..z(0.8)..";#F5F5F5FF]"..
		"textarea["..z(0.15)..","..z(5.15)..";"..z(5.85)..","..z(0.85)..";;;"..text.."]"
	return dialogue
end

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
	if fields.quit then
		local meta = mt_player_obj:get_meta()
		minetest.sound_stop(tonumber(meta:get_string("zoonami_music_handler")))
		meta:set_string("zoonami_music_handler", "false")
		meta:set_string("zoonami_battle_session_id", 0)
		return true
	else
		local mt_player_name = mt_player_obj:get_player_name()
		return battle.update(mt_player_name, fields, battle_context)
	end
end

-- Prepares needed components for battling
function battle.initialize(mt_player_name, enemy_type, enemy_monsters)
	local mt_player_obj = minetest.get_player_by_name(mt_player_name)
	if not mt_player_obj then return end
	local meta = mt_player_obj:get_meta()
	battle.player_zoom = meta:get_float("zoonami_gui_zoom")
	local battle_context = {}
	battle_context.player_current_monster = 1
	battle_context.enemy_current_monster = 1
	battle_context.enemy_monsters = enemy_monsters
	battle_context.player_monsters = {}
	battle_context.locked = false
	
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
		"formspec_version[3]"..
        "size["..z(6)..","..z(6)..",true]"..
		"no_prepend[true]"..
		"animated_image[0,0;"..z(6)..","..z(6)..";intro_animation;zoonami_battle_intro_animation.png;8;100;1]"
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
	local menu, textbox, animation = "", "", ""
	fields = fields or {}
	
	-- Play button press if fields isn't empty
	if next(fields) ~= nil then
		minetest.sound_play("zoonami_select", {to_player = mt_player_name, gain = 0.7})
	end
	
	if fields.battle then
		menu = menu.."image_button["..z(4.5)..","..z(4.5)..";"..z(1.5)..","..z(0.5)..";zoonami_menu_button2.png;main_menu;Back;false;false;zoonami_menu_button2_pressed.png]"
		for i, v in ipairs (player.moves) do
			menu = menu.."image_button["..z((i-1)*(1.5))..","..z(5)..";"..z(1.5)..","..z(1)..";zoonami_menu_button1.png;move_"..i..";"..move_stats[v].name..";false;false;zoonami_menu_button1_pressed.png]"..
			"tooltip[move_"..i..";Attack: "..move_stats[v].power * (100).."%\nEnergy: "..move_stats[v].energy..";#ffffff;#000000]"
		end
	elseif fields.party then
		local meta = mt_player_obj:get_meta()
		menu = menu.."image[0,0;"..z(6)..","..z(6)..";zoonami_battle_party_background.png]".."image_button["..z(4.5)..","..z(5.5)..";"..z(1.5)..","..z(0.5)..";zoonami_menu_button2.png;main_menu;Back;false;false;zoonami_menu_button2_pressed.png]"
		for i = 1, 5 do
			if battle_context.player_monsters["monster_"..i] then
				local monster = battle_context.player_monsters["monster_"..i]
				menu = menu.."box["..z(0.25)..","..z(0.1+i-0.9)..";"..z(0.7)..","..z(0.7)..";"..monster_stats[monster.asset_name].color.."]".."image_button[0,"..z(0.1+i-1)..";"..z(6)..","..z(0.92)..";zoonami_menu_button3.png;monster_"..i..";"..monster.name.."\nH:"..monster.health.."/"..monster.max_health.."  E:"..monster.energy.."/"..monster.max_energy..";false;false;zoonami_menu_button3_pressed.png]"
			end
		end
	elseif fields.items then
		textbox = dialogue_write("This feature is not implemented yet.")
		minetest.after(3, battle.update, mt_player_name, false, battle_context)
	elseif fields.move_1 or fields.move_2 or fields.move_3 or fields.move_4 then
		battle_context.locked = true
		local player_move_name = nil
		for i = 1, 4 do
			if fields["move_"..i] then
				player_move_name = player.moves[i]
			end
		end
		-- Start the battle sequence if the player has enough energy to use the move otherwise inform player of low energy
		if move_stats[player_move_name].energy <= player.energy then
			local player_move = move_stats[player_move_name]
			local enemy_move = move_stats[computer.choose_move(mt_player_name, player, enemy)]
			battle.sequence(mt_player_name, player, enemy, menu, textbox, animation, battle_context, player_move, enemy_move)
		else
			textbox = dialogue_write("Not enough energy to use that move.")
			battle.redraw_formspec(mt_player_name, player, enemy, menu, textbox, animation, battle_context)
			minetest.after(3, function()
				local new_fields = {battle = true}
				battle_context.locked = false
				battle.update(mt_player_name, new_fields, battle_context)
			end)
		end
	elseif fields.move_skip then
		local player_move = "skip"
		local enemy_move = move_stats[computer.choose_move(mt_player_name, player, enemy)]
		battle.sequence(mt_player_name, player, enemy, menu, textbox, animation, battle_context, player_move, enemy_move)
	elseif fields.monster_1 or fields.monster_2 or fields.monster_3 or fields.monster_4 or fields.monster_5 then
		battle_context.locked = true
		local player_new_monster = 1
		for i = 1, 5 do
			if fields["monster_"..i] then
				player_new_monster = i
			end
		end
		if battle_context.player_monsters["monster_"..player_new_monster].health > 0 then
			local player_move = player_new_monster
			local enemy_move = move_stats[computer.choose_move(mt_player_name, player, enemy)]
			battle.sequence(mt_player_name, player, enemy, menu, textbox, animation, battle_context, player_move, enemy_move)
		else
			textbox = dialogue_write("Monster is too tired to battle.")
			battle.redraw_formspec(mt_player_name, player, enemy, menu, textbox, animation, battle_context)
			minetest.after(3, function()
				local new_fields = {party = true}
				battle_context.locked = false
				battle.update(mt_player_name, new_fields, battle_context)
			end)
		end
	else
		menu = "image_button[0,"..z(5)..";"..z(1.5)..","..z(1)..";zoonami_menu_button1.png;battle;Battle;false;false;zoonami_menu_button1_pressed.png]"..
		"image_button["..z(1.5)..","..z(5)..";"..z(1.51)..","..z(1)..";zoonami_menu_button1.png;party;Party;false;false;zoonami_menu_button1_pressed.png]"..
		"image_button["..z(3)..","..z(5)..";"..z(1.5)..","..z(1)..";zoonami_menu_button1.png;items;Items;false;false;zoonami_menu_button1_pressed.png]"..
		"image_button["..z(4.5)..","..z(5)..";"..z(1.51)..","..z(1)..";zoonami_menu_button1.png;move_skip;Skip;false;false;zoonami_menu_button1_pressed.png]"
	end
	
	-- Redraw formspec except when battle sequence starts
	if next(fields) == nil or fields.battle or fields.party or fields.items or fields.main_menu then
		battle.redraw_formspec(mt_player_name, player, enemy, menu, textbox, animation, battle_context)
	end
end

-- Battle sequence after both the player and enemy have chosen a move
function battle.sequence(mt_player_name, player, enemy, menu, textbox, animation, battle_context, player_move, enemy_move)
	local function attack(attacker, defender, move, prefix, animation_name, damage_pos_x, damage_pos_y)
		local mt_player_obj = battle.player_check(mt_player_name, battle_context, false)
		if not mt_player_obj then return end
		attacker.energy = attacker.energy - move.energy
		local damage_dealt = math.floor(math.max((move.power * attacker.attack) - defender.defense, 1))
		defender.health = math.max(defender.health - damage_dealt, 0)
		animation = "animated_image[0,0;"..z(6)..","..z(6)..";move_animation;zoonami_"..animation_name.."_"..move.asset_name.."_animation.png;"..move.animation_frames..";"..move.frame_length..";1]".."style_type[label;font_size="..z(28)..";textcolor=#FF2407]".."label["..z(damage_pos_x)..","..z(damage_pos_y)..";"..(damage_dealt * -1).."]"
		minetest.sound_play(move.sound, {to_player = mt_player_name, gain = 1})
		textbox = dialogue_write(prefix..attacker.name.." used "..move.name..".")
		battle.redraw_formspec(mt_player_name, player, enemy, menu, textbox, animation, battle_context)
	end
	
	local function end_battle()
		local mt_player_obj = battle.player_check(mt_player_name, battle_context, false)
		if not mt_player_obj then return end
		local meta = mt_player_obj:get_meta()
		player.energy = player.max_energy
		meta:set_string("zoonami_monster_"..battle_context.player_current_monster, minetest.serialize(player))
		minetest.sound_stop(meta:get_string("zoonami_music_handler"))
		-- Ideally I need to rework my code to return true to the fsc mod to close the formspec; this is temporary
		minetest.close_formspec(mt_player_name, "")
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
		textbox = dialogue_write(dead.monster.name.." is too weak to battle.")
		animation = ""
		battle.redraw_formspec(mt_player_name, player, enemy, menu, textbox, animation, battle_context)
		local another_monster = false
		for i = 1, 5 do
			local monster_string = battle_context[dead.owner.."_monsters"]["monster_"..i]
			if monster_string and monster_string.health > 0 then
				another_monster = true
			end
		end
		if another_monster then
			-- Choose monster
		else
			minetest.after(3, end_battle)
		end
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
	if attacker[2] == "skip" then
		textbox = dialogue_write(attacker[3]..attacker[1].name.." used skip.")
		battle.redraw_formspec(mt_player_name, player, enemy, menu, textbox, animation, battle_context)
	elseif type(attacker[2]) == "number" then
		battle_context[attacker[4].."_current_monster"] = attacker[2]
		if attacker[4] == "player" then
			player = battle_context.player_monsters["monster_"..battle_context.player_current_monster]
			attacker[1] = player
		else
			enemy = battle_context.enemy_monsters["monster_"..battle_context.enemy_current_monster]
			attacker[1] = enemy
		end
		textbox = dialogue_write(attacker[3]..attacker[1].name.." switched in.")
		battle.redraw_formspec(mt_player_name, player, enemy, menu, textbox, animation, battle_context)
	else
		attack(attacker[1], defender[1], attacker[2], attacker[3], attacker[4], attacker[5], attacker[6])
	end
	if player.health > 0 and enemy.health > 0 then
		minetest.after(3, function()
			animation = ""
			if defender[2] == "skip" then
				textbox = dialogue_write(defender[3]..defender[1].name.." used skip.")
				battle.redraw_formspec(mt_player_name, player, enemy, menu, textbox, animation, battle_context)
			elseif type(defender[2]) == "number" then
				battle_context[defender[4].."_current_monster"] = defender[2]
				if defender[4] == "player" then
					player = battle_context.player_monsters["monster_"..battle_context.player_current_monster]
					defender[1] = player
				else
					enemy = battle_context.enemy_monsters["monster_"..battle_context.enemy_current_monster]
					defender[1] = enemy
				end
				textbox = dialogue_write(attacker[3]..defender[1].name.." switched in.")
				battle.redraw_formspec(mt_player_name, player, enemy, menu, textbox, animation, battle_context)
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
function battle.redraw_formspec(mt_player_name, player, enemy, menu, textbox, animation, battle_context)
	local mt_player_obj = battle.player_check(mt_player_name, battle_context, false)
	if not mt_player_obj then return end
	local formspec = 
        "formspec_version[3]"..
        "size["..z(6)..","..z(6)..",true]"..
		"no_prepend[true]"..
		"bgcolor[#F5F5F5]"..
		"background[0,0;"..z(6)..","..z(6)..";zoonami_battle_background.png]"..
		"style_type[button,image_button,tooltip,label;font=mono,bold;font_size="..z(16)..";textcolor=#000000]"..
		"style_type[textarea;font=mono,bold;font_size="..z(15)..";textcolor=#000000]"..
		"label["..z(0.1)..","..z(0.3)..";"..enemy.name.."]"..
		"label["..z(0.1)..","..z(0.6)..";Level: "..enemy.level.."]"..
		"box["..z(1.5)..","..z(0.75)..";"..z(enemy.health/enemy.max_health*2)..","..z(0.25)..";#25C425FF]"..
		"label["..z(0.1)..","..z(0.9)..";Health: "..enemy.health.."/"..enemy.max_health.."]"..
		"box["..z(1.5)..","..z(1.05)..";"..z(enemy.energy/enemy.max_energy*2)..","..z(0.25)..";#29B4DBFF]"..
		"label["..z(0.1)..","..z(1.2)..";Energy: "..enemy.energy.."/"..enemy.max_energy.."]"..
		"image["..z(3.585)..",0;"..z(2.4151)..","..z(2.4151)..";zoonami_"..enemy.asset_name.."_front.png]"..
		"label["..z(2.515)..","..z(2.875)..";"..player.name.."]"..
		"label["..z(2.515)..","..z(3.175)..";Level: "..player.level.."]"..
		"box["..z(3.915)..","..z(3.325)..";"..z(player.health/player.max_health*2)..","..z(0.25)..";#25C425FF]"..
		"label["..z(2.515)..","..z(3.475)..";Health: "..player.health.."/"..player.max_health.."]"..
		"box["..z(3.915)..","..z(3.625)..";"..z(player.energy/player.max_energy*2)..","..z(0.25)..";#29B4DBFF]"..
		"label["..z(2.515)..","..z(3.775)..";Energy: "..player.energy.."/"..player.max_energy.."]"..
		"image[0,"..z(2.4151)..";"..z(2.4151)..","..z(2.4151)..";zoonami_"..player.asset_name.."_back.png]"..
		menu..
		animation..
		textbox
	fsc.show(mt_player_name, formspec, battle_context, battle.fsc_callback)
end