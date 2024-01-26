-- scripts

function init_map()
	world = {}
	world.x = 3
	world.y = 5
	
	-- map data strings
	local a = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6b6969696969696969696969696cxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6a494a49494c4a4b49494d4b496axxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6axx50xxxxxx50xx6axxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6axx60xxxxxx60xx6axxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6axx70xxxxxx70xx6axxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6axxxxxxxxxxxx6axxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6axx50xxxxxx50xx6axxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6axx60xxx42xx60xx6axxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6axx70xxxxxx70xx6axxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6axxxxx43xxxxxx6axxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6axx50xxx44xx50xx6axxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6axx60xx54xxx60xx6axxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6axx70xx4243xx70xx6axxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6axxxxxx44xxxxx6axxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx4e6969696cx4254x6b6969695exxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx7b6969697cx4342x7b6969697cxxxc2xxc2xxxxx46xxxxxxxxxxxxxxxxxxxxx5d4b494d6dxx44x5d49494c6dxxc2xc2c2xc2xc2c2c27764646464xxxxxxxxxxxxxxxxxc2xxxxx4243xxxxxxc2c2xxxc2xxc2c2xxxxxxxxxxxxxxxxxxxxxxxc2xxx50xx44xxx50xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxc2xx60xxx54xx60xxxxxx41x41x41xxxxxxxxxxxxxxxxxxxxxxxxxc2xxx70xxxxxx70xxxxx41x41x41xxxxxxxxxxxxxxxxxxxxxxxxxxc2xxxxxx43xxxxxxxxxxxxxxxxxxx4762626262xxxxxxxxxxxxxxxx48x41xxxxxxxxxx41xxxxxxx41x41x41x5772727272xxxxxxxxxxxxxxxx58xx41xxxxxxxx41xxxxxxx41x41x41xx67xxxxxxxxxxxxxxxxxxxx5548xxxxxxxxxxxxxxxxxxxxxxxxx46xxxxxxxxxxxxxxxxxxxx6558xxxxxxxxxxxxxxxxxx4762626262626256xxxxxxxxxxxxxxxxxxxxx556248xxxxxxxx47626262626262627472727272727266xxxxxxxxxxxxxxxxxxxxx6572756262626262626262747272727272727273xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx65727272727272727266xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	-- can fit an estimated 15 to 20 map data strings
	
	world.map = {
		{0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0},
		{0, 0, a, 0, 0}
	}
end

function load_map(x, y)
	local data = world.map[y][x]
	
	-- parse data
	local _x = 0
	local _y = 0
	local i = 1
	while i < #data do
		if sub(data, i, i) != "x" then
			local tile = tonum("0x"..sub(data, i, i+1))
			mset(_x, _y, tile)
			i += 2
		else
			mset(_x, _y, 0)
			i += 1
		end
		
		_x += 1
		if _x > 47 then
			_x = 0
			_y += 1
		end
	end
	
	-- create tree objects
	for _y = 0, 47 do
		for _x = 0, 47 do
			if mget(_x, _y) == 194 then -- "T" tile
				mset(_x, _y, 64)
				local tree = create_obj_tree()
				tree.x = _x * 8 + 4
				tree.y = _y * 8 + 5
			end
		end
	end
end


function update_camera()
	-- slide camera
	local spd = 10
	cam.xto = (player.x \ 128) * 128
	cam.yto = (player.y \ 128) * 128
	if abs(cam.xto - cam.x) < 1 then cam.x = cam.xto
	else cam.x += (cam.xto - cam.x) / spd
	end
	if abs(cam.yto - cam.y) < 1 then cam.y = cam.yto
	else cam.y += (cam.yto - cam.y) / spd
	end
	
	-- clamp and draw
	cam.x = mid(cam.x, 0, 256)
	cam.y = mid(cam.y, 0, 256)
	camera(cam.x, cam.y)
end


function update_objects()
	for o in all(objects) do
		o.update()
	end
end

function update_particles()
	for p in all(particles) do
		p.update()
	end
end

function tile_collision(obj)
	if tileflag(obj.x + obj.left + obj.vec.x - 1, obj.y + obj.top)
	or tileflag(obj.x + obj.left + obj.vec.x - 1, obj.y) then
		obj.x += 0.5
		obj.vec.x = 0
	elseif tileflag(obj.x + obj.right + obj.vec.x, obj.y + obj.top)
	or tileflag(obj.x + obj.right + obj.vec.x, obj.y) then
		obj.x -= 0.5
		obj.vec.x = 0
	end
	
	if tileflag(obj.x + obj.left, obj.y + obj.top + obj.vec.y)
	or tileflag(obj.x + obj.right, obj.y + obj.top + obj.vec.y) then
		obj.y += 0.5
		obj.vec.y = 0
	elseif tileflag(obj.x + obj.left, obj.y + obj.vec.y)
	or tileflag(obj.x + obj.right, obj.y + obj.vec.y) then
		obj.y -= 0.5
		obj.vec.y = 0
	end
end


function draw_everything()
	-- sort
	z = {} -- z-index table
	for obj in all(objects) do
		if obj.x >= cam.x - 32 and obj.x <= cam.x + 160 and
		obj.y >= cam.y - 32 and obj.y <= cam.y + 160 then
			local y = flr(obj.y)
			z[y] = z[y] or {} -- create table if it does not exist
			add(z[y], obj)
		end
	end
	for part in all(particles) do
		local y = flr(part.y)
		z[y] = z[y] or {} -- create table if it does not exist
		add(z[y], part)
	end
	
	-- draw
	for y = flr(cam.y) - 32, flr(cam.y) + 160 do
		for i in all(z[y]) do
			i.draw()
		end
	end
	
	
	
	-- debug: draw collision boxes
	menuitem(1, "hitboxes: "..hitboxes,
	function() hitboxes *= -1 end)
	
	if hitboxes >= 1 then
		for obj in all(objects) do
			obj.draw_collision()
		end
	end
end

function draw_snow()
	for s in all(snow) do
		s.update()
		s.draw()
	end
end


function init_pal()
	pal()
	--pal(13, 134, 1)
	palt(0, false)
	palt(14, true)
end

function set_pal(col)
	for i = 0, 15 do pal(i, col) end
end