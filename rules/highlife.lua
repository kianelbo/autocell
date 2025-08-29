local highlife = {}

highlife.numStates = 2
highlife.colormap = {
    [0] = {0, 0, 0},
    [1] = {0.7, 0.9, 0.2}  -- olive color
}

function highlife.updateCell(grid, x, y, state)
    local rows, cols = #grid, #grid[1]
    local neighbors = 0
    for dy = -1,1 do
        for dx = -1,1 do
            if not (dx==0 and dy==0) then
                local nx, ny = x+dx, y+dy
                if nx>=1 and nx<=cols and ny>=1 and ny<=rows then
                    neighbors = neighbors + grid[ny][nx]
                end
            end
        end
    end
    if state==1 then
        return (neighbors==2 or neighbors==3) and 1 or 0
    else
        return (neighbors==3 or neighbors==6) and 1 or 0
    end
end

return highlife
