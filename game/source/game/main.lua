SCREENSPACE = 0.88
SMALLFONT = 0.0125
BIGFONT = 0.02

MAP_W = 1024
MAP_H = 1024

FPS = 75

SAVEFILE = "savefile" -- +n
COMPRESSION = "zlib"
RANDOMNESSFILE = "randomness"

--STATEMENTS
STARTING_RANDOMNESS = 300

--[[
    url,website logo,game logo and game title and maybe game banner's text. only 5 places for name

    Clean folder %APPDATA%/LOVE to save some space! This folder is for starting directly from code.
    And clean folder C:\Users\user\AppData\Roaming\gamename or \game. This folder is for starting from the compiled executable.
    If you delete the file RANDOMNESSFILE (see above) it is regenerated but edit its contained number to avoid same map generation. Ideally it should be accumulating forever to avoid them.

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

    local function boostrandom()
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
        x1 = x1*ScreenWidth
        y1 = y1*ScreenHeight
        return x1, y1
    end

    local function print_to_debug(text)
        local width, height = translatexy(0.01, 0.97)
        gfx.setColor(1,1,1)
        gfx.rectangle("fill",width,height,SmallFont:getWidth(text),SmallFont:getHeight(text))
        gfx.setFont(SmallFont)
        --[[gfx.setColor(0,0,0)
        gfx.print(text, width-1, height)
        gfx.print(text, width+1, height)
        gfx.print(text, width, height-1)
        gfx.print(text, width, height+1)
        gfx.print(text, width-1, height+1)
        gfx.print(text, width+1, height-1)
        gfx.print(text, width+1, height+1)
        gfx.print(text, width-1, height-1)]]--
        gfx.setColor(1,0,0)
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

    function love.mousemoved(x, y, dx, dy, istouch )
        local len = table_len(Buttons[State.leaf])
        for i=1,len do
            local button = Buttons[State.leaf][i]
            if x > button.x and x < button.x + button.width and y > button.y and y < button.y + button.height then
                State.hoover = i
                break
            else
                State.hoover = 0
            end
        end
    end

    local function debugbox(value)
        love.window.showMessageBox("Debug Info", value, {"OK"}, "info", true)
    end

    function love.load()
        love.window.setVSync(1)
        love.window.setTitle("Doctor Sauerkraut")
        ScreenWidth, ScreenHeight = love.window.getDesktopDimensions()
        ScreenWidth, ScreenHeight = ScreenWidth*SCREENSPACE, ScreenHeight*SCREENSPACE
        love.window.setMode(ScreenWidth, ScreenHeight, {resizable =false, borderless= true, y=ScreenHeight*(1-SCREENSPACE)/2.0, x=ScreenWidth*(1-SCREENSPACE)/2.0})

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

        local fontsize, y = translatexy(SMALLFONT,SMALLFONT)
        SmallFont = gfx.newFont(fontsize)
        fontsize, y = translatexy(BIGFONT, BIGFONT)
        BigFont = gfx.newFont(fontsize)

        local newgamebuttonw, newgamebuttonh = translatexy(0.25, 0.07)
        local newbuttonstartw, newbuttonstarth = translatexy(0.5, 0.3)
        local wt, newgamebuttonpadding = translatexy(0.5, 0.02)

        Buttons = {{}}
        Buttons[1] = {{text="New Game", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth, width = newgamebuttonw, height=newgamebuttonh, call = newgame},{text="Save Game", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+newgamebuttonh+newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = savegame}, {text="Load Game", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+2*newgamebuttonh+2*newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = loadgame}, {text="Help", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+3*newgamebuttonh+3*newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = helpwindow}, {text="Quit", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+4*newgamebuttonh+4*newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = quitgame}}
        
        State = {leaf = 1, oldleaf = 1, hoover = 0, logo = gfx.newImage("graphics/logo.png"), bg = gfx.newImage("graphics/parrot.png"), banner = gfx.newImage("graphics/banner.png")}
        -- leaf 1 = main menu, 2 = new game,
    end

    function love.mousereleased(x, y, button, istouch, presses)
        if button == 1 and State.hoover ~= 0 then
            Buttons[State.leaf][State.hoover].call()
        end
    end

    function love.update(dt)
        local timeout = 1.0/FPS - dt
        if timeout < 0 then
            timeout = 0
        end

        love.timer.sleep(timeout)
    end

    function love.draw()
        if State.leaf == 1 then
            gfx.setColor(0,0.5,0)
            gfx.rectangle("fill", 0, 0, ScreenWidth, ScreenHeight)
            gfx.setColor(255, 255, 255, 255)
            gfx.push()
            gfx.scale(ScreenHeight/State.bg:getHeight(), ScreenHeight/State.bg:getHeight())
            gfx.draw(State.bg, 0,0)
            gfx.pop()
            local mx, my = translatexy(0, 0.1)
            gfx.draw(State.logo, ScreenWidth/2.0-State.logo:getWidth()/2.0, my)
        end

        --first after custom leaves is banner
        for i=1,ScreenWidth do
            gfx.draw(State.banner, i-1, 0)
        end
        local text = "Doctor Sauerkraut"
        gfx.setColor(1,1,1)
        for i=1, 6 do
            gfx.print(text, ScreenWidth/2.0 - SmallFont:getWidth(text)/2.0, State.banner:getHeight()/2.0-SmallFont:getHeight(text)/2.0)
        end

        gfx.setFont(BigFont)
        local len = table_len(Buttons[State.leaf])
        for i=1,len do
            local button = Buttons[State.leaf][i]
            if State.hoover == i then
                gfx.setColor(0,0,0)
                gfx.rectangle("fill", button.x, button.y, button.width, button.height)
                gfx.setColor(1,1,1)
                gfx.rectangle("line", button.x, button.y, button.width, button.height)
                local w,h = BigFont:getWidth(button.text), BigFont:getHeight(button.text)
                gfx.print(button.text, button.x+button.width/2.0-w/2.0, button.y+button.height/2.0-h/2.0)
            else
                gfx.setColor(1,1,1)
                gfx.rectangle("fill", button.x, button.y, button.width, button.height)
                gfx.rectangle("line", button.x, button.y, button.width, button.height)
                gfx.setColor(0,0,0)
                local w,h = BigFont:getWidth(button.text), BigFont:getHeight(button.text)
                gfx.print(button.text, button.x+button.width/2.0-w/2.0, button.y+button.height/2.0-h/2.0)
            end
        end

        for i=1, 6 do
            print_to_debug(ScreenWidth.."x"..ScreenHeight..", vsync="..love.window.getVSync()..", fps="..love.timer.getFPS()..", mem="..string.format("%.3f", collectgarbage("count")/1000.0).."MB, mapnumber="..MapTotal..", randomseed="..Randomseed)
        end
    end
end
