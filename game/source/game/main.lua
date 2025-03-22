MAP_W = 1024
MAP_H = 1024
WINDOW_W = 1920
WINDOW_H = 1080 -- 16:9
SAVEFILE = "savefile" -- +n
COMPRESSION = "zlib"

--[[
    Clean folder %APPDATA%/LOVE to save some space!
]] --

do 
    local love = require("love")
    local lume = require("lib.lume")

    local function savefile(save_number)
        local compressed = love.data.compress("string", COMPRESSION, lume.serialize(Save), 9)

        love.filesystem.write(SAVEFILE..save_number, compressed)
    end

    local function loadfile(save_number)
        local contents, size = love.filesystem.read(SAVEFILE..save_number)

        Save = lume.deserialize(love.data.decompress("string", COMPRESSION, contents))
    end

    local function quitmessage()
        local pressedbutton = love.window.showMessageBox("Want to Quit?", "All saved progress will be lost", {"OK", "No!", escapebutton = 1})
        if pressedbutton == 1 then
            love.event.quit()
        end
    end

    function love.keypressed(key, scancode, isrepeat)
        if key == "escape" then
            quitmessage()
        end
    end

    local function translatexy(x1, y1)
        local width, height = love.graphics.getDimensions( )
        x1 = x1*width
        y1 = y1*height
        return x1, y1
    end

    local function print_to_debug(text)
        love.graphics.setColor(0,0,0)
        love.graphics.printf(text, 10+1, WINDOW_H-45, WINDOW_W)
        love.graphics.printf(text, 10-1, WINDOW_H-45, WINDOW_W)
        love.graphics.printf(text, 10, WINDOW_H-45+1, WINDOW_W)
        love.graphics.printf(text, 10, WINDOW_H-45-1, WINDOW_W)

        local width, height = translatexy(0.05, 0.95)
        love.graphics.setColor(0,1,0)
        love.graphics.printf(text, width, height, 800)
    end

    function love.load()
        love.window.setMode(WINDOW_W, WINDOW_H, {fullscreen=true})

        local map = {}
        for i=1,MAP_W do
            map[i] = {}     -- create x
            for j=1,MAP_H do
                map[i][j] = 0
            end
        end

        Save = {map, 5, "aac", { {1,"select"}, "select2" }}
    end

    function love.draw()
        local width, height = love.graphics.getDimensions( )
        print_to_debug(tostring(tostring(Save[1][2][5]))..", "..tostring(Save[2])..", "..tostring(Save[3])..", "..tostring(Save[4][1][2]..", "..width.."x"..height..", "..love.window.getVSync()))
        --1536x864
    end
end
