MAPW = 1024
MAPH = 1024
WINDOWW = 1000
WINDOWH = 800

do 
    function love.load()
        -- image = love.graphics.newImage("assets/love-ball.png")

        buffer = require("string.buffer")

        map = {}
        for i=1,MAPW do
            map[i] = {}     -- create x
            for j=1,MAPH do
                map[i][j] = 0
            end
        end

        save = {map, 5, "aac"}

        local encoded_tbl = buffer.encode(save)
        
        --love.data.encode("base64", "string", str))

        save = buffer.decode(encoded_tbl)

        -- love.graphics.setColor(0,1,0)
    end
    
    function love.draw()
       --  love.graphics.draw(image, 400, 300)
       love.graphics.printf(tostring(save[1][1])..tostring(save[2])..tostring(save[3]), 0, WINDOWH-50, WINDOWW)
    end
end
