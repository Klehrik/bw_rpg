-- object : player

function create_obj_player()
	local p = {}
	
	-- variables
	p.entity = true
	p.x = 64
	p.y = 224
	p.vec = vec2(0, 0) -- movement vector
	p.sprite = 1
	p.flip = false
	p.dir = 0
	
	-- stats
	p.hp = 5
	p.max_hp = 5
	p.kb_mod = 1 -- multiplier for how much knockback is taken
	p.inv = 0    -- invincibility frames
	p.max_inv = 60
	
	p.damage = 1
	
	-- collision box
	p.left = -3
	p.right = 3
	p.top = -4
	p.sword_box = {
		{0, -8, 14, 1},   -- right
		{-5, -18, 5, -4}, -- up
		{-14, -8, 0, 1},  -- left
		{-5, -4, 5, 10},  -- down
	}
	
	-- states
	p.state = "none"
	p.dash_dir = 0
	p.dash_timer = 0
	p.dash_cooldown = 50
	p.dash_max_cooldown = 50
	p.attack_dir = 0
	p.attack_frame = 0
	
	
	
	-- functions
	p.update = function()
		local acc = 0.1
		local max_spd = 0.65 -- not 100% accurate since speed "capping" is a curve
		local dash_spd = max_spd * 7
		local dash_timer = 20 -- time for second button press
		local attack_frames = 20 -- length of attack animation
		
		
		-- invincibility frames
		if (p.inv > 0) p.inv -= 1
		
		
		if p.state == "none" then
			-- movement
			if btn(⬅️) then p.vec.add(vec2(-acc, 0)) p.dir = 2 end
			if btn(➡️) then p.vec.add(vec2(acc, 0)) p.dir = 0 end
			if btn(⬆️) then p.vec.add(vec2(0, -acc)) p.dir = 1 end
			if btn(⬇️) then p.vec.add(vec2(0, acc)) p.dir = 3 end
			
			-- dash
			if (p.dash_timer > 0) p.dash_timer -= 1
			if p.dash_cooldown >= p.dash_max_cooldown then
				-- check direction of button press
				local dir = -1
				if (btns.⬅️ == 1) dir = 2 -- left
				if (btns.➡️ == 1) dir = 0 -- right
				if (btns.⬆️ == 1) dir = 1 -- up
				if (btns.⬇️ == 1) dir = 3 -- down
				
				if dir >= 0 then
					-- check if the it is as the previous direction input
					-- if so, apply dash speed in that direction
					if p.dash_timer > 0 and p.dash_dir == dir then
						if (dir == 2) p.vec.add(vec2(-dash_spd, 0)) -- left
						if (dir == 0) p.vec.add(vec2(dash_spd, 0)) -- right
						if (dir == 1) p.vec.add(vec2(0, -dash_spd)) -- up
						if (dir == 3) p.vec.add(vec2(0, dash_spd)) -- down
						p.dash_cooldown = 0
						
					else
						p.dash_timer = dash_timer
						p.dash_dir = dir
					end
				end
			end
			
			-- decelerate
			local mag = p.vec.get_mag()
			if not (btn(⬅️) or btn(➡️) or btn(⬆️) or btn(⬇️))
			and mag > 0 then p.vec.set_mag(mag - (acc / 2)) end
			
			-- attack
			if btn(🅾️) then
				p.state = "attack"
				p.dash_timer = 0
				p.attack_frame = 0
				
				-- apply slight forward force
				local spd = max_spd * 0.7
				if (p.dir == 2) p.vec.add(vec2(-spd, 0)) -- left
				if (p.dir == 0) p.vec.add(vec2(spd, 0)) -- right
				if (p.dir == 1) p.vec.add(vec2(0, -spd)) -- up
				if (p.dir == 3) p.vec.add(vec2(0, spd)) -- down
			end
			
		
		elseif p.state == "attack" then
			-- increment attack frame
			if p.attack_frame < attack_frames then
				p.attack_frame += 1
				
				-- deal damage on frames 5-12 of attack
				if p.attack_frame >= 5 and p.attack_frame <= 12 then
					-- get sword collision box
					local box = p.sword_box[p.dir + 1]
					
					-- loop through all objects
					for obj in all(objects) do
					
						-- check if the object is a moving entity
						-- if so, check for collision
						if obj != p and obj.entity == true then
							if box_collide(p.x + box[1], p.y + box[2], p.x + box[3], p.y + box[4],
							obj.x + obj.left, obj.y + obj.top, obj.x + obj.right, obj.y) then
							
								if obj.inv <= 0 then
									-- deal damage
									-- damage is doubled if attacking during a dash
									if p.vec.get_mag() > max_spd then obj.hp -= p.damage * 2
									else obj.hp -= p.damage
									end
									
									-- knockback
									local spd = (p.vec.get_mag() * 6) * obj.kb_mod
									if (p.dir == 2) obj.vec.add(vec2(-spd, 0)) -- kb left
									if (p.dir == 0) obj.vec.add(vec2(spd, 0))  -- kb right
									if (p.dir == 1) obj.vec.add(vec2(0, -spd)) -- kb up
									if (p.dir == 3) obj.vec.add(vec2(0, spd))  -- kb down
								
									obj.inv = obj.max_inv
								end
							end
						end
						
					end
				end
				
			else p.state = "none"
			end
			
			-- decelerate
			p.vec.set_mag(p.vec.get_mag() - (acc / 2))
			
		end
		
		
		-- dash cooldown
		if (p.dash_cooldown < p.dash_max_cooldown) p.dash_cooldown += 1
		
		-- cap movement speed
		local mag = p.vec.get_mag()
		if mag > max_spd then p.vec.set_mag(mag * 0.8) end
			
		-- collision
		tile_collision(p)
		
		-- fix rounding errors
		if (abs(p.vec.x) < 0.05) p.vec.x = 0
		if (abs(p.vec.y) < 0.05) p.vec.y = 0
		
		-- apply forces
		p.x += p.vec.x
		p.y += p.vec.y
	end
	
	
	
	p.draw = function()
		local max_spd = 0.65 -- not 100% accurate since speed "capping" is a curve
		
		
		if p.state == "none" then
			-- reset attack sprite to standing sprite
			if p.sprite >= 7 then
				if (p.dir == 2) p.sprite = 1 p.flip = true -- left
				if (p.dir == 0) p.sprite = 1 -- right
				if (p.dir == 1) p.sprite = 5 -- up
				if (p.dir == 3) p.sprite = 3 -- down
			end
			
			-- animate
			local spd = 8 -- change sprite every X frames
			if btn(⬅️) then p.sprite = animate(p.sprite, 1, 2, spd) p.flip = true
			elseif btn(➡️) then p.sprite = animate(p.sprite, 1, 2, spd) p.flip = false
			elseif btn(⬆️) then p.sprite = animate(p.sprite, 5, 6, spd) p.flip = false
			elseif btn(⬇️) then p.sprite = animate(p.sprite, 3, 4, spd) p.flip = false
			
			-- reset to standing sprite when not moving
			elseif p.sprite % 2 == 0 then p.sprite -= 1
			end
			
			-- draw self
			p.draw_self()
			
		
		elseif p.state == "attack" then
			-- switch to attack sprite
			p.sprite = 7 + p.dir
			p.flip = false
			
			-- draw self and sword sword
			if (p.dir < 3) p.draw_sword()
			p.draw_self()
			if (p.dir >= 3) p.draw_sword()
			
		end
		
		
		-- create dash particles
		if p.vec.get_mag() > max_spd then
			local part = create_part_dash()
			part.x = p.x
			part.y = p.y - 4
			part.dir = p.vec.get_dir() - 0.6 + rnd(0.2)
			part.col = 12
		end
		
		-- debug
		-- print(stat(1), cam.x + 1, cam.y + 2, 0)
		-- print(stat(1), cam.x + 1, cam.y + 1, 12)
		-- print(p.vec.y, 1, 7, 7)
		-- print(p.vec.get_mag(), 1, 13, 7)
	end
	
	
	
	p.draw_self = function()
		-- draw self
		if p.inv % 4 == 0 then
			spr_outline(p.sprite, p.x - 4, p.y - 8 - (1 - p.sprite % 2), p.flip)
			spr(p.sprite, p.x - 4, p.y - 8 - (1 - p.sprite % 2), 1, 1, p.flip)
		end
		
		-- draw hp pips
		for i = 1, p.hp do
			pset(p.x - p.max_hp - 1 + (i * 2), p.y + 2, 12)
		end
		
		-- draw dash meter
		local len = p.max_hp
		local col = 13
		if (p.dash_cooldown >= p.dash_max_cooldown) col = 7
		line(p.x - len + 1, p.y + 4, p.x - len - 1 + (p.dash_cooldown / p.dash_max_cooldown * len * 2), p.y + 4, col)
	end
	
	p.draw_sword = function()
		-- sword position
		local f = p.attack_frame
		if f < 16 then
			-- * each pair of numbers (separated by a space) are the x and y offsets for that frame
			local frame_data = {
				"-01-04 -01-04 +02-05 +02-05 +04-05 +04-05 +04-05 +04-05 +04-05 +04-05 +04-05 +04-05 +02-05 +02-05 -01-04 -01-04", -- right
				"-03-11 -03-11 -03-13 -03-13 -03-15 -03-15 -03-15 -03-15 -03-15 -03-15 -03-15 -03-15 -03-13 -03-13 -03-11 -03-11", -- up
				"-07-04 -07-04 -10-05 -10-05 -12-05 -12-05 -12-05 -12-05 -12-05 -12-05 -12-05 -12-05 -10-05 -10-05 -07-04 -07-04", -- left
				"+00-03 +00-03 +00-01 +00-01 +00+01 +00+01 +00+01 +00+01 +00+01 +00+01 +00+01 +00+01 +00-01 +00-01 +00-03 +00-03"  -- down
			}
			local spr_data = {
				{11, false, false}, -- right
				{12, false, true},  -- up
				{11, true, false},  -- left
				{12, false, false}  -- down
			}
			local offx = tonum(sub(frame_data[p.dir + 1], f * 7 + 1, f * 7 + 3))
			local offy = tonum(sub(frame_data[p.dir + 1], f * 7 + 4, f * 7 + 6))
			local sd = spr_data[p.dir + 1] -- sprite number and flipping information
			
			spr_outline(sd[1], p.x + offx, p.y + offy, sd[2], sd[3])
			spr(sd[1], p.x + offx, p.y + offy, 1, 1, sd[2], sd[3])
		end
	end
	
	p.draw_collision = function()
		rect(p.x + p.left, p.y + p.top, p.x + p.right, p.y, 10)
		
		if p.state == "attack" and p.attack_frame >= 5 and p.attack_frame <= 12 then
			local box = p.sword_box[p.dir + 1]
			rect(p.x + box[1], p.y + box[2], p.x + box[3], p.y + box[4], 9)
		end
	end
	
	
	
	add(objects, p)
	return p
end