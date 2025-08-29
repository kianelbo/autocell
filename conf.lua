function love.conf(t)
    t.identity = "cellular_automata_engine"
    t.window.title = "AutoCell"
    t.window.width = 800
    t.window.height = 600
end

return {
    -- pick which rule to load
    rule = "conway",
    -- initial random density
    randomDensity = 0.1,
    -- size of each cell in pixels (reduce to have a larger grid)
    cellSize = 10
}
