local cyclic = {}

cyclic.numStates = 5
cyclic.colormap = {
    [0] = {0, 0, 0},       -- black for state 0 (background)
    [1] = {1, 0, 0},       -- red
    [2] = {1, 0.5, 0},     -- orange
    [3] = {1, 1, 0},       -- yellow
    [4] = {0, 1, 0}        -- green
}

-- Follows same signature as other rules:
-- updateCell(grid, x, y, state) -> nextState
function cyclic.updateCell(grid, x, y, state)
    local rows, cols = #grid, #grid[1]
    local neighbors = 0
    local ns = cyclic.numStates
    local target = (state + 1) % ns

    for dy = -1, 1 do
        for dx = -1, 1 do
            if not (dx == 0 and dy == 0) then
                local nx, ny = x + dx, y + dy
                if nx >= 1 and nx <= cols and ny >= 1 and ny <= rows then
                    if grid[ny][nx] == target then
                        neighbors = neighbors + 1
                    end
                end
            end
        end
    end

    -- classic cyclic rule: become next state if any neighbor is the next state
    return (neighbors >= 1) and target or state
end

return cyclic
