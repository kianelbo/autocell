function love.conf(t)
    t.identity = "cellular_automata_engine"
    t.window.title = "AutoCell"
    t.window.width = 800
    t.window.height = 600
end

return {
    -- pick which rule to load
    rule = "conway",
    randomDensity = 0.1
}
