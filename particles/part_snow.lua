-- particle : snow

function create_part_snow()
	local p = {}
		
	-- variables
	p.x = cam.x + 132
	p.y = cam.y - 80 + rnd(208)
	p.xsp = -rnd(2) - 0.2
	p.ysp = rnd(0.5) + 0.5
	p.size = 1
	if (p.xsp < -1.2) p.size = 2
	
	
	
	-- functions
	p.update = function()
		p.x += p.xsp
		p.y += p.ysp
		
		if (p.x < cam.x or p.y > cam.y + 127) p.destroy()
	end
	
	
	
	p.draw = function()
		rectfill(p.x, p.y, p.x + p.size - 1, p.y + p.size - 1, 7)
	end
	
	
	
	p.destroy = function()
		del(snow, p)
	end
	
	
	
	add(snow, p)
	return p
end