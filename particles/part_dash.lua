-- particle : dash

function create_part_dash()
	local p = {}
		
	-- variables
	p.x = 0
	p.y = 0
	p.dir = 0
	p.spd = rnd(1) / 4 + 0.25
	p.col = 7
	
	
	
	-- functions
	p.update = function()
		p.x += cos(p.dir) * p.spd
		p.y += sin(p.dir) * p.spd
		p.spd *= 0.97
		if (p.spd < 0.05) p.destroy()
	end
	
	
	
	p.draw = function()
		local size = p.spd * 8
		circfill(p.x, p.y, size, p.col)
	end
	
	
	
	p.destroy = function()
		del(particles, p)
	end
	
	
	
	add(particles, p)
	return p
end