-- life and war -- Siva Somayyajula & Patrick Do
state   = require 'hump.gamestate'
class   = require 'hump.class'
signal  = require 'hump.signal'
--message = require 'messages.MessageInABottle'
--import signals to dispatch events during gameplay
--use gui for deployments

DEAD, BLUE, RED = 0, 1, 2

local width, height = love.graphics.getDimensions()
if width < height then
	SIZE = width
else
	SIZE = height
end

SPACE = 20
N     = SIZE / SPACE

CBLACK, CBLUE,
CWHITE, CRED   = {49, 79, 79}, {100, 149, 237},
                 {255, 255, 255}, {205, 92, 92}

GAMESPEED = 5
score, t  = 0, 0

level = class {
	init = function(self)
		self.grid        = {}
		self.buffer      = {}
		self.paused      = false
		self.ghost       = false
		self.orientation = 3
		level:patterns()
		for x = 1, N do
			self.grid[x] = {}
			self.buffer[x] = {}
			for y = 1, N do
				self.grid[x][y]   = DEAD
				self.buffer[x][y] = DEAD
			end
		end
	end
}

function level:enter(previous)
	love.graphics.setBackgroundColor(unpack(CBLACK))
	love.graphics.clear()
	self.paused = true
end

function level:patterns()
	xs, ys, centerFactor = {}, {}, 2
	image = love.graphics.newImage("gfx/ghost.png")
	local stng, index = "", 1
	for line in love.filesystem.lines("gfx/patterns/glider.txt") do
		xs[#xs + 1] = tonumber(string.sub(line, string.find(line, ",") + 1)) 
		ys[#ys + 1] = tonumber(string.sub(line, 0, string.find(line, ",") - 1))
	end
	maxX = math.max(unpack(xs))
	maxY = math.max(unpack(ys))
end

function level:leave()
	--increment score and stuff
	--maybe change to signals
end

function level:update(dt)
	t = t + 1
	if self.paused or t < GAMESPEED then
		return
	end
	t = 0
	function clear()
		for x = 1, N do
			for y = 1, N do
				self.buffer[x][y] = self.grid[x][y]
			end
		end
	end
	function copy_buffer()
		for x = 1, N do
			for y = 1, N do
				self.grid[x][y] = self.buffer[x][y]
			end
		end
	end
	function get(x, y)
		if x < 1 then
			x = N
		elseif x > N then
			x = 1
		end
		if y < 1 then
			y = N
		elseif y > N then
			y = 1
		end
		return self.grid[x][y]
	end
	clear()
	for x = 1, N do
		for y = 1, N do
			local neighbors = {}
			for i = -1, 1 do
				for j = -1, 1 do
					if not (i == 0 and j == 0) then
						neighbors[table.maxn(neighbors) + 1] = get(x + i, y + j)
					end
				end
			end
			local sumBlue, sumRed = 0, 0
			for sum = 1, table.maxn(neighbors) do
				if neighbors[sum] == BLUE then
					sumBlue = sumBlue + 1
				elseif neighbors[sum] == RED then
					sumRed  = sumRed  + 1
				end
			end
			if self.grid[x][y] ~= DEAD and
			  (sumBlue + sumRed < 2     or
			   sumBlue + sumRed > 3)    then
				self.buffer[x][y] = DEAD
			elseif sumBlue + sumRed == 3 and self.grid[x][y] == DEAD then
				if sumBlue > 1 then
					self.buffer[x][y] = BLUE
				elseif sumRed > 1 then
					self.buffer[x][y] = RED
				end
			end
		end
	end
	copy_buffer()
end

function level:toPixel(c)
	return SPACE * (c - 1)
end

function level:toCell(p)
	return math.floor((p + 1) / SPACE + 1)
end

function level:draw()
	function ghosting()
		local x, y = love.mouse.getPosition()
		if x < level:toPixel(centerFactor) then
			x = level:toPixel(centerFactor)
		end
		if y < level:toPixel(centerFactor) then
			y = level:toPixel(centerFactor)
		end
		if x > SIZE - level:toPixel(maxX) then
			x = SIZE - level:toPixel(maxX)
		end
		if y > SIZE - level:toPixel(maxY) then
			y = SIZE - level:toPixel(maxY)
		end
		local txs, tys = {}, {}
		for n = 1, #xs do
			if self.orientation == 0 then
				txs[n] = xs[n]
				tys[n] = ys[n]
			elseif self.orientation == 2 then
				txs[n] = maxX - xs[n]
				tys[n] = maxY - ys[n]
			elseif self.orientation == 1 then
				txs[n] = maxX - xs[n]
				tys[n] = ys[n]
			elseif self.orientation == 3 then
				txs[n] = xs[n]
				tys[n] = maxY - ys[n]
			end
			local ghostx = txs[n] + level:toCell(x)
			local ghosty = tys[n] + level:toCell(y)
			love.graphics.draw(image, level:toPixel(ghostx), level:toPixel(ghosty))
		end
	end
	for x = 1, N do
		for y = 1, N do
			if self.grid[x][y] == BLUE then
				love.graphics.setColor(unpack(CBLUE))
			elseif self.grid[x][y] == RED then
				love.graphics.setColor(unpack(CRED))
			else
				love.graphics.setColor(unpack(CBLACK))
			end
			love.graphics.rectangle("fill",
				level:toPixel(y), level:toPixel(x), SPACE, SPACE)
		end
	end
	love.graphics.setColor(unpack(CWHITE))
	if ghost then
		ghosting()
	end
	for x = 0, SIZE, SPACE do
		love.graphics.line(x, 0, x, SIZE)
	end
	for y = 0, SIZE, SPACE do
		love.graphics.line(0, y, SIZE, y)
	end
end

function level:focus(f)
	self.paused = not f
end

function level:keyreleased(key)
	--IMPORTANT: levelcreator.txt is in a path like this one C:/Users/Patrick/AppData/Roaming/LOVE/life5-master/levelwriter.txt
	--If you want to save a "level" for use later, better go there and copy and paste it into a new text file. 
	--https://www.love2d.org/forums/viewtopic.php?f=4&p=157187
	function savemap()
		local stng = ""
		for x = 1, N do
				for y = 1, N do
					if self.grid[x][y] ~= DEAD then
						stng = stng .. tostring(x) .. ", " .. tostring(y) .. "\r\n"
					end
				end
		end
		love.filesystem.write("levelcreator.txt", stng) 
	end
	function draw_map()
		for line in love.filesystem.lines("enemies.ini") do
   			self.grid[tonumber(string.sub(line, 0, string.find(line, ",") - 1))]
   				[tonumber(string.sub(line, string.find(line, ",") + 1))] = RED
		end
	end
	function destroy_map()
		for x = 1, N do
			for y = 1, N do
				self.grid[x][y] = DEAD
			end
		end
	end
	if key == ' ' then
		self.paused = not self.paused
	elseif key == 's' then
		save_map()
	elseif key == 'd' then
		draw_map()
	elseif key == 'c' then
		destroy_map()
	elseif key == 'g' then
		ghost = not ghost
	elseif key == 'left' or key == 'right' then
		self.orientation = (self.orientation + 1) % 4
	end
end

function level:mousereleased(x, y, button)
	local yy, xx = level:toCell(x), level:toCell(y)
	if yy <= N and xx <= N and
	   yy >= 1 and xx >= 1 then
		if self.grid[xx][yy] ~= DEAD then
			self.grid[xx][yy] = DEAD
		elseif button == 'l' then
			self.grid[xx][yy] = BLUE
		else
			self.grid[xx][yy] = RED
		end
	end
end

local menu = {}

local level1,
      level2,
      level3,
      level4,
      level5  =
                level(),
                level(),
                level(),
                level(),
                level()

function menu:enter(previous)
end

function menu:draw()
end

function menu:keyreleased(key)
	if key == ' ' then
		state.switch(level1)
	end
end

function love.load()
	state.registerEvents()
	state.switch(menu)
end

function love.quit()
end
