--[[
    Life, by Siva Somayyajula
             Patrick Do
             Shrikant Mishra
             Peter Zhao
]]--

state   = require 'hump.gamestate'
class   = require 'hump.class'
signal  = require 'hump.signal'
--message = require 'message.MessageInABottle'
--IDEA: Use signals to check if user lost/won and same for AI?

DEAD, ALIVE = 0, 1
N   , SIZE  = 100, 1000
SPACE       = SIZE / N
score       = 0

level = class {
	init = function(self)
		self.grid   = {}
		self.paused = false
		--TODO: replace with map from ctor
		for x = 1, N do
			self.grid[x] = {}
			for y = 1, N do
				self.grid[x][y] = DEAD
			end
		end
	end
}

function level:enter(previous)
	love.graphics.setBackgroundColor(255, 255, 255)
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
	if self.paused or t < 20 then
		return
	end
	t = 0
	function cell(x, y)
		if x > N or y > N or x < 1 or y < 1 then
			return DEAD
		else
			return self.grid[x][y]
		end
	end
	for x = 1, N do
		for y = 1, N do
			local neighbors = cell(x + 1, y    ) +
			                  cell(x - 1, y    ) +
			                  cell(x    , y + 1) +
			                  cell(x    , y - 1) +
			                  cell(x + 1, y + 1) +
			                  cell(x + 1, y - 1) +
			                  cell(x - 1, y + 1) +
			                  cell(x - 1, y - 1)
			if self.grid[x][y] == ALIVE and
			  (neighbors < 2       or
			   neighbors > 3)      then
				self.grid[x][y] = DEAD
			elseif neighbors == 3 then
				self.grid[x][y] = ALIVE
			end
		end
	end
end

function level:draw()
	function toPixel(c)
		return SPACE * (c - 1)
	end
	for x = 1, N do
		for y = 1, N do
			if self.grid[x][y] == ALIVE then
				love.graphics.setColor(0, 0, 1)
			else
				love.graphics.setColor(255, 255, 255)
			end
			love.graphics.rectangle("fill",
				toPixel(y), toPixel(x), SPACE, SPACE)
		end
	end
	love.graphics.setColor(0, 0, 0)
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
	if button == 'l' then
		local yy, xx = toCell(x), toCell(y)
		if yy <= N and xx <= N and
		   yy >= 1 and xx >= 1 then
			self.grid[xx][yy] = ALIVE - self.grid[xx][yy]
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

function love.update(dt)
	state.update(dt)
end

function love.draw()
	state.draw()
end

function love.mousereleased(x, y, button)
	state.mousepressed(x, y, button)
end

function love.keyreleased(key)
	state.keypressed(key)
end

function love.focus(f)
	state.focus(f)
end

function love.quit()
	-- end screen
	-- inspirational message on how cellular automata
	-- is literally the best thing ever invented
	-- and how this game made your life better in every way
end
