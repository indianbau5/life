-- Life, by Siva Somayyajula, Patrick Do
--       and some freshman and sophomore
--       whose names escape me

-- TODO: Actual game
-- Use HUMP framework for game states/levels and player progression

-- State/class libraries
state = require 'hump.gamestate'
class = require 'hump.class'

-- Cell states
DEAD, ALIVE = 0, 1

-- The grid and its size
grid, N = {}, 10

-- Height/width of grid
-- and pixel spacing
SIZE  = 500
SPACE = SIZE / N

-- Game state
paused = false

function love.load()
	-- Setup the grid
	for x = 1, N do
		grid[x] = {}
		for y = 1, N do
			grid[x][y] = DEAD
		end
	end
	love.graphics.setBackgroundColor(255, 255, 255)
end

function love.draw()
	-- Converts grid coordinate (cell) to pixel
	function toPixel(c)
		return SPACE * (c - 1)
	end
	-- Render grid
	for x = 1, N do
		for y = 1, N do
			if grid[x][y] == ALIVE then
				love.graphics.setColor(0, 0, 0)
			else
				love.graphics.setColor(255, 255, 255)
			end
			-- Oddly enough, you have to switch x and y
			-- to draw the cell. Same for converting back
			love.graphics.rectangle("fill",
				toPixel(y), toPixel(x), SPACE, SPACE)
		end
	end
	-- Draw grid lines
	love.graphics.setColor(0, 0, 0)
	for x = 0, SIZE, SPACE do
		love.graphics.line(x, 0, x, SIZE)
	end
	for y = 0, SIZE, SPACE do
		love.graphics.line(0, y, SIZE, y)
	end
end

-- The actual life algorithm
-- Ignore dt, it's just time passed
function love.update(dt)
	if paused then
		return
	end
	-- Retrieves cell from matrix with bounds checking
	function cell(x, y)
		if x > N or y > N or x < 1 or y < 1 then
			return DEAD
		else
			return grid[x][y]
		end
	end
	for x = 1, N do
		for y = 1, N do
			-- Moore neighborhood
			local neighbors = cell(x + 1, y    ) +
			                  cell(x - 1, y    ) +
			                  cell(x    , y + 1) +
			                  cell(x    , y - 1) +
			                  cell(x + 1, y + 1) +
			                  cell(x + 1, y - 1) +
			                  cell(x - 1, y + 1) +
			                  cell(x - 1, y - 1)
			-- PATRICK PLS FIX
			-- We play by da rules mang
			living = grid[x][y] == ALIVE
			if living and (neighbors < 2  or
						   neighbors > 3) then
				grid[x][y] = DEAD
			elseif neighbors == 3 then
				grid[x][y] = ALIVE
			end
		end
	end
end

-- Allows player to toggle cell states on grid
function love.mousepressed(x, y, button)
	-- Converts pixel to grid coordinate (cell)
	function toCell(p)
		return math.floor((p + 1) / SPACE + 1)
	end
	if button == 'l' then
		local yy, xx = toCell(x), toCell(y)
		grid[xx][yy] = ALIVE - grid[xx][yy]
	end
end

-- Allows player to pause or unpause
-- the game on spacebar press

-- It suspends the algorithm, but
-- allows the user to still toggle cells
function love.keypressed(key)
	if key == ' ' then
		paused = not paused
	end
end
