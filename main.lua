local config = require("conf")
local rule = require("rules." .. config.rule)
local Grid = require("src.grid")
local UI = require("src.ui")

local grid = Grid:new(10, rule, config.randomDensity)
local ui = UI
ui:init(grid)

function love.load()
    love.graphics.setBackgroundColor(0,0,0)
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(love.graphics.newFont(14))
end

function love.update(dt)
    ui:update(dt)
end

function love.draw()
    ui:draw()
end

function love.mousepressed(x,y,button)
    ui:mousepressed(x,y,button)
end

function love.keypressed(key)
    ui:keypressed(key)
end
