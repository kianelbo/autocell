local wireworld = {}

wireworld.numStates = 4
wireworld.colormap = {
    [0] = {0,   0,   0},   -- empty  -> black
    [1] = {0,   0.5, 1},   -- head   -> blue
    [2] = {1,   0,   0},   -- tail   -> red
    [3] = {1,   1,   0},   -- wire   -> yellow
}

function wireworld.updateCell(grid, x, y, state)
    local rows, cols = #grid, #grid[1]

    if state == 0 then
        -- Empty stays empty
        return 0
    elseif state == 1 then
        -- Electron head -> electron tail
        return 2
    elseif state == 2 then
        -- Electron tail -> conductor
        return 3
    else
        -- Conductor: becomes head if 1 or 2 neighboring heads, else stays conductor
        local heads = 0
        for dy = -1, 1 do
            for dx = -1, 1 do
                if not (dx == 0 and dy == 0) then
                    local nx, ny = x + dx, y + dy
                    if nx >= 1 and nx <= cols and ny >= 1 and ny <= rows then
                        if grid[ny][nx] == 1 then
                            heads = heads + 1
                            -- Small micro-optimization: early exit if > 2
                            if heads > 2 then
                                -- More than 2 cannot satisfy "exactly 1 or 2"
                                return 3
                            end
                        end
                    end
                end
            end
        end
        return (heads == 1 or heads == 2) and 1 or 3
    end
end

return wireworld
