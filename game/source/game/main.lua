MAP_W = 1024
MAP_H = 1024
WINDOW_W = 1000
WINDOW_H = 600

do 
    function print_to_debug(text)
        love.graphics.setColor(0,1,0)
        love.graphics.printf(text, 0, WINDOW_H-50, WINDOW_W)
    end

    function love.load()
        -- image = love.graphics.newImage("assets/love-ball.png")

        love.window.setMode(WINDOW_W, WINDOW_H)

        BUFFER = require("string.buffer")

        MAP = {}
        for i=1,MAP_W do
            MAP[i] = {}     -- create x
            for j=1,MAP_H do
                MAP[i][j] = 0
            end
        end

        SAVE = {MAP, 5, "aac"}

        local encoded_tbl = BUFFER.encode(SAVE)
        
        --love.data.encode("base64", "string", str))

        SAVE = BUFFER.decode(encoded_tbl)

        -- love.graphics.setColor(0,1,0)
    end
    
    function love.draw()
        --  love.graphics.draw(image, 400, 300)
        print_to_debug(tostring(SAVE[1][1])..", "..tostring(SAVE[2])..", "..tostring(SAVE[3]))
    end
end
