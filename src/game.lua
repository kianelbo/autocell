local Grid = require("src.grid")
local UI = require("src.ui")

local Game = {}
Game.__index = Game

function Game:new(cellSize)
    local g = setmetatable({}, self)
    local cols = math.floor(love.graphics.getWidth() / cellSize)
    local rows = math.floor((love.graphics.getHeight()-50) / cellSize)
    g.grid = Grid:new(cols, rows, cellSize)
    g.timer = 0
    g.interval = 0.1
    g.autoplay = false

    g.ui = UI:new()
    local bw, bh = 100, 30
    local y = love.graphics.getHeight() - bh - 10

    g.ui:addButton("Save",       10 + 0*(bw+10), y, bw, bh, function() g.grid:save("board.json") end)
    g.ui:addButton("Load",       10 + 1*(bw+10), y, bw, bh, function() g.grid:load("board.json") end)
    g.ui:addButton("Reset",      10 + 2*(bw+10), y, bw, bh, function() g.grid:clear() end)
    g.ui:addButton("Randomize",  10 + 3*(bw+10), y, bw, bh, function() g.grid:randomize() end)
    g.ui:addButton("Step",       10 + 4*(bw+10), y, bw, bh, function() g.grid:update() end)

    -- Play/Pause button with dynamic label
    g.playBtn = { index = #g.ui.buttons+1 }
    g.ui:addButton("Play", 10 + 5*(bw+10), y, bw, bh, function(btn)
        g.autoplay = not g.autoplay
        btn.label = g.autoplay and "Pause" or "Play"
    end)

    -- Lock button with dynamic color
    g.lockBtn = { index = #g.ui.buttons+1 }
    g.ui:addButton("Lock", 10 + 6*(bw+10), y, bw, bh, function(btn)
        g.grid.locked = not g.grid.locked
        if g.grid.locked then
            btn.color = {1, 0.84, 0} -- golden
        else
            btn.color = {1, 1, 1}   -- white
        end
    end)

    return g
end

function Game:update(dt)
    if self.autoplay then
        self.timer = self.timer + dt
        if self.timer >= self.interval then
            self.grid:update()
            self.timer = 0
        end
    end
end

function Game:draw()
    love.graphics.setColor(1, 1, 1)
    self.grid:draw()
    self.ui:draw()
end

function Game:mousepressed(x, y, button)
    if y > love.graphics.getHeight() - 50 then
        self.ui:mousepressed(x, y)
    else
        if button == 1 then
            self.grid:toggleCellAt(x, y)
        end
    end
end

function Game:keypressed(key)
    if key == "s" then
        self.grid:save("board.json")
    elseif key == "l" then
        self.grid:load("board.json")
    elseif key == "c" then
        self.grid:clear()
    elseif key == "r" then
        self.grid:randomize()
    elseif key == "n" then
        self.grid:update()
    elseif key == "space" then
        self.autoplay = not self.autoplay
        self.ui.buttons[self.playBtn.index].label = self.autoplay and "Pause" or "Play"
    elseif key == "k" then
        self.grid.locked = not self.grid.locked
        self.ui.buttons[self.lockBtn.index].color = self.grid.locked and {1,0.84,0} or {1,1,1}
    end
end

return Game
