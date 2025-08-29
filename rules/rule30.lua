-- rules/rule30.lua
local rule30 = {}


rule30.numStates = 2
rule30.colormap = {
    [0] = {0, 0, 0},    -- dead -> black
    [1] = {1, 1, 1}     -- alive -> white
}

-- Rule 30 mapping table (index = 3-bit neighborhood as binary)
-- Example: 111 -> 0, 110 -> 0, 101 -> 0, 100 -> 1, 011 -> 1, 010 -> 1, 001 -> 1, 000 -> 0
local mapping = {
    ["111"] = 0,
    ["110"] = 0,
    ["101"] = 0,
    ["100"] = 1,
    ["011"] = 1,
    ["010"] = 1,
    ["001"] = 1,
    ["000"] = 0
}

function rule30.updateCell(grid, x, y, state)
    local rows, cols = #grid, #grid[1]

    -- Rule 30 is inherently 1D, but we’ll evolve it downward row by row
    -- Each row is based on the row above
    if y == 1 then
        -- First row stays unchanged (initial condition)
        return grid[y][x]
    end

    -- Get the row above
    local left  = (x > 1)      and grid[y-1][x-1] or 0
    local mid   = grid[y-1][x]
    local right = (x < cols)   and grid[y-1][x+1] or 0

    local key = tostring(left) .. tostring(mid) .. tostring(right)
    return mapping[key]
end

rule30.colors = {
    [0] = {1, 1, 1}, -- white for dead
    [1] = {0, 0, 0}, -- black for alive
}

return rule30
