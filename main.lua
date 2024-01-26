-- main

function _init() init_game() end
function _update60() end



function init_game()
	init_pal()
	
	frames = 0
	state = "game"
	
	btns = {⬅️ = 0, ➡️ = 0, ⬆️ = 0, ⬇️ = 0, 🅾️ = 0, ❎ = 0}
	cam = {x = 0, y = 0, xto = 0, yto = 0}
	
	objects = {}
	particles = {}
	snow = {}
	
	player = create_obj_player()
	for i = 1, 3 do
		wolf = create_obj_wolf()
		wolf.x = 172 + i * 2
		wolf.y = 324 + i * 4
	end
	
	init_map()
	load_map(3, 5)
	
	-- debug
	hitboxes = -1
end



function _draw()
	cls()
	frames += 1
	
	btn_press()
	
	if state == "game" then
		-- update
		update_objects()
		update_particles()
		update_camera()
		
		-- draw
		map(0, 0, 0, 0, 48, 48, 0) -- main map tiles
		draw_everything()
		map(0, 0, 0, 0, 48, 48, 2) -- foreground tiles
		
		-- snow
		if (frames % 10 == 0) create_part_snow()
		draw_snow()
	end
end