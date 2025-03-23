MAP_W = 1024
MAP_H = 1024
WINDOW_W = 1200
WINDOW_H = 600

FPS = 60

SAVEFILE = "savefile" -- +n
COMPRESSION = "zlib"
RANDOMNESSFILE = "randomness"

--STATEMENTS
STARTING_RANDOMNESS = 300

--[[
    url,website logo,game logo and game title- only 4 places for name
    The grid comes with 24 columns and 16 rows

    Clean folder %APPDATA%/LOVE to save some space!

    Mini tiles hand-drawn with A* clicks
    -pystyy polttamaan
]] --

do
    local love = require("love")
    local lume = require("lib.lume")

    local choice
    if love.filesystem.getInfo(RANDOMNESSFILE) == nil then
        love.filesystem.write(RANDOMNESSFILE, tostring(STARTING_RANDOMNESS))
        choice = STARTING_RANDOMNESS
    else
        local contents, size = love.filesystem.read(RANDOMNESSFILE)
        choice = tonumber(contents)+1
        if choice > 2147483646 then
            choice = 0
        end
        love.filesystem.write(RANDOMNESSFILE, tostring(choice))
    end
    local randomgen = love.math.newRandomGenerator(choice)
    Randomseed = choice

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
        local width, height = translatexy(0.01, 0.95)
        love.graphics.setColor(0,1,0)
        love.graphics.print(text, width, height)
    end

    local function generate_map()
        local map = {}
        local maptotal = 0
        for i=1,MAP_W do
            map[i] = {}     -- create x
            for j=1,MAP_H do
                map[i][j] = randomgen:random(2)-1
                maptotal = maptotal + map[i][j]
            end
        end

        Save.map = map

        return maptotal
    end

    local function savegame()

    end

    local function newgame()

    end

    local function loadgame()

    end

    local function helpwindow()

    end

    local function quitgame()

    end

    function love.mousepressed(x, y, mouse_button, is_touch)
        --[[if x < WINDOW_W and x > WINDOW_W-25 and y > 0 and y < 25 then
            quitmessage()
        end]]--
    end

    function love.load()
        love.window.setVSync(1)
        love.window.setTitle("Doctor Sauerkraut")
        love.window.setMode(WINDOW_W, WINDOW_H, {resizable =false, borderless= true, centered=true})

        --initialize savedata
        local map = {}
        for i=1,MAP_W do
            map[i] = {}     -- create x
            for j=1,MAP_H do
                map[i][j] = 0
            end
        end
        Save = {map=map, positionx=0, positiony=0}

        --generate all data
        MapTotal = generate_map()

        State = {leaf = "mainmenu"}
        --GUI = {}
        --GUI["mainmenu"] = {buttons = {text="New Game",x=MAINMENU_LEFTALIAS,y=0.40},{text="Save Game",x=MAINMENU_LEFTALIAS,y=0.45},{text="Load Game",x= MAINMENU_LEFTALIAS,y=0.5},{text="Help",x=MAINMENU_LEFTALIAS,y=0.55},{text="Quit",x=MAINMENU_LEFTALIAS,y=0.60}}
    end

    function love.update(dt)
        local timeout = 1.0/FPS - dt
        if timeout < 0 then
            timeout = 0
        end
        love.timer.sleep(timeout)
    end

    function love.draw()
        if State.leaf == "mainmenu" then

        end

        --[[love.graphics.setColor(1,0,0)
        love.graphics.rectangle("fill", WINDOW_W-25, 0, 25, 25)]]--
        local width, height = love.graphics.getDimensions()
        print_to_debug(width.."x"..height..", vsync="..love.window.getVSync()..", fps="..love.timer.getFPS()..", mem="..string.format("%.3f", collectgarbage("count")/1000.0).."MB, mapnumber="..MapTotal..", randomseed="..Randomseed)
    end
end
