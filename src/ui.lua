local UI = {}
UI.__index = UI

function UI:new()
    local u = setmetatable({}, self)
    u.buttons = {}
    return u
end

function UI:addButton(label, x, y, w, h, callback)
    table.insert(self.buttons, {
        label = label, x = x, y = y, w = w, h = h,
        callback = callback,
        color = {1, 1, 1} -- default white
    })
end

function UI:draw()
    for _, b in ipairs(self.buttons) do
        -- fill
        love.graphics.setColor(b.color[1]*0.2, b.color[2]*0.2, b.color[3]*0.2)
        love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 6)
        -- border
        love.graphics.setColor(b.color)
        love.graphics.rectangle("line", b.x, b.y, b.w, b.h, 6)

        -- label
        local tw = love.graphics.getFont():getWidth(b.label)
        local th = love.graphics.getFont():getHeight()
        love.graphics.print(b.label, b.x + (b.w - tw)/2, b.y + (b.h - th)/2)
    end
end

function UI:mousepressed(mx, my)
    for _, b in ipairs(self.buttons) do
        if mx >= b.x and mx <= b.x+b.w and my >= b.y and my <= b.y+b.h then
            b.callback(b)
        end
    end
end

return UI
