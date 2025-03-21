MAP_W = 1024
MAP_H = 1024
WINDOW_W = 1000
WINDOW_H = 600
SAVEFILE_NAME = "savefile"

do 
    local love = require("love")
    local lume = require("lib.lume")
    
    local function print_to_debug(text)
        love.graphics.setColor(0,0,0)
        love.graphics.printf(text, 10+1, WINDOW_H-45, WINDOW_W)
        love.graphics.printf(text, 10-1, WINDOW_H-45, WINDOW_W)
        love.graphics.printf(text, 10, WINDOW_H-45+1, WINDOW_W)
        love.graphics.printf(text, 10, WINDOW_H-45-1, WINDOW_W)

        love.graphics.setColor(0,1,0)
        love.graphics.printf(text, 10, WINDOW_H-45, WINDOW_W)
    end

    function love.load()
        -- image = love.graphics.newImage("assets/love-ball.png")

        love.window.setMode(WINDOW_W, WINDOW_H)

        local buffer = require("string.buffer")

        local map = {}
        for i=1,MAP_W do
            map[i] = {}     -- create x
            for j=1,MAP_H do
                map[i][j] = 0
            end
        end

        Save = {map, 5, "aac"}

        --[[ local file = assert(io.open(SAVEFILE_NAME, "w"))
        file:write(serialized)
        file:close()

        local file = assert(io.open(SAVEFILE_NAME, "r"))
        serialized = io.read()
        file:close() ]]--
    end

    function love.draw()
        --  love.graphics.draw(image, 400, 300)
        print_to_debug(tostring(tostring(Save[1][2][5]))..", "..tostring(Save[2])..", "..tostring(Save[3]))
    end
end
