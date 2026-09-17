local daynight = {}

daynight.numStates = 2
daynight.colormap = {
    [0] = {0, 0, 0},    -- dead -> black
    [1] = {1, 1, 1}     -- alive -> white
}

-- B3678 / S34678
function daynight.updateCell(grid, x, y, state)
    local rows, cols = #grid, #grid[1]
    local neighbors = 0
    for dy = -1,1 do
        for dx = -1,1 do
            if not (dx == 0 and dy == 0) then
                local nx, ny = x+dx, y+dy
                if nx>=1 and nx<=cols and ny>=1 and ny<=rows then
                    neighbors = neighbors + grid[ny][nx]
                end
            end
        end
    end

    if state == 1 then
        return (neighbors == 3
            or neighbors == 4
            or neighbors == 6
            or neighbors == 7
            or neighbors == 8) and 1 or 0
    else
        return (neighbors == 3
            or neighbors == 6
            or neighbors == 7
            or neighbors == 8) and 1 or 0
    end
end

return daynight
