local seeds = {}

seeds.numStates = 2
seeds.colormap = {
    [0] = {0, 0, 0},    -- dead -> black
    [1] = {1, 0, 0}     -- alive -> red
}

function seeds.updateCell(grid, x, y, state)
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

    if state==0 then
        -- Birth if exactly 2 neighbors
        return neighbors==2 and 1 or 0
    else
        -- All live cells die
        return 0
    end
end

return seeds
