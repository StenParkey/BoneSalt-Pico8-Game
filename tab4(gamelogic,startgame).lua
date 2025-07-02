-- game logic

-- collision detection
function is_blocked(x, y)
	local hitbox_w = 6
	local hitbox_h = 6

	local x_offset = 1
	local y_offset = 1

	local x1 = flr((x + x_offset) / 8)
	local y1 = flr((y + y_offset) / 8)
	local x2 = flr((x + x_offset + hitbox_w - 1) / 8)
	local y2 = flr((y + y_offset + hitbox_h - 1) / 8)

	return fget(mget(x1, y1), 0)
		or fget(mget(x2, y1), 0)
		or fget(mget(x1, y2), 0)
		or fget(mget(x2, y2), 0)
end

-- player movement
function move_player(dx, dy)
	local steps = ceil(max(abs(dx), abs(dy)))
	local step_x = dx / steps
	local step_y = dy / steps

	for i = 1, steps do
		local test_x = player_x + step_x
		local test_y = player_y + step_y

		-- attempt full diagonal move first
		if not is_blocked(test_x, test_y) then
			player_x = test_x
			player_y = test_y
		else
			-- if diagonal blocked, try horizontal move
			if not is_blocked(player_x + step_x, player_y) then
				player_x += step_x
			-- or try vertical move
			elseif not is_blocked(player_x, player_y + step_y) then
				player_y += step_y
			end

			-- if all are blocked, break
			break
		end
	end
end

-- camera movement
function center_camera_on_player()
	local cam_x = mid(0, player_x - 64, 128)
	local cam_y = mid(0, player_y - 64, 128)
	camera(cam_x, cam_y)
end

-- test player start position
player_x = 64
player_y = 64

function draw_game_test_state()
	center_camera_on_player()

	-- draw map at world (0,0)
	map(0, 0, 0, 0, 32, 32)

	spr(player_info.sp, player_x, player_y)

	for e in all(enemy_instances) do
    	spr(enemies[e.type].sp, e.x, e.y)
	end
	
	-- draw enemy projectiles
    for p in all(enemy_projectiles) do
        spr(p.sp, p.x, p.y)
    end
	
	-- reset camera for ui
	camera()

    -- hp and mp bar
	rectfill(0, 0, 128, 20, 1)
	draw_health(3, 2, player_info.hp, heart_hover_timer)
	draw_mana_bar(3, 11, player_info.mp, player_info.mp, selected_char == "svar")
 	rectfill(0, 113, 128, 128, 0)
 
    local l_y_offset = light_ability_bump_timer > 0 and -1 or 0
	local h_y_offset = heavy_ability_bump_timer > 0 and -1 or 0
	local s_y_offset = special_ability_bump_timer > 0 and -1 or 0
	local ability_offsets = {l_y_offset, h_y_offset, s_y_offset}

	for i=0,2 do
		local x = 10 + i * 37
		local y = 115 + ability_offsets[i+1]
		rect(x, y, x + 33, y + 12, 5)
	end

	spr(6, 12, 117 + l_y_offset)
	print("light", 22, 119 + l_y_offset, 2)

	spr(38, 49, 117 + h_y_offset)
	print("heavy", 59, 119 + h_y_offset, 8)

	spr(22, 86, 117 + s_y_offset)
	print("speci", 95, 119 + s_y_offset, 11)
end