-- init, update, draw
function _init()
		sfx(0)
end

function _update()
    --splash startup screen
	if state == "splash" then
		splash_letter_timer += 1
		if splash_letter_timer >= splash_letter_delay and splash_letters < #splash_text then
			splash_letter_timer = 0
			splash_letters += 1
		end
		splash_timer += 1/30
		if splash_timer >= splash_duration or btnp(4) or btnp(5) or btnp(6) then
			state = "menu"
			sfx(-1, 0)
		end
    
    -- Main Menu
	elseif state == "menu" then
		eye_timer += 1

		if eye_timer > 8 then 
			eye_timer = 0
			eye_frame += eye_direction
			logo_hover_timer += 0.06
			skull_hover_timer += 0.08
			if eye_frame == #left_eye_frames or eye_frame == 1 then
				eye_direction *= -1
			end
		end
		
		if btnp(2) then 
			menu_index = max(1, menu_index - 1)
			sfx(1)
		elseif btnp(3) then 
			menu_index = min(#menu_items, menu_index + 1)
			sfx(1)
		elseif btnp(4) then 
			sfx(2)
			if menu_index == 1 then
				state = "char_select"
			elseif menu_index == 2 then
				state = "secrets"
			elseif menu_index == 3 then
				state = "controls"
			end
		end

    -- Controls Screen
	elseif state == "controls" then
		ability_icon_hover_timer += 0.07

		if btnp(4) or btnp(5) then
			state = "menu"
			sfx(2)
		end
    
    -- Character Select Menu
    elseif state == "char_select" then
		if player_info.sp == 1 then
			char_hover_timer += 0.026
		elseif player_info.sp == 2 then
			char_hover_timer += 0.015
		elseif player_info.sp == 3 then
			char_hover_timer += 0.06
		elseif player_info.sp == 4 then
			char_hover_timer += 0.02
		elseif player_info.sp == 5 then
			char_hover_timer += 0.012
		end

		heart_hover_timer = (heart_hover_timer or 0) + 0.03
	
		if btnp(2) or btnp(3) or btnp(5) then
			if char_select_active_window == "chars" then
				char_select_active_window = "menu"
			else
				char_select_active_window = "chars"
			end
			sfx(1)
		end

		if char_select_active_window == "chars" then
			if btnp(0) then
				char_select_window_index = (char_select_window_index - 2) % #char_names + 1
				sfx(1)
				left_arrow_bump_timer = 2
			elseif btnp(1) then
				char_select_window_index = (char_select_window_index) % #char_names + 1
				sfx(1)
				right_arrow_bump_timer = 2
			end

		elseif char_select_active_window == "menu" then
			if btnp(0) then
				char_select_menu_index = (char_select_menu_index - 2) % #char_select_menu_items + 1
				sfx(1)
			elseif btnp(1) then
				char_select_menu_index = (char_select_menu_index) % #char_select_menu_items + 1
				sfx(1)
			end
		end
	
		if left_arrow_bump_timer > 0 then
			left_arrow_bump_timer -= 1
			left_arrow_bump_y = -1
		else
			left_arrow_bump_y = 0
		end

		if right_arrow_bump_timer > 0 then
			right_arrow_bump_timer -= 1
			right_arrow_bump_y = -1
		else
			right_arrow_bump_y = 0
		end

		if btnp(4) then
			sfx(2)
			if char_select_active_window == "chars" then
				char_desc_open = not char_desc_open -- toggle the window on/off
			elseif char_select_active_window == "menu" then
				if char_select_menu_index == 1 then
					state = "difficulty_menu"
				elseif char_select_menu_index == 2 then
					state = "menu"
				end
			end
		end

		if char_desc_open and btnp(5) then
		char_desc_open = false
		end
		
    -- difficulty select menu
	elseif state == "difficulty_menu" then
		if difficulty_index == 1 then
		diff_border = 11
		selected_char_hover_timer += 0.014
		elseif difficulty_index == 2 then
		diff_border = 9
		selected_char_hover_timer += 0.034
		elseif difficulty_index == 3 then
		diff_border = 8
		selected_char_hover_timer += 0.07
		elseif difficulty_index == 4 then
		diff_border = 2
		selected_char_hover_timer += 0.11
		end
		
		if btnp(2) then 
			difficulty_index = max(1, difficulty_index - 1)
			sfx(1)
		elseif btnp(3) then 
			difficulty_index = min(#difficulties, difficulty_index + 1)
			sfx(1)
		elseif btnp(4) then 
			sfx(2)
			if menu_index == 1 then
				selected_char = char_names[char_select_window_index]
				player_info = playerc[selected_char] 
				player_speed = player_info.speed 
				enemy_instances = {} 
				
				add(enemy_instances, {
                    type="anti_seraph",
                    x=42, y=48,
                    hp=enemies.anti_seraph.hp,
                    speed=enemies.anti_seraph.speed,
                    min_range=16,   
                    max_range=17,   
                    attack_cooldown = 60,
                    attack_damage = 1,
                    update=update_enemy
				})
				
				state = "game_test_state"
			elseif difficulty_index == 2 then
				--medium mode
			elseif difficulty_index == 3 then
				--hard mode
			elseif difficulty_index == 4 then
				--extreme mode
			end

		elseif btnp(5) then 
			sfx(2)
			state = "char_select"
		end
		
	elseif state == "game_test_state" then
		heart_hover_timer += 0.05
		ability_icon_hover_timer += 0.07	
		local new_x = player_x
		local new_y = player_y	
		local dx = 0
		local dy = 0

		if btn(0) then dx -= player_speed end
		if btn(1) then dx += player_speed end
		if btn(2) then dy -= player_speed end
		if btn(3) then dy += player_speed end
		
		if light_ability_bump_timer > 0 then light_ability_bump_timer -= 1 end
		if heavy_ability_bump_timer > 0 then heavy_ability_bump_timer -= 1 end
		if special_ability_bump_timer > 0 then special_ability_bump_timer -= 1 end
		
		if btnp(4) and not btn(5) then
			light_ability_bump_timer = 5
			sfx(3)
		elseif btnp(5) and not btn(4) then
			heavy_ability_bump_timer = 5
			sfx(4)
		elseif btnp(4) and btn(5) then
			special_ability_bump_timer = 5
			sfx(5)
		end
		
		move_player(dx, dy)	
		
		for e in all(enemy_instances) do
            e:update(e)
		end

		-- update enemy projectiles
    for p in all(enemy_projectiles) do
        p.x += p.dx * 2
        p.y += p.dy * 2
        p.life -= 1
        if p.life <= 0 then
            del(enemy_projectiles, p)
        end
    end
	end
end

function _draw()
	cls()

	if state == "splash" then
		draw_splash()
	elseif state == "menu" then
		draw_menu()
	elseif state == "char_select" then
		draw_char_select()
		if char_desc_open then
			draw_char_desc()
		end
	elseif state == "controls" then
		draw_controls_menu()
	elseif state == "secrets" then
		draw_secrets_menu()
	elseif state == "difficulty_menu" then
		draw_difficulty_menu()
	elseif state == "game_test_state" then
		draw_game_test_state()
		if player_dead then
			draw_death_screen()
        end
	elseif state == "new_cards" then
	elseif state == "load_lv_1" then
	elseif state == "lv_1" then
	elseif state == "load_lv_2" then
	elseif state == "lv_2" then
	elseif state == "load_lv_3" then
	elseif state == "lv_3" then
	elseif state == "death_screen" then
		draw_death_screen()	
	elseif state == "end_game" then	
	end
end