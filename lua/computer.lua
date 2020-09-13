-- Handles the computer's artificial intelligence in battles

local computer = {}

-- Determines what move the computer will choose
function computer.choose_move(name, player, enemy)
	local moves = dofile(minetest.get_modpath("zoonami") .. "/lua/move_stats.lua")
	local max_move_damage = 0
	local selected_move = nil
	
	-- Find move with highest damage
	for i = 1, 4 do
		if enemy.moves[i] then
			local move_damage = math.max((moves[enemy.moves[i]].power * enemy.attack) - player.defense, 1)
			if move_damage > max_move_damage then
				if moves[enemy.moves[i]].energy <= enemy.energy then
					selected_move = enemy.moves[i]
				end
			end
		end
	end
	if selected_move == nil then
		selected_move = "skip"
	end
	
	return selected_move
end

return computer
