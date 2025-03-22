MAP_W = 1024
MAP_H = 1024
WINDOW_W = 1000
WINDOW_H = 600
GAMEFILES_FOLDER= "Gamefiles"
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
        GAMEFILES_FOLDER = love.filesystem.getSaveDirectory().."/"..GAMEFILES_FOLDER
        if love.filesystem.getInfo(GAMEFILES_FOLDER, "directory") == nil then
            love.filesystem.createDirectory(GAMEFILES_FOLDER)
        end


        SAVEFILE_NAME = GAMEFILES_FOLDER.."/"..SAVEFILE_NAME

        love.window.setMode(WINDOW_W, WINDOW_H)

        local buffer = require("string.buffer")

        local map = {}
        for i=1,MAP_W do
            map[i] = {}     -- create x
            for j=1,MAP_H do
                map[i][j] = 0
            end
        end

        Save = {map, 5, "aac", { {1,"select"}, "select2" }}

        local compressed = love.data.compress("string", "zlib", lume.serialize(Save), 9)

        Compressed3 = compressed

        local file = assert(io.open(SAVEFILE_NAME, "wb"))
        file:write(compressed)
        file:close()

        file = assert(io.open(SAVEFILE_NAME, "rb"))
        compressed = file:read()
        file:close()

        Compressed2 = compressed

        --Save = lume.deserialize(love.data.decompress("string", "zlib", compressed))
    end

    function love.draw()
        --  love.graphics.draw(image, 400, 300)
        --print_to_debug(tostring(tostring(Save[1][2][5]))..", "..tostring(Save[2])..", "..tostring(Save[3])..", "..tostring(Save[4][1][2]))
        print_to_debug(string.len(Compressed2).." "..string.len(Compressed3))
    end
end
