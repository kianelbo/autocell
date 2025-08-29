local Colors = require("src.colors")
local Grid = require("src.grid")
local UI = {}
UI.__index = UI

local buttons = {}
local grid
local autoplay = false
local timer, interval = 0, 0.1
local playBtn, lockBtn

local function toggleAutoplay(btn)
    autoplay = not autoplay
    btn.label = autoplay and "Pause" or "Play"
    btn.color = autoplay and Colors.Red or Colors.White         -- red when paused
end

local function toggleLock(btn)
    grid.locked = not grid.locked
    btn.color = grid.locked and Colors.Golden or Colors.White   -- golden when locked
end

function UI:init(g)
    grid = g
    buttons = {}
    local bw,bh = 100,30
    local y = love.graphics.getHeight()-bh-10

    local function addBtn(label, callback)
        table.insert(buttons,{label=label, x=10+(#buttons)*(bw+10), y=y, w=bw,h=bh, callback=callback, color=Colors.White})
        return #buttons
    end

    addBtn("Save", function() grid:save("board.json") end)
    addBtn("Load", function() grid:load("board.json") end)
    addBtn("Reset", function() grid:clear() end)
    addBtn("Randomize", function() grid:randomize() end)
    addBtn("Step", function() grid:update() end)

    playBtn = addBtn("Play", toggleAutoplay)
    lockBtn = addBtn("Lock", toggleLock)
end

function UI:update(dt)
    if autoplay then
        timer = timer + dt
        if timer>=interval then
            grid:update()
            timer=0
        end
    end
end

function UI:draw()
    love.graphics.setColor(Colors.White)
    grid:draw()
    for _,b in ipairs(buttons) do
        love.graphics.setColor(b.color[1]*0.2,b.color[2]*0.2,b.color[3]*0.2)
        love.graphics.rectangle("fill",b.x,b.y,b.w,b.h,6)
        love.graphics.setColor(b.color)
        love.graphics.rectangle("line",b.x,b.y,b.w,b.h,6)
        local tw = love.graphics.getFont():getWidth(b.label)
        local th = love.graphics.getFont():getHeight()
        love.graphics.print(b.label, b.x+(b.w-tw)/2, b.y+(b.h-th)/2)
    end
end

function UI:mousepressed(x,y,button)
    if y > love.graphics.getHeight()-50 then
        for _,b in ipairs(buttons) do
            if x>=b.x and x<=b.x+b.w and y>=b.y and y<=b.y+b.h then
                b.callback(b)
            end
        end
    else
        if button==1 then grid:toggleCellAt(x,y) end
    end
end

function UI:keypressed(key)
    local map = {
        s = function() grid:save("board.json") end,
        l = function() grid:load("board.json") end,
        c = function() grid:clear() end,
        r = function() grid:randomize() end,
        n = function() grid:update() end,
        space = function() toggleAutoplay(buttons[playBtn]) end,
        k = function() toggleLock(buttons[lockBtn]) end
    }
    if map[key] then map[key]() end
end

return UI
