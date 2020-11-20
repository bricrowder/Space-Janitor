function love.load()
	-- "Space Janitor"
	-- Detailed variable and logic documentation in variable descriptions.xlsx

	-- Audio Data
	sources = {}

	-- **** LOAD/CREATE HIGH SCORE DATA ****
	highscores = {}
	if love.filesystem.exists("highscores.txt") == false then
		-- **** CREATE DATA ****
		hs = "BOB,20000;JAN,10000;JOE,1000;"
		love.filesystem.write("highscores.txt",hs)
	end

	-- **** LOAD DATA ****
	hs = love.filesystem.read("highscores.txt")
	for s in string.gmatch(hs,"([%w,]+);") do
		for k,v in string.gmatch(s, "(%a+),(%d+)") do
			j = {}
			j["name"] = k
			j["score"] = tonumber(v)
			table.insert(highscores,j)
			j = nil
		end
	end
	
	-- **** GAME DATA ****
	game = {}
	game["screen_w"] = love.graphics.getWidth()
	game["screen_h"] = love.graphics.getHeight()
	game["end_game"] = 0
	game["enemy_flag"] = 0
	game["enemy_timer"] = 0	
	game["enemy_anim_rate"] = 10000
	game["item_move_rate"] = 200
	game["item_anim_rate"] = 10000
	game["bullet_anim_rate"] = 10000
	game["timer_max"] = 1000
	game["default_font"] = love.graphics.newFont(24)
	game["spacebar_flag"] = false
	game["spacebar_flag_previous"] = false
	game["current_level"] = 1
	game["enemy_rate"] = 1000
	game["enemy_rate_mod"] = 100
	game["enemy_move_mod"] = 5
	game["enemy_life_mod"] = 0.1
	game["condition_count"] = 0
	game["condition"] = 50
	game["transition_flag"] = 1
	game["transition_ship_animation_rate"] = 200
	game["backgrounds"] = {}
	game.backgrounds[1] = love.graphics.newImage("planet1.png")
	game.backgrounds[2] = love.graphics.newImage("planet2.png")
	game.backgrounds[3] = love.graphics.newImage("planet3.png")
	game.backgrounds[4] = love.graphics.newImage("planet4.png")
	game.backgrounds[5] = love.graphics.newImage("planet5.png")
	game["background_pos"] = -300
	game["background_rate"] = 1
	game["background_index"] = math.random(#game.backgrounds)
	game["highscore_name"] = ""
	game["highscore_entered_flag"] = false
	love.graphics.setFont(game.default_font)
	love.graphics.setLine(5,"rough")
	
		-- **** BACKGROUND ****
	background = {}
	background["img"] = {}
	background.img[1] = love.graphics.newImage("stars.PNG")
	background.img[2] = love.graphics.newImage("stars2.png")
	background["img_w"] = background.img[1]:getWidth()
	background["img_h"] = background.img[1]:getHeight()
	background["pos_1"]	= 0
	background["pos_2"]	= -600
	background["pos_3"]	= 0
	background["pos_4"]	= -600	
	background["scrolling_rate"] = 50	
	background["scrolling_rate_2"] = 25	

	
	-- **** PLAYER ****
	player = {}
	player["img"] = {}
	player.img[1] = love.graphics.newImage("player1.PNG")
	player.img[2] = love.graphics.newImage("player2.PNG")
	player.img[3] = love.graphics.newImage("player3.PNG")
	player.img[4] = love.graphics.newImage("player4.PNG")
	player.img[5] = love.graphics.newImage("player5.PNG")
	player.img[6] = love.graphics.newImage("player6.PNG")
	player["img_offset_w"] = player.img[1]:getWidth() / 2
	player["img_offset_h"] = player.img[1]:getHeight() / 2
	player["anim_current_frame"] = 1
	player["anim_type"] = "normal"
	player["animations"] = {"normal", "shoot", "death"}
	player.animations.normal = {1,3}
	player.animations.shoot = {1,1}
	player.animations.death = {4,6}
	player["anim_timer"] = 0
	player["anim_timer_rate"] = 10000
	player["pos_x"] = game.screen_w / 2
	player["pos_y"] = game.screen_h - player.img[1]:getHeight() - 20
	player["move_rate"] = 300
	player["can_collide"] = 0
	player["collide_reset_timer"] = 0
	player["collide_reset_timer_rate"] = 1000
	player["invisible"] = 0
	player["invisible_timer"] = 0
	player["invisible_timer_rate"] = 1000	
	player["score"] = 0
	player["lives"] = 3
	player["life_img"] = love.graphics.newImage("playerlife.PNG")	
	player["life_img_w"] = player.life_img:getWidth()
	player["life_img_h"] = player.life_img:getHeight()
	player["fire_flag"] = 0
	player["fire_timer"] = 0
	player["bullet_ref"] = 2
	player["bullet_mod"] = 1
	player["level_shots"] = 0
	player["level_hits"] = 0
	player["game_shots"] = 0
	player["game_hits"] = 0
	player["extralife_count"] = 0
	player["extralife_max"] = 50000
	
	-- **** PLAYER BULLET DATA ****
	bullet_data = {}
	bullets = {}

	-- preload bullets
	local bul = {}
	bul["name"] = "No Bullet"
	bul["img"] = {}
	bul.img[1] = love.graphics.newImage("bullet51.png")
	bul["img_offset_w"] = bul.img[1]:getWidth() / 2
	bul["img_offset_h"] = bul.img[1]:getHeight() / 2
    bul["move_rate_x"] = 0
	bul["move_rate_y"] = 0
	bul["fire_timer_rate"] = 0
	bul["animations"] = {"normal","death"}
	bul.animations.normal = {1,1}
	bul.animations.death = {1,1}
	bul["strength"] = 0
	table.insert(bullet_data,bul)
	bul = nil
	
	bul = {}
	bul["name"] = "Player Laser"
	bul["img"] = {}
	bul.img[1] = love.graphics.newImage("bullet51.png")
	bul.img[2] = love.graphics.newImage("bullet52.png")
	bul.img[3] = love.graphics.newImage("bullet53.png")
	bul.img[4] = love.graphics.newImage("bullet54.png")
	bul["img_offset_w"] = bul.img[1]:getWidth() / 2
	bul["img_offset_h"] = bul.img[1]:getHeight() / 2
    bul["move_rate_x"] = 0
	bul["move_rate_y"] = 600
	bul["fire_timer_rate"] = 6000
	bul["animations"] = {"normal","death"}
	bul.animations.normal = {1,4}
	bul.animations.death = {4,4}
	bul["strength"] = 1
	bul["audio"] = "laser.wav"
	table.insert(bullet_data,bul)
	bul = nil			
	
	-- **** SCORE DATA ****
	score_data = {}
	score_data["move_rate"] = 100
	score_data["score_timer_rate"] = 1000
	scores = {}	

	-- **** ITEM DATA ****
	item_data = {}
	items = {}	

	--Pre-load item data
	local it = {}
	it["name"] = "Weapon+"
	it["img"] = {}
	it.img[1] = love.graphics.newImage("item11.png")
	it.img[2] = love.graphics.newImage("item12.png")
	it.img[3] = love.graphics.newImage("item13.png")
	it.img[4] = love.graphics.newImage("item14.png")
	it["img_offset_w"] = it.img[1]:getWidth()/2
	it["img_offset_h"] = it.img[1]:getHeight()/2
	it["animations"] = {"normal", "death"}
	it.animations.normal = {1,4}
	it.animations.death = {4,4}
	it["score"] = 1000
	it["modifier"] = "bullet_mod"
	it["modifier_value"] = 0.25 
	it["modifier_op"] = "+"
	table.insert(item_data,it)
	it = nil
	
	-- **** ENEMY DATA ****
	enemy_data = {}
	enemies = {}
	enemy_bullets = {}	

	--Pre-load Enemy Graphics and Offsets
	local ed = {}
	ed["name"] = "Small Asteroid"
	ed["img"] = {}
	ed.img[1] = love.graphics.newImage("enemy11.png")
	ed.img[2] = love.graphics.newImage("enemy12.png")
	ed.img[3] = love.graphics.newImage("enemy13.png")
	ed.img[4] = love.graphics.newImage("enemy14.png")	
	ed.img[5] = love.graphics.newImage("enemy15.png")	
	ed.img[6] = love.graphics.newImage("enemy16.png")	
	ed["img_offset_w"] = ed.img[1]:getWidth() / 2
	ed["img_offset_h"] = ed.img[1]:getHeight() / 2
	ed["item_drop_chance"] = 5
	ed["x_rate_min"] = -25
	ed["x_rate_max"] = 25
	ed["y_rate_min"] = 100
	ed["y_rate_max"] = 200
	ed["starting_pos_x"] = 0
	ed["starting_pos_y"] = 0
	ed["rotation_min"] = 0
	ed["rotation_max"] = 0
	ed["animations"] = {"normal", "shoot", "death"}
	ed.animations.normal = {1,4}
	ed.animations.death = {5,6}	
	ed["score"] = 100
	ed["life"] = 1
	ed["level_kills"] = 0
	ed["game_kills"] = 0
	table.insert(enemy_data,ed)
	ed = nil

	local ed = {}
	ed["name"] = "Large Asteroid"	
	ed["img"] = {}
	ed.img[1] = love.graphics.newImage("enemy21.png")
	ed.img[2] = love.graphics.newImage("enemy22.png")
	ed.img[3] = love.graphics.newImage("enemy23.png")
	ed.img[4] = love.graphics.newImage("enemy24.png")
	ed.img[5] = love.graphics.newImage("enemy25.png")	
	ed.img[6] = love.graphics.newImage("enemy26.png")	
	ed["img_offset_w"] = ed.img[1]:getWidth() / 2
	ed["img_offset_h"] = ed.img[1]:getHeight() / 2
	ed["item_drop_chance"] = 10
	ed["x_rate_min"] = -25
	ed["x_rate_max"] = 25
	ed["y_rate_min"] = 100
	ed["y_rate_max"] = 200	
	ed["starting_pos_x"] = 0
	ed["starting_pos_y"] = 0
	ed["rotation_min"] = 0
	ed["rotation_max"] = 0
	ed["animations"] = {"normal", "shoot", "death"}
	ed.animations.normal = {1,4}
	ed.animations.death = {5,6}	
	ed["score"] = 200
	ed["life"] = 2
	ed["level_kills"] = 0
	ed["game_kills"] = 0
	table.insert(enemy_data,ed)
	ed = nil	
end

function love.keypressed(key, unicode)

	-- **** CHECK FOR SPACE KEY PRESS FOR TRANSITION CHANGES ****
	if key == " " and game.spacebar_flag_previous == false and (game.transition_flag == 1 or game.transition_flag == 4 or (game.end_game == 1 and game.highscore_entered_flag == true)) then		
		game.spacebar_flag = true
	end
	
	-- **** CHECK FOR HIGHSCORE NAME INPUT ****
	if game.end_game == 1 and player.score > highscores[#highscores].score and game.highscore_entered_flag == false then
		-- add the key to the string
		if unicode > 31 and unicode < 127 then 
			game.highscore_name = game.highscore_name..string.upper(string.char(unicode))
		end
		
		-- keep the highscore name to 3 characters
		if string.len(game.highscore_name) > 3 then
			game.highscore_name = string.sub(game.highscore_name,2)
		end
		
		--the user is done and has hit enter, lets write the file.
		if unicode == 13 and string.len(game.highscore_name) > 0 then
			--record it
			hs = {}
			hs["name"] = game.highscore_name
			hs["score"] = player.score
			
			-- insert it into the table at the right spot
			for i = 1, #highscores - 1 do
				--first check if it is great than the first
				if i == 1 and player.score > highscores[i].score then
					table.insert(highscores,i,hs)
					table.remove(highscores,#highscores)
					break				
				end
				--is the score in between or equal to i and i+1 then insert at i+1?
				if player.score <= highscores[i].score and player.score >= highscores[i+1].score then
					table.insert(highscores,i+1,hs)
					table.remove(highscores,#highscores)
					break
				end
			end			
			hs = nil
			
			--lets just reuse this... 
			hs = ""
			for i = 1, #highscores do
				hs = hs..highscores[i].name..","..highscores[i].score..";"
			end
			love.filesystem.write("highscores.txt",hs)
			game.highscore_entered_flag = true
		end
	end	
end

-- check for sources that finished playing and remove them
-- add to love.update
function love.audio.update()
	local remove = {}
	for _,s in pairs(sources) do
		if s:isStopped() then
			remove[#remove + 1] = s
		end
	end

	for i,s in ipairs(remove) do
		sources[s] = nil
	end
end

-- overwrite love.audio.play to create and register source if needed
local play = love.audio.play
function love.audio.play(what, how, loop)
	local src = what
	if type(what) ~= "userdata" or not what:typeOf("Source") then
		src = love.audio.newSource(what, how)
		src:setLooping(loop or false)
	end

	play(src)
	sources[src] = src
	return src
end

-- stops a source
local stop = love.audio.stop
function love.audio.stop(src)
	if not src then return end
	stop(src)
	sources[src] = nil
end



function love.update(dt)
    love.audio.update()
	
	print("UPDATE BACKGROUND")
	-- **** UPDATE THE BACKGROUND IMAGE ****
	background.pos_1 = background.pos_1 + (dt * background.scrolling_rate)
	background.pos_2 = background.pos_2 + (dt * background.scrolling_rate)
	background.pos_3 = background.pos_3 + (dt * background.scrolling_rate_2)
	background.pos_4 = background.pos_4 + (dt * background.scrolling_rate_2)
	if game.background_pos < game.screen_h then game.background_pos = game.background_pos + (dt * game.background_rate) end

	if background.pos_1 >= background.img_h then background.pos_1 = 0 end
	if background.pos_2 >= 0 then background.pos_2 = background.img_h * -1 end
	if background.pos_3 >= background.img_h then background.pos_3 = 0 end
	if background.pos_4 >= 0 then background.pos_4 = background.img_h * -1 end
	

	if game.end_game == 0 then
	
		print("UPDATE LEVEL TRANSITION TIMER")
		-- **** UPDATE LEVEL TRANSITION MODE 1, INCREMENT STORY ELEMENT TO NEXT IF HIT TIMER MAX OR PLAYER HIT SPACEBAR, SET TO NEXT LEVEL TRANSITION PHASE ON PLAYER INPUT ****
		if game.transition_flag == 1 then
			if game.spacebar_flag == true then
				game.transition_flag = 2
				player.pos_y = game.screen_h + player.img_offset_h
				game.transition_ship_animation_rate = 50
				player.pos_x = game.screen_w / 2
				player.can_collide = 0
				player.level_hits = 0
				player.level_shots = 0
				game.highscore_entered_flag = false
				for i = 1, #enemy_data do
					enemy_data[i].level_kills = 0
				end
			end
		-- **** UPDATE LEVEL TRANSITION MODE 2, PROCEED TO NORMAL LEVEL IF HIT TIMER MAX ****
		elseif game.transition_flag == 2 then
			print("UPDATE PLAYER ANIMATION TIMER")
			player.anim_timer = player.anim_timer + (dt * player.anim_timer_rate)
			if player.anim_timer >= game.timer_max then
				player.anim_timer = 0
				player.anim_current_frame = player.anim_current_frame + 1
				if player.anim_current_frame > player.animations[player.anim_type][2] then 
					player.anim_current_frame = player.animations[player.anim_type][1]
				end
			end		
			print("UPDATE PLAYER POSITION")
			player.pos_y = player.pos_y - (dt * game.transition_ship_animation_rate)
			if player.pos_y <= game.screen_h - player.img[1]:getHeight() - 20 then
				game.transition_flag = 0
				player.pos_y = game.screen_h - player.img[1]:getHeight() - 20
				game.transition_ship_animation_rate = 200
			end
		-- **** UPDATE LEVEL TRANSITION MODE 3, PROCEED TO TRANSITION 4 IF HIT TIMER MAX ****
		elseif game.transition_flag == 3 then
			print("UPDATE PLAYER ANIMATION TIMER")
			player.anim_timer = player.anim_timer + (dt * player.anim_timer_rate)
			if player.anim_timer >= game.timer_max then
				player.anim_timer = 0
				player.anim_current_frame = player.anim_current_frame + 1
				if player.anim_current_frame > player.animations[player.anim_type][2] then 
					player.anim_current_frame = player.animations[player.anim_type][1]
				end
			end		
			print("UPDATE PLAYER POSITION")
			player.pos_y = player.pos_y - (dt * game.transition_ship_animation_rate)
			if player.pos_y <= 0 - player.img_offset_h then
				game.transition_flag = 4
			end
		-- **** UPDATE LEVEL TRANSITION MODE 4, PROCEED TO TRANSITION 2 ON PLAYER INPUT ****
		elseif game.transition_flag == 4 then	
			if game.spacebar_flag == true then
				game.spacebar_flag = false
				game.current_level = game.current_level + 1
				game.transition_flag = 2
				game.background_index = math.random(#game.backgrounds)
				game.background_pos = -300
				game.background_rate = 1
				player.pos_y = game.screen_h + player.img_offset_h
				game.transition_ship_animation_rate = 50
				player.pos_x = game.screen_w / 2
				player.can_collide = 0
				player.level_hits = 0
				player.level_shots = 0
				for i = 1, #enemy_data do
					enemy_data[i].level_kills = 0
				end				
			end
		else
			-- **** MAIN GAME UPDATE ****
			local i, j = 1			--Counters for loops
			local removed = 0		--A flag that tracks if items should be removed from tables

			print("UPDATE PLAYER INVISIBLE TIMER")
			-- **** UPDATE PLAYER INVISIBLE TIMER, SET TO VISIBLE IF HIT MAX ****
			if player.invisible == 1 then
				player.invisible_timer = player.invisible_timer + (dt * player.invisible_timer_rate)
				if player.invisible_timer >= game.timer_max then
					player.invisible = 0
					player.invisible_timer = 0
				end
			end
			
			print("UPDATE PLAYER COLLIDE TIMER")
			-- **** UPDATE PLAYER COLLIDE TIMER, SET TO COLLIDE IF HIT MAX ****
			if player.can_collide == 0 and player.anim_type ~= "death" and player.invisible == 0 then
				player.collide_reset_timer = player.collide_reset_timer + (dt * player.collide_reset_timer_rate)
				if player.collide_reset_timer >= game.timer_max then 
					player.can_collide = 1
					player.collide_reset_timer = 0
				end
			end
			
			print("UPDATE PLAYER POSITION")
			-- **** UPDATE PLAYER POSITION ****
			if player.invisible == 0 then
				if love.keyboard.isDown("left") then
					player.pos_x = player.pos_x - (dt * player.move_rate)
					if player.pos_x < player.img_offset_w then player.pos_x = player.img_offset_w end
				end
				if love.keyboard.isDown("right") then
					player.pos_x = player.pos_x + (dt * player.move_rate)
					if player.pos_x > (game.screen_w - player.img_offset_w) then player.pos_x = (game.screen_w - player.img_offset_w) end
				end
			end

			print("CREATE NEW ENEMY")
			-- **** CREATE A NEW ENEMY IF NECESSARY ****
			if game.enemy_flag == 0 then
				game.condition_count = game.condition_count + 1
				local en = {}
				en["ref"] = math.random(1,#enemy_data)
				en["x"] = math.random(100, game.screen_w - 100)
				en["y"] = enemy_data[en.ref].img_offset_h * -1
				en["rate_y"] = math.random(enemy_data[en.ref].y_rate_min + ((game.current_level-1)*game.enemy_move_mod),enemy_data[en.ref].y_rate_max + ((game.current_level-1)*game.enemy_move_mod))
				en["rate_x"] = math.random(enemy_data[en.ref].x_rate_min,enemy_data[en.ref].x_rate_max)
				en["rotation"] = math.random(enemy_data[en.ref].rotation_min,enemy_data[en.ref].rotation_max)
				en["anim_type"] = "normal"
				en["anim_current_frame"] = enemy_data[en.ref].animations.normal[1]
				en["anim_timer"] = 0
				en["life"] = enemy_data[en.ref].life + ((game.current_level-1)*game.enemy_life_mod)
				table.insert(enemies,en)
				game.enemy_flag = 1
			end	

			print("UPDATE ENEMY CREATION TIMER")
			-- **** UPDATE ENEMY CREATION TIMER ****		
			if game.enemy_flag == 1 then
				game.enemy_timer = game.enemy_timer + (dt * (game.enemy_rate + game.enemy_rate_mod*game.current_level))
				if game.enemy_timer >= game.timer_max then 
					game.enemy_flag = 0
					game.enemy_timer = 0
				end
			end	
			
			print("UPDATE ENEMY POSITIONS")
			-- **** UPDATE ENEMY POSITIONS AND ENEMY BULLET TIMERS, ADD ENEMY BULLETS IF NECESSARY, REMOVE ENEMIES IF OFF SCREEN ****
			i = 1
			removed = 0
			while i <= #enemies do
				removed = 0
				if enemies[i].anim_type ~= "death" then
					enemies[i].x = enemies[i].x + (dt * enemies[i].rate_x)
					enemies[i].y = enemies[i].y + (dt * enemies[i].rate_y)
					if enemies[i].y > (game.screen_h + enemy_data[enemies[i].ref].img_offset_h) or (enemies[i].x < 0 - enemy_data[enemies[i].ref].img_offset_w) or (enemies[i].x > game.screen_w + enemy_data[enemies[i].ref].img_offset_w) then
						local s = {}
						s["x"] = enemies[i].x
						s["y"] = game.screen_h - 25
						s["score_timer"] = 0
						s["text"] = "-"..enemy_data[enemies[i].ref].score
						s["colour"] = {255,0,0,255}
						table.insert(scores,s)
						s = nil
						player.score = player.score - enemy_data[enemies[i].ref].score
						player.extralife_count = player.extralife_count - enemy_data[enemies[i].ref].score
						table.remove(enemies,i)
						removed = 1
					end
				end
				if removed == 0 then i = i + 1 end					
			end
			
			print("CREATE NEW PLAYER BULLETS")
			-- **** CREATE NEW PLAYER BULLETS ****
			if love.keyboard.isDown(" ") and player.fire_flag == 0 and player.invisible == 0 then
				local bul = {}
				bul["x"] = player.pos_x
				bul["y"] = player.pos_y
				bul["bullet_ref"] = player.bullet_ref
				bul["anim_type"] = "normal"
				bul["anim_current_frame"] = bullet_data[player.bullet_ref].animations.normal[1]
				bul["anim_timer"] = 0				
				table.insert(bullets,bul)
				player.fire_flag = 1
				player.level_shots = player.level_shots + 1
				player.game_shots = player.game_shots + 1
				love.audio.play("laser.wav")
			end
			
			print("UPDATE PLAYER BULLET TIMER")
			-- **** UPDATE PLAYER BULLET TIMER ****
			if player.fire_flag == 1 then
				player.fire_timer = player.fire_timer + (dt * bullet_data[player.bullet_ref].fire_timer_rate)
				if player.fire_timer >= game.timer_max then 
					player.fire_flag = 0
					player.fire_timer = 0
				end
			end			

			print("UPDATE PLAYER BULLET POSITIONS")
			-- **** UPDATE PLAYER BULLET POSITIONS, REMOVE BULLET IF OUTSIDE OF GAME WINDOW ****
			i = 1
			removed = 0
			while i <= #bullets do
				removed = 0
				bullets[i].y = bullets[i].y - (dt * bullet_data[bullets[i].bullet_ref].move_rate_y)
				if bullets[i].y < 0 then
					table.remove(bullets,i)
					removed = 1
				end
				if removed == 0 then i = i + 1 end		
			end			

			print("CHECK PLAYER BULLET COLLISION WITH ENEMY")
			-- **** CHECK PLAYER BULLET COLLIDED WITH ENEMY, IF COLLISION THEN REMOVE PLAYER BULLET, ADD SCORE, ITEM ****
			i = 1
			local j = 1
			while i <= #bullets do
				if bullets[i].anim_type ~= "death" then
					for j = 1, #enemies do
						if enemies[j].anim_type ~= "death" then
							if (bullets[i].x - bullet_data[bullets[i].bullet_ref].img_offset_w >= enemies[j].x - enemy_data[enemies[j].ref].img_offset_w and bullets[i].x - bullet_data[bullets[i].bullet_ref].img_offset_w <= enemies[j].x + enemy_data[enemies[j].ref].img_offset_w) or (bullets[i].x + bullet_data[bullets[i].bullet_ref].img_offset_w >= enemies[j].x - enemy_data[enemies[j].ref].img_offset_w and bullets[i].x + bullet_data[bullets[i].bullet_ref].img_offset_w <= enemies[j].x + enemy_data[enemies[j].ref].img_offset_w) then
								if (bullets[i].y - bullet_data[bullets[i].bullet_ref].img_offset_h >= enemies[j].y - enemy_data[enemies[j].ref].img_offset_h and bullets[i].y - bullet_data[bullets[i].bullet_ref].img_offset_h <= enemies[j].y + enemy_data[enemies[j].ref].img_offset_h) or (bullets[i].y + bullet_data[bullets[i].bullet_ref].img_offset_h >= enemies[j].y - enemy_data[enemies[j].ref].img_offset_h and bullets[i].y + bullet_data[bullets[i].bullet_ref].img_offset_h <= enemies[j].y + enemy_data[enemies[j].ref].img_offset_h) then
									enemies[j].life = enemies[j].life - bullet_data[bullets[i].bullet_ref].strength * player.bullet_mod
									bullets[i].anim_type = "death"
									bullets[i].anim_current_frame = bullet_data[bullets[i].bullet_ref].animations.death[1]
									player.level_hits = player.level_hits + 1
									player.game_hits = player.game_hits + 1
									if enemies[j].life <= 0 then
										if math.random(100) <= enemy_data[enemies[j].ref].item_drop_chance then
											local it = {}
											it["x"] = enemies[j].x
											it["y"] = enemies[j].y
											it["item_ref"] = math.random(#item_data)
											it["anim_type"] = "normal"
											it["anim_current_frame"] = item_data[it.item_ref].animations.normal[1]
											it["anim_timer"] = 0
											table.insert(items,it)
											it = nil
										end									
										enemies[j].anim_type = "death"
										enemies[j].anim_current_frame = enemy_data[enemies[j].ref].animations.death[1]
										enemy_data[enemies[j].ref].level_kills = enemy_data[enemies[j].ref].level_kills + 1
										enemy_data[enemies[j].ref].game_kills = enemy_data[enemies[j].ref].game_kills + 1
										local a = love.audio.play("explosion.wav")
										a:setVolume(0.5)
										-- **** CREATE FOUR SMALL ASTEROIDS IF A LARGE ASTEROID WAS KILLED ****
										if enemy_data[enemies[j].ref].name == "Large Asteroid" then
											local en = {}
											en["ref"] = 1
											en["x"] = enemies[j].x
											en["y"] = enemies[j].y
											en["rate_y"] = math.random(enemy_data[en.ref].y_rate_min + ((game.current_level-1)*game.enemy_move_mod),enemy_data[en.ref].y_rate_max + ((game.current_level-1)*game.enemy_move_mod))
											en["rate_x"] = enemy_data[en.ref].x_rate_min*2
											en["rotation"] = math.random(enemy_data[en.ref].rotation_min,enemy_data[en.ref].rotation_max)
											en["anim_type"] = "normal"
											en["anim_current_frame"] = enemy_data[en.ref].animations.normal[1]
											en["anim_timer"] = 0
											en["life"] = enemy_data[en.ref].life + ((game.current_level-1)*game.enemy_life_mod)
											table.insert(enemies,en)
											en = nil
											en = {}
											en["ref"] = 1
											en["x"] = enemies[j].x
											en["y"] = enemies[j].y
											en["rate_y"] = math.random(enemy_data[en.ref].y_rate_min + ((game.current_level-1)*game.enemy_move_mod),enemy_data[en.ref].y_rate_max + ((game.current_level-1)*game.enemy_move_mod))
											en["rate_x"] = enemy_data[en.ref].x_rate_min
											en["rotation"] = math.random(enemy_data[en.ref].rotation_min,enemy_data[en.ref].rotation_max)
											en["anim_type"] = "normal"
											en["anim_current_frame"] = enemy_data[en.ref].animations.normal[1]
											en["anim_timer"] = 0
											en["life"] = enemy_data[en.ref].life + ((game.current_level-1)*game.enemy_life_mod)
											table.insert(enemies,en)
											en = nil
											en = {}
											en["ref"] = 1
											en["x"] = enemies[j].x
											en["y"] = enemies[j].y
											en["rate_y"] = math.random(enemy_data[en.ref].y_rate_min + ((game.current_level-1)*game.enemy_move_mod),enemy_data[en.ref].y_rate_max + ((game.current_level-1)*game.enemy_move_mod))
											en["rate_x"] = enemy_data[en.ref].x_rate_max
											en["rotation"] = math.random(enemy_data[en.ref].rotation_min,enemy_data[en.ref].rotation_max)
											en["anim_type"] = "normal"
											en["anim_current_frame"] = enemy_data[en.ref].animations.normal[1]
											en["anim_timer"] = 0
											en["life"] = enemy_data[en.ref].life + ((game.current_level-1)*game.enemy_life_mod)
											table.insert(enemies,en)																					
											en = nil
											en = {}
											en["ref"] = 1
											en["x"] = enemies[j].x
											en["y"] = enemies[j].y
											en["rate_y"] = math.random(enemy_data[en.ref].y_rate_min + ((game.current_level-1)*game.enemy_move_mod),enemy_data[en.ref].y_rate_max + ((game.current_level-1)*game.enemy_move_mod))
											en["rate_x"] = enemy_data[en.ref].x_rate_max*2
											en["rotation"] = math.random(enemy_data[en.ref].rotation_min,enemy_data[en.ref].rotation_max)
											en["anim_type"] = "normal"
											en["anim_current_frame"] = enemy_data[en.ref].animations.normal[1]
											en["anim_timer"] = 0
											en["life"] = enemy_data[en.ref].life + ((game.current_level-1)*game.enemy_life_mod)
											table.insert(enemies,en)																					
											en = nil
										end
									end					
									break
								end
							end
						end
					end
				end
				i = i + 1
			end			
			
			print("CHECK PLAYER COLLISION WITH ITEM")
			-- **** CHECK PLAYER COLLIDED WITH ITEM, IF COLLISION THEN APPLY ITEM BONUS, TURN ON ITEM DEATH ANIMATION ****
			if player.can_collide == 1 then
				for i = 1, #items do
					if (items[i].y + item_data[items[i].item_ref].img_offset_h) >= player.pos_y - player.img_offset_h and (items[i].y + item_data[items[i].item_ref].img_offset_h) <= player.pos_y + player.img_offset_h or (items[i].y - item_data[items[i].item_ref].img_offset_h) >= player.pos_y + player.img_offset_h and (items[i].y - item_data[items[i].item_ref].img_offset_h) <= player.pos_y - player.img_offset_h then
						if (items[i].x - item_data[items[i].item_ref].img_offset_w) >= (player.pos_x - player.img_offset_w) and (items[i].x - item_data[items[i].item_ref].img_offset_w) <= (player.pos_x + player.img_offset_w) or (items[i].x + item_data[items[i].item_ref].img_offset_w) >= (player.pos_x - player.img_offset_w) and (items[i].x + item_data[items[i].item_ref].img_offset_w) <= (player.pos_x + player.img_offset_w) then
							if items[i].anim_type == "normal" then
								items[i].anim_type = "death"
								items[i].anim_current_frame = item_data[items[i].item_ref].animations.death[1]
								love.audio.play("weaponup.wav")
							end
						end
					end
				end
			end
			
			print("CHECK PLAYER ENEMY COLLISIONS")
			-- **** CHECK FOR ENEMY AND PLAYER COLLISION, IF COLLISION, REDUCE PLAYER LIFE AND MAKE PLAYER INVULNERABLE ****
			if player.can_collide == 1 then
				for i = 1, #enemies do
					if (enemies[i].y + enemy_data[enemies[i].ref].img_offset_w) >= player.pos_y - player.img_offset_h then
						if (enemies[i].x - enemy_data[enemies[i].ref].img_offset_w) >= (player.pos_x - player.img_offset_w) and (enemies[i].x - enemy_data[enemies[i].ref].img_offset_w) <= (player.pos_x + player.img_offset_w) or (enemies[i].x + enemy_data[enemies[i].ref].img_offset_w) >= (player.pos_x - player.img_offset_w) and (enemies[i].x + enemy_data[enemies[i].ref].img_offset_w) <= (player.pos_x + player.img_offset_w) then
							player.lives = player.lives - 1
							player.can_collide = 0
							player.anim_type = "death"
							player.anim_current_frame = player.animations[player.anim_type][1]
							enemies[i].anim_type = "death"
							enemies[i].anim_current_frame = enemy_data[enemies[i].ref].animations.death[1]
							player.bullet_mod = player.bullet_mod - 1
							if player.bullet_mod < 1 then player.bullet_mod = 1 end
							love.audio.play("explosion.wav")
						end
					end
				end
			end				
			
			print("UPDATE SCORE POSITIONS")
			-- **** UPDATE SCORE POSITIONS, REMOVE IF SCORE TIMER HAS RUN OUT ****
			i = 1
			removed = 0
			while i <= #scores do
				removed = 0
				scores[i].y = scores[i].y - (dt * score_data.move_rate)
				scores[i].score_timer = scores[i].score_timer + (dt * score_data.score_timer_rate)
				if scores[i].score_timer >= game.timer_max then
					table.remove(scores,i)
					removed = 1
				end
				if removed == 0 then i = i + 1 end		
			end	

			print("UPDATE ITEM POSITIONS")
			-- **** UPDATE ITEM POSITIONS, REMOVE IF OUTSIDE SCREEN ****
			i = 1
			removed = 0
			while i <= #items do
				removed = 0
				if items[i].anim_type ~= "death" then
					items[i].y = items[i].y + (dt * game.item_move_rate)
					if items[i].y > game.screen_h then
						table.remove(items,i)
						removed = 1
					end
				end
				if removed == 0 then i = i + 1 end
			end	

			print("UPDATE ITEM ANIMATION TIMER")
			-- **** UPDATE ITEM ANIMATION TIMER, UPDATE FRAME AND LOOP IF NECESSARY, APPLY ITEM MODIFICATION, REMOVE ITEM FROM SCREEN IF AT END OF DEATH ANIMATION ----
			i = 1
			removed = 0
			while i <= #items do
				removed = 0
				items[i].anim_timer = items[i].anim_timer + (dt * game.item_anim_rate)
				if items[i].anim_timer >= game.timer_max then
					items[i].anim_timer = 0
					items[i].anim_current_frame = items[i].anim_current_frame + 1
					if items[i].anim_current_frame > item_data[items[i].item_ref].animations[items[i].anim_type][2] then
						if items[i].anim_type == "death" then
							if item_data[items[i].item_ref].modifier_op == "=" then
								player[item_data[items[i].item_ref].modifier] = item_data[items[i].item_ref].modifier_value
							elseif item_data[items[i].item_ref].modifier_op == "+" then
								player[item_data[items[i].item_ref].modifier] = player[item_data[items[i].item_ref].modifier] + item_data[items[i].item_ref].modifier_value
							end
							local s = {}
							s["x"] = items[i].x
							s["y"] = items[i].y
							s["score_timer"] = 0
							s["text"] = "+"..item_data[items[i].item_ref].score
							s["colour"] = {0,255,0,255}
							table.insert(scores,s)
							s = nil	
							player.score = player.score + item_data[items[i].item_ref].score
							player.extralife_count = player.extralife_count + item_data[items[i].item_ref].score
							if player.extralife_count >= player.extralife_max then 
								player.lives = player.lives + 1
								player.extralife_count = player.extralife_count - player.extralife_max
								local s = {}
								s["x"] = game.screen_w/2
								s["y"] = game.screen_h/2
								s["score_timer"] = 0
								s["text"] = "1-UP!"
								s["colour"] = {255,255,0,255}
								table.insert(scores,s)
								s = nil					
								love.audio.play("1up.wav")
							end							
							table.remove(items,i)
							removed = 1
						else
							items[i].anim_current_frame = item_data[items[i].item_ref].animations[items[i].anim_type][1]
						end
					end
				end
				if removed == 0 then i = i + 1 end				
			end
			
			print("UPDATE PLAYER ANIMATION TIMER")
			-- **** UPDATE PLAYER ANIMATION TIMER, UPDATE FRAME AND LOOP IF NECESSARY ----
			player.anim_timer = player.anim_timer + (dt * player.anim_timer_rate)
			if player.anim_timer >= game.timer_max then
				player.anim_timer = 0
				player.anim_current_frame = player.anim_current_frame + 1
				if player.anim_current_frame > player.animations[player.anim_type][2] then 
					player.anim_current_frame = player.animations[player.anim_type][1]
					if player.anim_type == "death" then
						player.invisible = 1
						player.can_collide = 0
						player.collide_reset_timer = 0
						player.anim_type = "normal"
					end
				end
			end

			print("UPDATE PLAYER BULLET ANIMATION TIMER")
			-- **** UPDATE PLAYER BULLET ANIMATION TIMER ****
			i = 1
			removed = 0
			while i <= #bullets do
				removed = 0
				bullets[i].anim_timer = bullets[i].anim_timer + (dt * game.bullet_anim_rate)
				if bullets[i].anim_timer >= game.timer_max then
					bullets[i].anim_timer = 0
					bullets[i].anim_current_frame = bullets[i].anim_current_frame + 1
					if bullets[i].anim_current_frame > bullet_data[bullets[i].bullet_ref].animations[bullets[i].anim_type][2] then
						if bullets[i].anim_type == "death" then					
							table.remove(bullets,i)
							removed = 1
						else
							bullets[i].anim_current_frame = bullet_data[bullets[i].bullet_ref].animations[bullets[i].anim_type][1]
						end
					end
				end
				if removed == 0 then i = i + 1 end				
			end
					
			print("UPDATE ENEMY ANIMATION TIMER")
			-- **** UPDATE ENEMY ANIMATION TIMER, UPDATE FRAME AND LOOP IF NECESSARY ----
			i = 1
			removed = 0
			while i <= #enemies do
				removed = 0
				enemies[i].anim_timer = enemies[i].anim_timer + (dt * game.enemy_anim_rate)
				if enemies[i].anim_timer >= game.timer_max then
					enemies[i].anim_timer = 0
					enemies[i].anim_current_frame = enemies[i].anim_current_frame + 1
					if enemies[i].anim_current_frame > enemy_data[enemies[i].ref].animations[enemies[i].anim_type][2] then
						if enemies[i].anim_type == "death" then
							local s = {}
							s["x"] = enemies[i].x
							s["y"] = enemies[i].y
							s["score_timer"] = 0
							s["text"] = "+"..enemy_data[enemies[i].ref].score
							s["colour"] = {0,255,0,255}
							table.insert(scores,s)
							s = nil								
							player.score = player.score + enemy_data[enemies[i].ref].score
							player.extralife_count = player.extralife_count + enemy_data[enemies[i].ref].score
							if player.extralife_count >= player.extralife_max then 
								player.lives = player.lives + 1
								player.extralife_count = player.extralife_count - player.extralife_max
								local s = {}
								s["x"] = game.screen_w/2
								s["y"] = game.screen_h/2
								s["score_timer"] = 0
								s["text"] = "1-UP!"
								s["colour"] = {255,255,0,255}
								table.insert(scores,s)
								s = nil						
								love.audio.play("1up.wav")								
							end	
							table.remove(enemies,i)
							removed = 1
						else
							enemies[i].anim_current_frame = enemy_data[enemies[i].ref].animations[enemies[i].anim_type][1]
						end
					end
				end
				if removed == 0 then i = i + 1 end				
			end			
			
			print("CHECK IF CURRENT LEVEL IS OVER")
			-- **** CHECK IF CURRENT LEVEL IS OVER ****
			if game.condition_count > game.condition then
				game.transition_flag = 3
				game.condition_count = 0
				game.background_rate = 100
				game.condition = game.condition + 5
				game.enemy_flag = 0
				
				while #enemies > 0 do
					table.remove(enemies,#enemies)
				end
				while #bullets > 0 do
					table.remove(bullets,#bullets)
				end
				while #items > 0 do
					table.remove(items,#items)
				end
				while #scores > 0 do
					table.remove(scores,#scores)
				end
			end
			
			print("CHECK FOR GAME END")
			-- **** CHECK FOR GAME END ****
			if player.lives <= 0 then 
				game.end_game = 1
				if player.score <= highscores[#highscores].score then
					game.highscore_entered_flag = true
				end
			end	

			print("UPDATE PREVIOUS SPACEKEY STATE")
			-- **** UPDATE THE PREVIOUS STATE TO CURRENT STATE ****
			game.spacekey_flag_previous = game.spacekey_flag
			game.spacebar_flag = false
		end
	else
		-- **** RESET ALL THE GAME VARIABLES ON GAME RESTART ****
		if game.spacebar_flag == true then
			game.end_game = 0
			game.enemy_flag = 0			
			game.spacebar_flag = false
			game.transition_flag = 1
			game.current_level = 1
			game.condition_count = 0
			game.background_index = math.random(#game.backgrounds)
			game.background_pos = -300
			game.background_rate = 1
			game.transition_ship_animation_rate = 50
			player.pos_y = game.screen_h + player.img_offset_h
			player.pos_x = game.screen_w / 2
			player.can_collide = 0
			player.level_hits = 0
			player.level_shots = 0
			player.game_hits = 0
			player.game_shots = 0
			player.collide_reset_timer = 0
			player.lives = 3
			player.score = 0
			player.bullet_mod = 1
			player.anim_type = "normal"
			
			for i = 1, #enemy_data do
				enemy_data[i].level_kills = 0
				enemy_data[i].game_kills = 0
			end			
			while #enemies > 0 do
				table.remove(enemies,#enemies)
			end
			while #bullets > 0 do
				table.remove(bullets,#bullets)
			end
			while #items > 0 do
				table.remove(items,#items)
			end
			while #scores > 0 do
				table.remove(scores,#scores)
			end			
		end		
	end 
end

function love.draw()
	print("DRAW BACKGROUND")
	-- **** DRAW BACKGROUND ****
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(background.img[1],1,background.pos_1)
	love.graphics.draw(background.img[1],1,background.pos_2)
	if game.transition_flag ~= 1 then love.graphics.draw(game.backgrounds[game.background_index],1,game.background_pos) end
	love.graphics.draw(background.img[2],1,background.pos_3)
	love.graphics.draw(background.img[2],1,background.pos_4)

	if game.end_game == 0 then
		print("DRAW LEVEL TRANSITION")
		-- **** DRAW LEVEL TRANSITION ITEMS ****
		if game.transition_flag == 1 then
			love.graphics.printf("Space Janitor",1,50,game.screen_w,"center")
			love.graphics.printf("Cleaning up space, one level at a time.",1,150,game.screen_w,"center")
			
			for i = 1, #highscores do
				love.graphics.printf(highscores[i].name.." - "..highscores[i].score,1,250+i*50,game.screen_w,"center")
			end
			
			love.graphics.printf("Press SPACE to Start Playing!",1,game.screen_h-50,game.screen_w,"center")
		elseif game.transition_flag == 2 then
			love.graphics.draw(player.img[player.anim_current_frame],player.pos_x,player.pos_y,0,1,1,player.img_offset_w,player.img_offset_h)		
		elseif game.transition_flag == 3 then
			love.graphics.draw(player.img[player.anim_current_frame],player.pos_x,player.pos_y,0,1,1,player.img_offset_w,player.img_offset_h)		
		elseif game.transition_flag == 4 then
			love.graphics.setColor(0,0,0,100)
			love.graphics.rectangle("fill",100,100,game.screen_w-200,game.screen_h-200)
			love.graphics.setColor(255,255,255,255)
			love.graphics.rectangle("line",100,100,game.screen_w-200,game.screen_h-200)
			love.graphics.print("Shots: "..player.level_shots,120,120)
			love.graphics.print("Hits: "..player.level_hits,120,145)
			for i = 1, #enemy_data do
				love.graphics.print(enemy_data[i].name.." Kills: "..enemy_data[i].level_kills,120,145+(i*25))			
			end			
			love.graphics.printf("Press SPACE to Continue",1,game.screen_h-50,game.screen_w,"center")
		else
			print("DRAW ENEMIES")
			if #enemies ~= 0 then
				for i = 1, #enemies do
					love.graphics.draw(enemy_data[enemies[i].ref].img[enemies[i].anim_current_frame],enemies[i].x,enemies[i].y,math.rad(enemies[i].rotation),1,1,enemy_data[enemies[i].ref].img_offset_w,enemy_data[enemies[i].ref].img_offset_h)
				end
			end	
			print("DRAW PLAYER BULLETS")
			-- **** DRAW PLAYER BULLETS, ENEMY BULLETS, ENEMIES, ITEMS ****
			if #bullets ~= 0 then
				for i = 1, #bullets do
					love.graphics.draw(bullet_data[bullets[i].bullet_ref].img[bullets[i].anim_current_frame],bullets[i].x,bullets[i].y,0,1,1,bullet_data[bullets[i].bullet_ref].img_offset_w,bullet_data[bullets[i].bullet_ref].img_offset_h)
				end
			end	
			print("DRAW ITEMS")
			if #items ~= 0 then
				for i = 1, #items do
					love.graphics.draw(item_data[items[i].item_ref].img[items[i].anim_current_frame],items[i].x,items[i].y,0,1,1,item_data[items[i].item_ref].img_offset_w,item_data[items[i].item_ref].img_offset_h)
				end
			end
			print("DRAW PLAYER")
			-- **** DRAW PLAYER, UPDATE ALPHA IF INVULNERABLE ****
			if player.invisible == 0 then
				if player.can_collide == 0 and player.anim_type == "normal" then
					love.graphics.setColor(255,255,255,100)
				end
				love.graphics.draw(player.img[player.anim_current_frame],player.pos_x,player.pos_y,0,1,1,player.img_offset_w,player.img_offset_h)
			end
			print("DRAW SCORES")
			-- **** DRAW SCORES (THAT SCROLL UP THE SCREEN) ****
			if #scores ~= 0 then
				for i = 1, #scores do
					love.graphics.setColor(scores[i].colour)	
					love.graphics.printf(scores[i].text,scores[i].x,scores[i].y,0,"center")
				end
			end	
		end
		if game.transition_flag ~= 1 then
			-- **** DRAW GAME HUD ITEMS, PLAYER LIVES, SCORE ****
			print("DRAW HUD")
			love.graphics.setColor(0,0,0,128)
			love.graphics.rectangle("fill",0,0,game.screen_w,40)
			love.graphics.setColor(255,255,255,255)
			love.graphics.line(0,40,game.screen_w,40)
			
			love.graphics.draw(item_data[1].img[1],12,6,0,0.75,0.75)
			love.graphics.printf((player.bullet_mod*100).."%",15,6,100,"center")			

			for i = 1, player.lives do
				local x = 120 + ((i-1)* player.life_img_w)
				love.graphics.draw(player.life_img,x,15)
			end
			
			love.graphics.printf("Level: "..game.current_level, game.screen_w - 200, 6, 190, "right")	
			love.graphics.printf("Score: "..player.score, game.screen_w - 400, 6, 200, "right")	
		end
	else
		print("DRAW END GAME")
		-- **** DRAW END GAME STUFF ****
		if game.end_game == 1 then
			love.graphics.printf("Game Over!",1,50,game.screen_w,"center")
			love.graphics.setColor(0,0,0,100)
			love.graphics.rectangle("fill",100,100,game.screen_w-200,game.screen_h-200)
			love.graphics.setColor(255,255,255,255)
			love.graphics.rectangle("line",100,100,game.screen_w-200,game.screen_h-200)
			love.graphics.print("Level: "..game.current_level,120,120)
			love.graphics.print("Score: "..player.score,120,145)
			love.graphics.print("Shots: "..player.game_shots,120,170)
			love.graphics.print("Hits: "..player.game_hits,120,195)
			for i = 1, #enemy_data do
				love.graphics.print(enemy_data[i].name.." Kills: "..enemy_data[i].game_kills,120,195+(i*25))			
			end

			if player.score > highscores[#highscores].score and game.highscore_entered_flag == false then
				love.graphics.print("A New Highscore!",120,300)
				love.graphics.print("Enter Your Initials (then ENTER): "..game.highscore_name,120,325)
			end

			love.graphics.printf("Press SPACE to Start Again!",1,game.screen_h-50,game.screen_w,"center")
		end
	end
end
