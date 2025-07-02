-- character, difficulty, and death menus

--character select menu
char_select_active_window = "chars"
char_select_window_index = 1
char_select_menu_index = 1
char_select_menu_items = {"select", "back"}
char_names = {"feld", "krug", "vond", "dirk", "svar"}
player_stats = playerc[current_char]
char_hover_timer = 0
hp_hover_timer = 0
left_arrow_bump_timer = 0
right_arrow_bump_timer = 0
left_arrow_bump_y = 0
right_arrow_bump_y = 0
heart_hover_timer = 0
char_desc_open = false

function draw_char_select()

	local current_char = char_names[char_select_window_index]
	local x_offset, y_offset = circ_hover_anim(char_hover_timer, 1.5, 1)
	player_info = playerc[current_char]
	
	if char_select_active_window == "chars" then
		spr(55, 14, 26 + left_arrow_bump_y) -- left arrow
		spr(55, 105, 26 + right_arrow_bump_y, 1, 1, true, true) -- right arrow
	end
		-- character preview box
	rect(19, 45, 107, 98, 7)
	print("select your spirit:", 26, 8, 3)
	print(current_char, 56, 19, 60)
	spr(player_info.sp, 60 + x_offset, 30 + y_offset)
	print("hp: ", 28, 51)
	draw_health(40, 50, player_info.hp, heart_hover_timer)
	print("mp: ", 28, 62)
	draw_mana_bar(41, 60, player_info.mp, player_info.mp, current_char == "svar")
	print("l-a:", 24, 72, 2)
	print(player_info.l_a, 44, 72, 6)
	print("h-a:", 24, 80, 8)
	print(player_info.h_a, 44, 80, 6)
	print("s-a:", 24, 88, 3)
	print(player_info.s_a, 44, 88, 6)
		
	for i=1,#char_select_menu_items do
		local x = 32 + (i-1) * 44
		local txt = char_select_menu_items[i]

		if char_select_active_window == "menu" and i == char_select_menu_index then
			spr(42, x-13, 106)
			print(txt, x+2, 107, 6)
		else
			print(txt, x, 107, 5)
		end
	end
end

-- window for character description, swaps with character preview box
function draw_char_desc()
	local current_char = char_names[char_select_window_index]
	local info = playerc[current_char]

	rect(19, 45, 107, 99, 5)
	rectfill(20, 46, 106, 98, 0)

	draw_wrapped_text(info.char_desc, 22, 49, 82, 6)
end


-- difficulty select menu
difficulty_index = 1
difficulties = {" easy", "medium", " hard", "extreme"}
selected_char_hover_timer = 0

function draw_difficulty_menu()
	local x_offset, y_offset = circ_hover_anim(selected_char_hover_timer, 1.5, 1)
	
	rect(15, 15, 115, 108, diff_border)
	print("select difficulty:", 30, 23, 6)
	
	spr(25, 29, 30)
	for i=1,7 do
		spr(26, 29 + i*8, 30)
	end
	spr(25, 93, 30, 1, 1, true)

	spr(player_info.sp, 62 + x_offset, 45 + y_offset)
	
	
	for i=1,#difficulties do
		local y = 64 + (i-1) * 10
		local txt = difficulties[i]
		if i == difficulty_index then
			spr(42, 42, y)
			print(txt, 54, y, diff_border)
		else
			print(txt, 52, y, 5)
		end
	end
end

--death screen
player_dead = false

function draw_death_screen()
end 