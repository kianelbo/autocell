local Colors = require("src.colors")
local Grid = require("src.grid")
local UI = {}
UI.__index = UI

local buttons = {}
local grid
local autoplay = false
local timer, interval = 0, 0.1
local playBtn, lockBtn

local saveBtnIdx, loadBtnIdx, clearBtnIdx

local lastCellX, lastCellY = nil, nil

-- Temporary button text timers
local function setTemporaryText(btn, text, duration)
    btn._tempOriginal = btn.label
    btn.label = text
    btn._tempTimer = duration or 2
end

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

    saveBtnIdx = addBtn("Save", function(btn)
        grid:save("board.json")
        setTemporaryText(btn, "Saved!", 2)
    end)
    loadBtnIdx = addBtn("Load", function(btn)
        grid:load("board.json")
        setTemporaryText(btn, "Loaded!", 2)
    end)
    clearBtnIdx = addBtn("Clear", function(btn)
        grid:clear()
        setTemporaryText(btn, "Cleared!", 2)
    end)
    addBtn("Randomize", function(btn) grid:randomize() end)
    addBtn("Step", function(btn) grid:update() end)

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

    -- update temporary button text timers
    for _,b in ipairs(buttons) do
        if b._tempTimer then
            b._tempTimer = b._tempTimer - dt
            if b._tempTimer <= 0 then
                b.label = b._tempOriginal
                b._tempTimer = nil
                b._tempOriginal = nil
            end
        end
    end

    -- handle drag painting
    if love.mouse.isDown(1) then
        local mx, my = love.mouse.getPosition()
        if my < love.graphics.getHeight() - 50 then -- only grid area
            local cellX = math.floor(mx / grid.cellSize) + 1
            local cellY = math.floor(my / grid.cellSize) + 1
            if cellX ~= lastCellX or cellY ~= lastCellY then
                grid:toggleCellAt(mx, my)
                lastCellX, lastCellY = cellX, cellY
            end
        else
            lastCellX, lastCellY = nil, nil -- over button area, don't paint
        end
    else
        lastCellX, lastCellY = nil, nil -- button released, stop painting
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

function UI:mousepressed(x, y, button)
    if button == 1 then
        if y > love.graphics.getHeight() - 50 then
            -- clicked on buttons
            for _, b in ipairs(buttons) do
                if x>=b.x and x<=b.x+b.w and y>=b.y and y<=b.y+b.h then
                    b.callback(b)
                end
            end
        else
            -- clicked on grid: toggle the first cell immediately
            grid:toggleCellAt(x, y)

            -- set lastCellX/Y so drag picking works properly
            lastCellX = math.floor(x / grid.cellSize) + 1
            lastCellY = math.floor(y / grid.cellSize) + 1
        end
    end
end


function UI:keypressed(key)
    local map = {
        s = function() 
            grid:save("board.json")
            setTemporaryText(buttons[saveBtnIdx], "Saved!", 2)
        end,
        l = function()
            grid:load("board.json")
            setTemporaryText(buttons[loadBtnIdx], "Loaded!", 2)
        end,
        c = function()
            grid:clear()
            setTemporaryText(buttons[clearBtnIdx], "Cleared!", 2)
        end,
        r = function() grid:randomize() end,
        n = function() grid:update() end,
        space = function() toggleAutoplay(buttons[playBtn]) end,
        k = function() toggleLock(buttons[lockBtn]) end
    }
    if map[key] then map[key]() end
end

return UI
