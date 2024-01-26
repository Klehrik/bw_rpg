-- object : wolf

function create_obj_wolf()
	local w = {}
	
	-- variables
	w.entity = true
	w.x = 0
	w.y = 0
	w.vec = vec2(0, 0) -- movement vector
	w.sprite = 17
	w.flip = false
	
	-- stats
	w.hp = 3
	w.max_hp = 3
	w.kb_mod = 1 -- multiplier for how much knockback is taken
	w.inv = 0    -- invincibility frames
	w.max_inv = 20
	
	w.damage = 1
	
	-- collision box
	w.left = -3
	w.right = 3
	w.top = -5
	
	-- states
	w.state = "none"
	w.lunge_dir = 0
	w.lunge_timer = 0
	w.lunge_cooldown = 0
	w.lunge_damage_time = 0
	w.random_move = 0
	
	
	
	-- functions
	w.update = function()
		local acc = 0.1
		local max_spd = 0.5 -- not 100% accurate since speed "capping" is a curve
		local lunge_spd = max_spd * 20
		local lunge_timer = 50
		local lunge_cooldown = 120
		local lunge_cooldown_random = 60
		local lunge_damage_time = 15
		
		
		-- death
		if w.hp <= 0 then
			for i = 1, 20 do
				local part = create_part_dash()
				part.x = w.x
				part.y = w.y - 4
				part.dir = rnd(1)
				part.col = 8
			end
			del(objects, w)
		end
		
		-- invincibility frames
		if (w.inv > 0) w.inv -= 1
		
		-- random move dir modifier
		if frames % 60 == 0 then
			w.random_move = (rnd(1) / 1.5) - 0.33 -- -0.33 to 0.33
		end
		
		
		if w.state == "none" then
			local dist = dist(w.x, w.y, player.x, player.y)
			local dir = atan2(player.x - w.x, player.y - w.y)
			
			-- move towards player
			-- 30 frame delay after lunging
			-- also keep distance if too close
			if w.lunge_cooldown <= 90 then
				if dist > 40 then
					local move_vec = vec2(acc, 0)
					move_vec.set_dir(dir + w.random_move / 2)
					w.vec.add(move_vec)
					
				elseif dist < 28 then
					local move_vec = vec2(acc, 0)
					move_vec.set_dir(dir - 0.5 + w.random_move)
					w.vec.add(move_vec)
				end
				
			else
				-- decelerate
				w.vec.set_mag(w.vec.get_mag() - (acc / 2))
			end
			
			
			-- lunge
			if (w.lunge_cooldown > 0) w.lunge_cooldown -= 1
			if w.lunge_cooldown <= 0 and dist <= 40 then
				w.state = "lunge"
				w.lunge_dir = dir
				w.lunge_timer = lunge_timer
			end
			
			
		elseif w.state == "lunge" then
			-- decelerate
			w.vec.set_mag(w.vec.get_mag() - (acc / 2))
			
			-- lunge
			if w.lunge_timer > 0 then w.lunge_timer -= 1
			else
				w.state = "none"
				w.lunge_cooldown = lunge_cooldown + flr(rnd(lunge_cooldown_random))
				w.lunge_damage_time = lunge_damage_time
				
				local move_vec = vec2(lunge_spd, 0)
				move_vec.set_dir(w.lunge_dir)
				w.vec.add(move_vec)
			end
			
		end
		
		
		-- cap movement speed
		local mag = w.vec.get_mag()
		if mag > max_spd then w.vec.set_mag(mag * 0.8) end
			
		-- collision
		tile_collision(w)
		
		-- fix rounding errors
		if (abs(w.vec.x) < 0.05) w.vec.x = 0
		if (abs(w.vec.y) < 0.05) w.vec.y = 0
		
		-- apply forces
		w.x += w.vec.x
		w.y += w.vec.y
		
		
		-- deal damage during lunge
		if w.lunge_damage_time > 0 then
			w.lunge_damage_time -= 1
			
			if box_collide(w.x + w.left, w.y + w.top, w.x + w.right, w.y,
			player.x + player.left, player.y + player.top, player.x + player.right, player.y) then
				
				if player.inv <= 0 then
					player.hp -= w.damage
					player.inv = player.max_inv
				end
				
			end
		end
	end
	
	
	
	w.draw = function()
		local max_spd = 0.5 -- not 100% accurate since speed "capping" is a curve
		
		
		-- animate
		local spd = 6 -- change sprite every X frames
		w.sprite = animate(w.sprite, 17, 20, spd)
		if w.state == "lunge" or w.lunge_cooldown > 90 then
			w.sprite = 17
		end
		
		
		if player.x < w.x then w.flip = true
		else w.flip = false
		end
		
		
		-- draw self
		if w.inv % 4 == 0 then
			spr_outline(w.sprite, w.x - 4, w.y - 8, w.flip)
			spr(w.sprite, w.x - 4, w.y - 8, 1, 1, w.flip)
		end
		
		-- draw hp pips
		for i = 1, w.hp do
			pset(w.x - w.max_hp - 1 + (i * 2), w.y + 2, 8)
		end
		
		
		-- create dash particles
		if w.vec.get_mag() > max_spd then
			local part = create_part_dash()
			part.x = w.x
			part.y = w.y - 4
			part.dir = w.vec.get_dir() - 0.6 + rnd(0.2)
			part.col = 8
		end
	end
	
	
	
	w.draw_collision = function()
		rect(w.x + w.left, w.y + w.top, w.x + w.right, w.y, 10)
	end
	
	
	
	add(objects, w)
	return w
end