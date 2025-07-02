-- assets, anims, draws
heart_drain_frames = {16, 17, 32, 33, 48, 49}
death_anim_frames = { 192, 193, 194, 195, 196, 197}

-- mana bar frames
mana_bar_svar = 18   
mana_cap_empty = 19
mana_tube_empty = 20
mana_charge_expended = 21
mana_filled_svar = 34
mana_cap_filled = 35
mana_tube_filled = 36
mana_cap_f_filled = 37

-- updown hover animation
function hover_anim(t, amp)
	return sin(t) * (amp or 1.5)
end

-- circular hover animation
function circ_hover_anim(t, radius, speed)
	local angle = t * (speed or 1)
	local x = cos(angle) * (radius or 1.5)
	local y = sin(angle) * (radius or 1.5)
	return x, y
end

-- health bar
function draw_health(x, y, max_hp, t)
	for i = 1, max_hp do
		local offset = hover_anim(t + i * 0.3, 0.4)
		spr(heart_drain_frames[1], x + (i - 1) * 8, y + offset)
	end
end

-- mana bar
function draw_mana_bar(x, y, max_mp, current_mp, is_svar)
	if is_svar and max_mp == 1 then
		-- svar has a special single mana bar sprite
		spr(mana_bar_svar, x, y)
		if current_mp > 0 then
			spr(mana_filled_svar, x, y)
		end
		return
	end

		-- empty mana bar
	spr(mana_cap_empty, x, y) 
	for i = 1, max_mp - 2 do
		spr(mana_tube_empty, x + i * 8, y)
	end
	spr(mana_cap_empty, x + (max_mp - 1) * 8, y, 1, 1, true) 
		-- filled mp bars on top
	if current_mp >= 1 then
		spr(mana_cap_filled, x, y)
	end
	for i = 1, current_mp - 2 do
		spr(mana_tube_filled, x + i * 8, y)
	end
	if current_mp == max_mp then
		spr(mana_cap_f_filled, x + (max_mp - 1) * 8, y)
	end
end

function draw_wrapped_text(text, x, y, max_width, color)
	local lines = {}
	
	-- split into paragraphs by \n
	for paragraph in all(split(text, "\n")) do
		local line = ""
		for word in all(split(paragraph, " ")) do
			local test_line = line == "" and word or line.." "..word
			if #test_line * 4 > max_width then
				add(lines, line)
				line = word
			else
				line = test_line
			end
		end
		if line != "" then
			add(lines, line)
		end
		-- add an empty line between paragraphs
		add(lines, "")
	end

	for i, line in ipairs(lines) do
		local line_width = #line * 4
		local cx = x + (max_width - line_width) / 2
		print(line, cx, y + (i - 1) * 6, color)
	end
end

-- player characters 
playerc = {
	feld = {
        sp=1, hp=3, mp=3, speed=2, 
        l_a="smoke slash", 
        h_a="smoulder bomb", 
        s_a="ravage", 
        char_desc="slice, burn, and decieve with the power of smoke and cinders.\ncull your enemies with speed and efficiency."
    },
	krug = {
        sp=2, hp=2, mp=5, speed=2.3, 
        l_a="caustic blast", 
        h_a="fetid howl", 
        s_a="overflow", 
        char_desc="howl and wither your enemies with the power of acid and decay.\noverwhelm them with your boundless energy."
    },
	vond = {
        sp=3, hp=1, mp=6, speed=3.1, 
        l_a="spectre shot", 
        h_a="displace self", 
        s_a="void walk", 
        char_desc="snipe, blink, and disengage from the battlefield with the power of the void.\nwalk safely through the abyss."
    },	
	dirk =	{
        sp=4, hp=5, mp=2, speed=1.5, 
        l_a="shard stomp", 
        h_a="petrified skin", 
        s_a="tremors", 
        char_desc="crush your enemies and fortify yourself with the power of stone and earth.\nrupture the ground beneath you."
    },	
	svar = {
        sp=5, hp=6, mp=1, speed=1.3, 
        l_a="devour", 
        h_a="frighten", 
        s_a="soul spew", 
        char_desc="consume and terrify your enemies with the power of the undeath.\nrelease stomached souls and wreak havoc."
    }
}

-- player init vars
player_speed = 1
light_ability_bump_timer = 0
heavy_ability_bump_timer = 0
special_ability_bump_timer = 0

-- test enemy attack stuff
enemy_projectiles = {}

-- enemies and bosses
enemies = {
	anti_seraph = {sp=136, hp=2, speed=2},
	radiant_sconces = {sp=152, hp=1, speed=3.1},
	corrupted_villager = {sp=0, hp=4, speed=3.2}
}

bosses = {
	grinning_mouth = {sp=0 ,hp=3, speed=1.4},
	village_shaman = {sp=0, hp=40, speed=2},
	eldritch_abomination = {sp=0, hp=80, speed=1}
}

--enemy logic
function update_enemy(e)
    local px, py = player_x, player_y
    local ex, ey = e.x, e.y

    -- check line of sight
    if not los(ex, ey, px, py) then return end

    local dist = manhattan(ex, ey, px, py)
    local minr = e.min_range or e.target_range or 3
    local maxr = e.max_range or e.target_range or 5

    -- unique attack for anti_seraph
    if e.type == "anti_seraph" then
        e.attack_timer = (e.attack_timer or 0) + 1
        local attack_cooldown = e.attack_cooldown or 60
        if dist <= maxr and e.attack_timer >= attack_cooldown then
            add(enemy_projectiles, {
                x = ex + 4, y = ey + 4,
                dx = sgn(px - ex), dy = sgn(py - ey),
                sp = 96, -- golden laser sprite
                life = 32,
                damage = e.attack_damage or 1
            })
            e.attack_timer = 0
        end
    end

    if dist < minr then
        try_step_away(e, px, py)
    elseif dist > maxr then
        try_step_toward(e, px, py)
    else
        -- in comfort zone: maybe strafe or idle
    end
end

function manhattan(x1, y1, x2, y2)
    return abs(x1 - x2) + abs(y1 - y2)
end

function try_step_toward(e, tx, ty)
    local dx = sgn(tx - e.x)
    local dy = sgn(ty - e.y)
    -- try diagonal first
    if not is_blocked(e.x + dx, e.y + dy) then
        try_move(e, e.x + dx, e.y + dy)
    -- then try horizontal
    elseif not is_blocked(e.x + dx, e.y) then
        try_move(e, e.x + dx, e.y)
    -- then try vertical
    elseif not is_blocked(e.x, e.y + dy) then
        try_move(e, e.x, e.y + dy)
    end
end

function try_step_away(e, tx, ty)
    local dx = -sgn(tx - e.x)
    local dy = -sgn(ty - e.y)
    if not is_blocked(e.x + dx, e.y + dy) then
        try_move(e, e.x + dx, e.y + dy)
    elseif not is_blocked(e.x + dx, e.y) then
        try_move(e, e.x + dx, e.y)
    elseif not is_blocked(e.x, e.y + dy) then
        try_move(e, e.x, e.y + dy)
    end
end

function sgn(n)
    return n > 0 and 1 or n < 0 and -1 or 0
end

function try_move(e, nx, ny)
    if not is_blocked(nx, ny) then
        e.x = nx
        e.y = ny
    end
end

function best_step_toward(x1, y1, x2, y2)
    local choices = {
        {0,-1}, {0,1}, {-1,0}, {1,0}
    }
    local best_dx, best_dy = 0, 0
    local best_dist = 999
    for c in all(choices) do
        local nx, ny = x1 + c[1], y1 + c[2]
        if not is_blocked(nx, ny) then
            local d = manhattan(nx, ny, x2, y2)
            if d < best_dist then
                best_dist = d
                best_dx, best_dy = c[1], c[2]
            end
        end
    end
    return best_dx, best_dy
end

function los(x1, y1, x2, y2)
    return true -- for now, always visible
end
