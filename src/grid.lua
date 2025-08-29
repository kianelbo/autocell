local Grid = {}
Grid.__index = Grid

function Grid:new(cols, rows, cellSize)
    local g = setmetatable({}, self)
    g.cols = cols
    g.rows = rows
    g.cellSize = cellSize
    g.cells = {}
    g.locked = false
    g:randomize()
    return g
end

function Grid:randomize()
    for x = 1, self.cols do
        self.cells[x] = {}
        for y = 1, self.rows do
            self.cells[x][y] = math.random() > 0.8 and 1 or 0
        end
    end
end

function Grid:clear()
    for x = 1, self.cols do
        self.cells[x] = {}
        for y = 1, self.rows do
            self.cells[x][y] = 0
        end
    end
end

function Grid:toggleCellAt(mx, my)
    if self.locked then return end
    local x = math.floor(mx / self.cellSize) + 1
    local y = math.floor(my / self.cellSize) + 1
    if x >= 1 and x <= self.cols and y >= 1 and y <= self.rows then
        self.cells[x][y] = 1 - self.cells[x][y]
    end
end

function Grid:save(filename)
    local data = {}
    for x = 1, self.cols do
        data[x] = {}
        for y = 1, self.rows do
            data[x][y] = self.cells[x][y]
        end
    end
    love.filesystem.write(filename, love.filesystem.newFileData(
        require("libs.dkjson").encode(data), filename
    ))
end

function Grid:load(filename)
    if not love.filesystem.getInfo(filename) then return end
    local contents = love.filesystem.read(filename)
    local json = require("libs.dkjson")
    local data = json.decode(contents)
    if data then
        self.cells = data
    end
end

-- drawing
function Grid:draw()
    for x = 1, self.cols do
        for y = 1, self.rows do
            if self.cells[x][y] == 1 then
                love.graphics.rectangle("fill", 
                    (x-1)*self.cellSize, 
                    (y-1)*self.cellSize, 
                    self.cellSize, 
                    self.cellSize
                )
            end
        end
    end
end

-- update step
function Grid:update()
    local newCells = {}
    for x = 1, self.cols do
        newCells[x] = {}
        for y = 1, self.rows do
            local neighbors = self:countNeighbors(x, y)
            local state = self.cells[x][y]
            if state == 1 then
                newCells[x][y] = (neighbors == 2 or neighbors == 3) and 1 or 0
            else
                newCells[x][y] = (neighbors == 3) and 1 or 0
            end
        end
    end
    self.cells = newCells
end

function Grid:countNeighbors(x, y)
    local total = 0
    for dx = -1, 1 do
        for dy = -1, 1 do
            if not (dx == 0 and dy == 0) then
                local nx, ny = x+dx, y+dy
                if nx >= 1 and nx <= self.cols and ny >= 1 and ny <= self.rows then
                    total = total + self.cells[nx][ny]
                end
            end
        end
    end
    return total
end

return Grid
