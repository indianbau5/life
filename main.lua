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

GAMESPEED    = 5
score        = 0

level = class {
	init = function(self)
		self.grid   = {}
		self.buffer = {}
		self.paused = false
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
end

function level:leave()
	--increment score and stuff
	--maybe change to signals idk
	--we'll figure it out sooner or later
end

t = 0
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

function level:draw()
	function toPixel(c)
		return SPACE * (c - 1)
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
				toPixel(y), toPixel(x), SPACE, SPACE)
		end
	end
	love.graphics.setColor(unpack(CWHITE))
	for x = 0, SIZE, SPACE do
		love.graphics.line(x, 0, x, SIZE)
	end
	for y = 0, SIZE, SPACE do
		love.graphics.line(0, y, SIZE, y)
	end
end

function level:focus(f)
	--show pause message
	self.paused = not f
end

function level:keyreleased(key)
	if key == ' ' then
		--show pause message
		self.paused = not self.paused
	end
end

function level:mousereleased(x, y, button)
	function toCell(p)
		return math.floor((p + 1) / SPACE + 1)
	end
	local yy, xx = toCell(x), toCell(y)
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
	--cue start music
end

function menu:draw()
	--draw menu/title screen
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
	-- end screen
	-- inspirational message on how cellular automata
	-- is literally the best thing ever invented
	-- and how this game made your life better in every way
end
