local json = require("libs.dkjson")
local Grid = {}
Grid.__index = Grid

function Grid:new(cellSize, rule, randomDensity)
    local g = setmetatable({}, self)
    g.cellSize = cellSize
    g.cols = math.floor(love.graphics.getWidth() / cellSize)
    g.rows = math.floor((love.graphics.getHeight()-50) / cellSize)
    g.cells = {}
    g.locked = false
    g.rule = rule
    g.randomDensity = randomDensity or 0.2
    g:randomize()
    return g
end

function Grid:randomize()
    for y=1,self.rows do
        self.cells[y] = {}
        for x=1,self.cols do
            self.cells[y][x] = math.random() < self.randomDensity and 1 or 0
        end
    end
end

function Grid:clear()
    for y=1,self.rows do
        self.cells[y] = {}
        for x=1,self.cols do
            self.cells[y][x] = 0
        end
    end
end

function Grid:toggleCellAt(mx,my)
    if self.locked then return end
    local x = math.floor(mx/self.cellSize)+1
    local y = math.floor(my/self.cellSize)+1
    if x>=1 and x<=self.cols and y>=1 and y<=self.rows then
        self.cells[y][x] = 1 - self.cells[y][x]
    end
end

function Grid:update()
    local newCells = {}
    for y=1,self.rows do
        newCells[y] = {}
        for x=1,self.cols do
            newCells[y][x] = self.rule.updateCell(self.cells, x, y, self.cells[y][x])
        end
    end
    self.cells = newCells
end

function Grid:draw()
    for y=1,self.rows do
        for x=1,self.cols do
            if self.cells[y][x]==1 then
                love.graphics.rectangle("fill",
                    (x-1)*self.cellSize, (y-1)*self.cellSize,
                    self.cellSize, self.cellSize)
            end
        end
    end
end

function Grid:save(filename)
    love.filesystem.write(filename, json.encode(self.cells))
end

function Grid:load(filename)
    if not love.filesystem.getInfo(filename) then return end
    local data = love.filesystem.read(filename)
    local tbl = json.decode(data)
    if tbl then self.cells = tbl end
end

return Grid
