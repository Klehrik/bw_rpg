-- helper

function btn_press()
	-- btnp without the auto re-pressing
	-- just check if button in table equals 1
	if btn(⬅️) then btns.⬅️ += 1
	else btns.⬅️ = 0 end
	if btn(➡️) then btns.➡️ += 1
	else btns.➡️ = 0 end
	if btn(⬆️) then btns.⬆️ += 1
	else btns.⬆️ = 0 end
	if btn(⬇️) then btns.⬇️ += 1
	else btns.⬇️ = 0 end
	if btn(🅾️) then btns.🅾️ += 1
	else btns.🅾️ = 0 end
	if btn(❎) then btns.❎ += 1
	else btns.❎ = 0 end
end


function animate(sp, mn, mx, spd)
	sp = mid(sp, mn, mx)
	if frames % spd == 0 then
		sp += 1
		if (sp > mx) sp = mn
	end
	return sp
end


function tileflag(x, y, flag)
	flag = flag or 0
	return fget(mget(x \ 8, y \ 8), flag)
end


function dist(x1, y1, x2, y2)
	return sqrt(((x2 - x1) / 32) ^ 2 + ((y2 - y1) / 32) ^ 2) * 32
end


function box_collide(l1, t1, r1, b1, l2, t2, r2, b2)
	if l1 > r2 or l2 > r1 or t1 > b2 or t2 > b1 then return false
	else return true
	end
end


-- note: spr_outline and sspr_outline are really CPU intensive
-- possibly trim the bottoms?
function spr_outline(sp, x, y, flip_x, flip_y)
	set_pal(0)
	local _x = "-1+0+1-1+1-1+0+1"
	local _y = "-1-1-1+0+0+1+1+1"
	for i = 1, #_x, 2 do
		spr(sp, x + tonum(sub(_x, i, i+1)), y + tonum(sub(_y, i, i+1)), 1, 1, flip_x, flip_y)
	end
	init_pal()
end

function sspr_outline(sp_x, sp_y, w, h, x, y)
	set_pal(0)
	local _x = "-1+0+1-1+1-1+0+1"
	local _y = "-1-1-1+0+0+1+1+1"
	for i = 1, #_x, 2 do
		sspr(sp_x, sp_y, w, h, x + tonum(sub(_x, i, i+1)), y + tonum(sub(_y, i, i+1)))
	end
	init_pal()
end