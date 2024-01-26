-- 2d vector library
-- klehrik

function vec2(x, y)
	local v = {}
	
	v.x = x
	v.y = y
	
	v.get_dir = function() -- returns direction of the vector
		return atan2(v.x, v.y)
	end
	
	v.get_mag = function() -- returns magnitude of the vector
		return sqrt((v.x * v.x) + (v.y * v.y))
	end
	
	v.add = function(vec) -- adds another vector
		v.x += vec.x
		v.y += vec.y
	end
	
	v.normalize = function() -- normalizes the vector
		local m = v.get_mag()
		if m != 0 then
			v.x /= m
			v.y /= m
		end
	end
	
	v.set_dir = function(dir) -- sets the direction of the vector
		local m = v.get_mag()
		v.x = cos(dir) * m
		v.y = sin(dir) * m
	end
	
	v.set_mag = function(len) -- sets the magnitude of the vector
		local m = v.get_mag()
		if m != 0 then
			v.x /= m
			v.y /= m
		end
		v.x *= len
		v.y *= len
	end
	
	return v
end