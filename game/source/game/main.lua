MAP_W = 1024
MAP_H = 1024

FPS = 75

SAVEFILE = "savefile" -- +n
COMPRESSION = "zlib"
RANDOMNESSFILE = "randomness"

--STATEMENTS
STARTING_RANDOMNESS = 300

--[[
    url,website logo,game logo and game title- only 4 places for name

    Clean folder %APPDATA%/LOVE to save some space! This folder is for starting directly from code.
    And clean folder C:\Users\user\AppData\Roaming\gamename or \game. This folder is for starting from the compiled executable.
    If you delete the file RANDOMNESSFILE (see above) you might generate old maps unless you add your own number to the new file the game creates containing STARTING_RANDOMNESS

    Mini tiles hand-drawn with A* clicks
    -2 places
    -pystyy polttamaan
]] --

do
    local love = require("love")
    local lume = require("lib.lume")

    local gfx = love.graphics

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

    local function table_len(t)
        local n = 0
        for _ in pairs(t) do
            n = n + 1
        end
        return n
    end

    local function quitmessage()
        local pressedbutton = love.window.showMessageBox("Want to Quit?", "All unsaved progress will be lost", {"OK", "No!", enterbutton = 2}, "warning", true)
        if pressedbutton == 1 then
            love.event.quit()
        end
    end

    local function savegame()

    end

    local function newgame()
        love.window.showMessageBox("New Game", "Starting a new game", {"OK"}, "info", true)
    end

    local function loadgame()

    end

    local function helpwindow()

    end

    local function quitgame()
        quitmessage()
    end

    function love.keypressed(key, scancode, isrepeat)
        if key == "escape" and State.leaf ~= 1 then
            State.oldleaf = State.leaf
            State.leaf = 1
        elseif key == "escape" then
            quitgame()
        end
    end

    local function translatexy(x1, y1)
        local width, height = gfx.getDimensions()
        x1 = x1*width
        y1 = y1*height
        return x1, y1
    end

    local function print_to_debug(text)
        local width, height = translatexy(0.01, 0.95)
        gfx.setColor(0,1,0)
        gfx.print(text, width, height)
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
    
    local function mousepressed(x, y, mouse_button)
        Buttons[State.leaf][State.hoover].call()
    end

    local function mousemoved( x, y, dx, dy, istouch )
        if State.leaf == 1 then
            local len = table_len(Buttons[State.leaf])
            for i=1,len do
                if x > Buttons[State.leaf][i].x and x < Buttons[State.leaf][i].x + Buttons[State.leaf][i].width and y > Buttons[State.leaf][i].y and y <Buttons[State.leaf][i].y + Buttons[State.leaf][i].height then
                    State.hoover = i
                    break
                end
            end
        end
    end

    function love.load()
        love.window.setVSync(1)
        love.window.setTitle("Doctor Sauerkraut")
        ScreenWidth, ScreenHeight = love.window.getDesktopDimensions()
        local xd, yd = translatexy(0.1, 0.1)
        love.window.setMode(ScreenWidth-xd, ScreenHeight-yd, {resizable =false, borderless= true})

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
        local newgamebuttonw, newgamebuttonh = translatexy(0.25, 0.07)
        local newbuttonstartw, newbuttonstarth = translatexy(0.5, 0.3)
        local wt, newgamebuttonpadding = translatexy(0.5, 0.02)
        Buttons = { 
            {
                {text="New Game", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth, width = newgamebuttonw, height=newgamebuttonh, call = newgame},{text="Save Game", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+newgamebuttonh+newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = savegame}, {text="Load Game", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+2*newgamebuttonh+2*newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = loadgame}, {text="Help", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+3*newgamebuttonh+3*newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = helpwindow}, {text="Quit", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+4*newgamebuttonh+4*newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = quitgame}
                },
                {
            },
            {

            }
        }
        
        State = {leaf = 1, oldleaf = 1, hoover = 0}
        -- leaf 1 = main menu, 2 = new game,
    end

    local function debugbox(value)
        love.window.showMessageBox("Debug Info", value, {"OK"}, "info", true)
    end

    function love.mousereleased(x, y, button, istouch, presses)
        if button == 1 then 
            Buttons[State.leaf][State.hoover].call()
        end
    end

    function love.update(dt)
        local 	mx = love.mouse.getX()
        local	my = love.mouse.getY()

        mousemoved(mx, my)

        local timeout = 1.0/FPS - dt
        if timeout < 0 then
            timeout = 0
        end

        love.timer.sleep(timeout)
    end

    function love.draw()
        if State.leaf == 1 then
            gfx.setColor(1,1,1)
            local len = table_len(Buttons[State.leaf])
            
            for i=1,len do
                if State.hoover == i then
                    gfx.setColor(0,0,0)
                    gfx.rectangle("fill", Buttons[State.leaf][i].x, Buttons[State.leaf][i].y, Buttons[State.leaf][i].width, Buttons[State.leaf][i].height)
                    gfx.setColor(1,1,1)
                    gfx.rectangle("line", Buttons[State.leaf][i].x, Buttons[State.leaf][i].y, Buttons[State.leaf][i].width, Buttons[State.leaf][i].height)
                else
                    gfx.setColor(1,1,1)
                    gfx.rectangle("fill", Buttons[State.leaf][i].x, Buttons[State.leaf][i].y, Buttons[State.leaf][i].width, Buttons[State.leaf][i].height)
                end
            end

        end
        local width, height = gfx.getDimensions()
        print_to_debug(width.."x"..height..", vsync="..love.window.getVSync()..", fps="..love.timer.getFPS()..", mem="..string.format("%.3f", collectgarbage("count")/1000.0).."MB, mapnumber="..MapTotal..", randomseed="..Randomseed)
    end
end
