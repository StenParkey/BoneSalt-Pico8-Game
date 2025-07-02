-- splash, main menu, and controls screen

--splash startup screen
state = "splash"
splash_timer = 0
splash_duration = 2.5
splash_text = "dogsalt_ games"
splash_letters = 0
splash_letter_timer = 0
splash_letter_delay = 3

function draw_splash()
	spr(12, 48, 30, 4, 4) 
	local text_to_draw = sub(splash_text, 1, splash_letters)
	print(text_to_draw, 36, 60, 7)
end

-- main menu screen
menu_index = 1
menu_items = {"start game", " secrets", " controls"}
eye_timer = 0
eye_frame = 1
eye_direction = 1
left_eye_frames = {108, 104, 72, 76}
right_eye_frames = {110, 106, 74, 78}
logo_hover_timer = 0
skull_hover_timer = 0

function draw_menu()
	local logo_offset = hover_anim(logo_hover_timer, 1.5)
	local skull_offset = hover_anim(skull_hover_timer, 1.6)

	-- logo
	spr(64, 33, 6 + logo_offset, 8, 8)

	-- eyes
	spr(left_eye_frames[eye_frame], 48, 22 + logo_offset, 2, 2)
	spr(right_eye_frames[eye_frame], 64, 22 + logo_offset, 2, 2)
	
	-- crowskulls 
	spr(40, 85, 52 + skull_offset, 2, 2)
	spr(40, 27, 52 + skull_offset, 2, 2, true)

	-- title 
	for i=0,2 do
		spr(9+i, 48 + i*8, 71)
	end
	spr(27, 72, 71)

	-- underline 
	spr(25, 39, 79)
	for i=1,4 do
		spr(26, 39 + i*8, 79)
	end
	spr(25, 79, 79, 1, 1, true)

	for i=1,#menu_items do
		local y = 90 + (i-1) * 10
		local txt = menu_items[i]
		if i == menu_index then
			spr(42, 34, y)
			print(txt, 46, y, 6)
		else
			print(txt, 44, y, 5)
		end
	end
end

-- controls screen
ability_icon_hover_timer = 0

function draw_controls_menu()
	local x_offset, y_offset = circ_hover_anim(ability_icon_hover_timer, 1, 1)
	
	rect(15, 15, 115, 108)
	print("  ⬆️ ", 33, 22 )
	print("⬅️⬇️➡️: movement")
	
	spr(25, 25, 36)
	for i=1,8 do
		spr(26, 25 + i*8, 36)
	end
	spr(25, 97, 36, 1, 1, true)
	
	print("  🅾️: light ability", 20, 48)
	spr(6, 61 + x_offset, 56 + y_offset)
	print("  ❎: heavy ability", 20, 68)
	spr(38, 61 + x_offset, 76 + y_offset)
	print(" 🅾️+❎: special ability", 18, 88)
	spr(22, 61 + x_offset, 96 + y_offset)
end