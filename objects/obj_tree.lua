-- object : tree

function create_obj_tree()
	local t = {}
	
	-- variables
	t.entity = false
	t.x = 0
	t.y = 0
	
	
	
	-- functions
	t.update = function()
		
	end
	
	
	
	t.draw = function()
		sspr_outline(0, 96, 16, 24, t.x - 8, t.y - 21)
		sspr(0, 96, 16, 24, t.x - 8, t.y - 21)
	end
	
	
	
	t.draw_collision = function()
		
	end
	
	
	
	add(objects, t)
	return t
end