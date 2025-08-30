local Colors = require("src.colors")
local json = require("libs.dkjson")
local Grid = {}
Grid.__index = Grid

function Grid:new(cellSize, rule, randomDensity)
    local g = setmetatable({}, self)
    g.cellSize = cellSize
    g.cols = math.floor(love.graphics.getWidth() / cellSize)
    g.rows = math.floor((love.graphics.getHeight() - 50) / cellSize)
    g.cells = {}
    g.locked = false
    g.rule = rule
    g.randomDensity = randomDensity or 0.2
    g:randomize()
    return g
end

-- if rule.numStates > 2, pick state 0 with prob (1-density), otherwise pick uniform in 1..numStates-1
function Grid:randomize()
    local ns = self.rule.numStates or 2
    local density = self.randomDensity
    for y = 1, self.rows do
        self.cells[y] = {}
        for x = 1, self.cols do
            if ns <= 2 then
                self.cells[y][x] = (math.random() < density) and 1 or 0
            else
                if math.random() < density then
                    -- pick a non-zero state uniformly
                    self.cells[y][x] = math.random(1, ns - 1)
                else
                    self.cells[y][x] = 0
                end
            end
        end
    end
end

function Grid:clear()
    for y = 1, self.rows do
        self.cells[y] = {}
        for x = 1, self.cols do
            self.cells[y][x] = 0
        end
    end
end

function Grid:toggleCellAt(mx, my)
    if self.locked then return end
    local x = math.floor(mx / self.cellSize) + 1
    local y = math.floor(my / self.cellSize) + 1
    if x >= 1 and x <= self.cols and y >= 1 and y <= self.rows then
        -- toggle between 0 and 1 for simplicity on click; you could cycle states instead
        if self.rule.numStates and self.rule.numStates > 2 then
            -- cycle state on click: 0 -> 1 -> 2 -> ... -> 0
            local cur = self.cells[y][x] or 0
            local ns = self.rule.numStates
            self.cells[y][x] = (cur + 1) % ns
        else
            self.cells[y][x] = 1 - (self.cells[y][x] or 0)
        end
    end
end

function Grid:update()
    local newCells = {}
    for y = 1, self.rows do
        newCells[y] = {}
        for x = 1, self.cols do
            newCells[y][x] = self.rule.updateCell(self.cells, x, y, self.cells[y][x] or 0)
        end
    end
    self.cells = newCells
end

function Grid:draw()
    for y = 1, self.rows do
        for x = 1, self.cols do
            local state = self.cells[y][x] or 0
            local color = self.rule.colormap[state] or Colors.White
            love.graphics.setColor(color)
            love.graphics.rectangle("fill",
                (x-1)*self.cellSize,
                (y-1)*self.cellSize,
                self.cellSize, self.cellSize)
        end
    end
    -- reset color to white for UI drawing elsewhere
    love.graphics.setColor(1,1,1)
end

function Grid:save(filename)
    local encoded = json.encode(self.cells)
    love.filesystem.write(filename, encoded)
end

function Grid:load(filename)
    if not love.filesystem.getInfo(filename) then return end
    local contents = love.filesystem.read(filename)
    local tbl, pos, err = json.decode(contents)
    if not tbl then
        print("JSON decode error:", err)
        return
    end
    self.cells = tbl
    -- adjust rows/cols if saved grid has different size (optional)
    self.rows = #self.cells
    self.cols = (self.cells[1] and #self.cells[1]) or 0
end

return Grid
