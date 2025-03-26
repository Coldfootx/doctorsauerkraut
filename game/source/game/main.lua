SCREENSPACE = 0.88
SMALLFONT = 0.0125
SMALLFONTDRAWS = 3
BIGFONT = 0.02
SCROLLLINES = 8

MAP_W = 1024
MAP_H = 1024

FPS = 75

SAVEFILE = "savefile" -- +n
COMPRESSION = "zlib"
RANDOMNESSFILE = "randomness"

HELP_TEXT ='Additional licenses not mentioned in the license file in the game folder \nand folder love in the source distribution\n\n\nThis game \nnewest GPL\n\n\n----Libraries----\n\n\nlume\nA collection of functions for Lua, geared towards game development.\nUsing it for serializing data before compression.\nhttps://github.com/rxi/lume\nMIT \n--\n-- lume\n--\n-- Copyright (c) 2020 rxi\n--\n-- Permission is hereby granted, free of charge, to any person obtaining a copy of\n-- this software and associated documentation files (the "Software"), to deal in\n-- the Software without restriction, including without limitation the rights to\n-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies\n-- of the Software, and to permit persons to whom the Software is furnished to do\n-- so, subject to the following conditions:\n--\n-- The above copyright notice and this permission notice shall be included in all\n-- copies or substantial portions of the Software.\n--\n-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n-- SOFTWARE.\n--\n\n\n----Graphics----\n\n\nMain Menu background money notes - graphics/100.jpg\nhttps://en.wikipedia.org/wiki/File:DAN-13-Danzig-100_Mark_(1922).jpg\nFrom user https://commons.wikimedia.org/wiki/User:Godot13 - Godot13\nAttribution National Numismatic Collection, National Museum of American History\nCreative Commons Attribution-Share Alike 4.0 International\n\n\nBackground love potion - graphics/potion.jpg\nhttps://en.w ikipedia.org/wiki/File:Filtre_d%27Amour.jpg\nFrom user https://commons.wikimedia.org/wiki/User:Arnaud_25 - Arnaud_25\nCreative Commons Attribution-Share Alike 4.0 International'

--STATEMENTS

STARTING_RANDOMNESS = 300

--[[
    url,website logo,game logo and game title and maybe game banner's text. only 5 places for name

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

    local function explode(inputstr, sep)
        sep=sep or '%s'
        local t={}
        for field,s in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do
            table.insert(t,field)  
            if s=="" then return t
            end
        end
    end


    local function debugbox(value)
        love.window.showMessageBox("Debug Info", value, {"OK"}, "info", true)
    end

    local function load_help_text(prefix)
        local lines = explode(HELP_TEXT, "\n")
        local fits = (Buttons[State.leaf][3].y-State.helppadding-(Buttons[State.leaf][2].y+Buttons[State.leaf][2].height+State.helppadding))/SmallFont:getHeight()
        local sliced = {}
        for i=0, fits do
            sliced[i] = lines[prefix+i]
        end
        --debugbox(sliced[2])
        local nstring = table.concat(sliced, "\n")
        State.savedhelpprefix = prefix
        --debugbox(nstring)
        return nstring
    end

    local function helpwindow()
        State.leaf = 5
        State.help_text = load_help_text(State.savedhelpprefix)
        
    end

    local function quitgame()
        quitmessage()
    end

    function love.keypressed(key, scancode, isrepeat)
        if key == "return" and State.hoover == -2 then
            debugbox(CommandLine.text)
        elseif key == "escape" and State.leaf ~= 1 then
            State.oldleaf = State.leaf
            State.leaf = 1
        elseif key == "escape" then
            State.leaf = State.oldleaf
        elseif key == "backspace"and State.hoover == -2 then
            CommandLine.text = CommandLine.text:sub(1,-2)
        end
    end

    function love.keyreleased(key, scancode, isrepeat)
        --debugbox(key) 
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
        gfx.setColor(1,0,0)
        for i=1, SMALLFONTDRAWS do
            --[[gfx.setColor(0,0,0)
            gfx.print(text, width-1, height)
            gfx.print(text, width+1, height)
            gfx.print(text, width, height-1)
            gfx.print(text, width, height+1)
            gfx.print(text, width-1, height+1)
            gfx.print(text, width+1, height-1)
            gfx.print(text, width+1, height+1)
            gfx.print(text, width-1, height-1)]]--
            gfx.print(text, width, height)
        end
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

    local function find_hoovered_button(x, y)
        local found = false
        if State.hoover ~= -2 then
            local len = table_len(Buttons[State.leaf])
            for i=1,len do
                local button = Buttons[State.leaf][i]
                if x > button.x and x < button.x + button.width and y > button.y and y < button.y + button.height then
                    State.hoover = i
                    found = true
                    break
                end
            end
        end
        return found
    end

    function love.mousemoved(x, y, dx, dy, istouch )
        local found = false
        found = find_hoovered_button(x, y)
        if found == false and x > CommandLine.x and x < CommandLine.x + CommandLine.width and y > CommandLine.y and y < CommandLine.y + CommandLine.height and State.hoover ~= -2 then
            State.hoover = -1
        elseif found == false and State.hoover ~= -2 then
            State.hoover = 0
        end
    end

    local function backtomain()
        State.leaf = 1
        State.oldleaf = 1
    end

    local function scrollhelpup()
        State.savedhelpprefix = State.savedhelpprefix - SCROLLLINES
        if State.savedhelpprefix < 0 then
            State.savedhelpprefix = 0
        end
        State.help_text = load_help_text(State.savedhelpprefix)
    end

    local function scrollhelpdown()
        State.savedhelpprefix = State.savedhelpprefix + SCROLLLINES
        State.help_text = load_help_text(State.savedhelpprefix)
    end

    function love.load()
        love.window.setVSync(1)
        love.window.setTitle("Doctor Sauerkraut")
        love.keyboard.setKeyRepeat(true)
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

        Buttons[2] = {{}}
        Buttons[3] = {{}}
        Buttons[4] = {{}}

        local helpbuttonw, helpbuttonh = translatexy(0.3, 0.07)
        local helpbuttonstartx, helpbuttonstarty = translatexy(0, 0.1)
        local centeredx = ScreenWidth/2.0-helpbuttonw/2.0
        Buttons[5] = {{text="Back to Main", x = centeredx, y = helpbuttonstarty, width = helpbuttonw, height=helpbuttonh, call = backtomain}, {text="Scroll Up", x = centeredx, y = helpbuttonstarty+helpbuttonh, width = helpbuttonw, height=helpbuttonh, call = scrollhelpup}, {text="Scroll Down", x = centeredx, y = helpbuttonstarty+10*helpbuttonh, width = helpbuttonw, height=helpbuttonh, call = scrollhelpdown}}

        local commandlinewidth=ScreenWidth/1.4
        CommandLine = {width=commandlinewidth, height=SmallFont:getHeight("debug"), x=ScreenWidth/2.0-commandlinewidth/2.0, y=ScreenHeight-ScreenHeight/10.0, button=gfx.newImage("graphics/enterbutton.png"), color = {1, 1, 1, 1}, focusedcolor = {0.2, 0.2, 0.2, 1}, focuspostfix="x_", focusswitch = true, focustime=0.7, focusmax = 0.7, text="dr"}
        
        State = {leaf = 1, oldleaf = 1, hoover = 0, logo = gfx.newImage("graphics/logo.png"), bg = gfx.newImage("graphics/100.jpg"), banner = gfx.newImage("graphics/banner.png"), bannerx = gfx.newImage("graphics/red.png"), bannerm = gfx.newImage("graphics/yellow.png"), helpbg = gfx.newImage("graphics/forest.png"), helppadding = ScreenWidth*0.2*0.1, savedhelpprefix=0}
        -- leaf 1 = main menu, 2 = new game,
    end

    function love.mousereleased(x, y, button, istouch, presses)
        if button == 1 and State.hoover > 0 then
            Buttons[State.leaf][State.hoover].call()
        elseif x > CommandLine.x and x < CommandLine.x + CommandLine.width and y > CommandLine.y and y < CommandLine.y + CommandLine.height then
            State.hoover = -2
        elseif x > ScreenWidth-State.banner:getHeight() and x < ScreenWidth and y > 0 and y < State.banner:getHeight() then
            if State.hoover == -2 then
                State.hoover = 0
            else
                quitmessage()
            end
        elseif x > ScreenWidth-2*State.banner:getHeight() and x < ScreenWidth-State.banner:getHeight() and y > 0 and y < State.banner:getHeight() then
            if State.hoover == -2 then
                State.hoover = 0
            else
                love.window.minimize()
            end
        else
            State.hoover = 0
            find_hoovered_button(x, y)
        end
    end

    function love.update(dt)
        local timeout = 1.0/FPS - dt
        if timeout < 0 then
            timeout = 0
        end

        CommandLine.focustime = CommandLine.focustime - 1/FPS
        if CommandLine.focustime < 0 then
            CommandLine.focustime= CommandLine.focusmax
            if CommandLine.focusswitch == true then
                CommandLine.focusswitch = false
            else
                CommandLine.focusswitch = true
            end
        end

        love.timer.sleep(timeout)
    end

    function love.textinput(text)
        if State.hoover == -2 then
            CommandLine.text = CommandLine.text..text
        end
    end

    function love.draw()
        if State.leaf == 1 then
            gfx.setColor(0.7,0.1,0.1)
            gfx.rectangle("fill", 0, 0, ScreenWidth, ScreenHeight)
            gfx.setColor(255, 255, 255, 255)
            gfx.push()
            local scale = ScreenHeight/State.bg:getHeight()
            gfx.scale(scale, scale)
            gfx.draw(State.bg, 0,0)
            gfx.pop()
            local mx, my = translatexy(0, 0.1)
            gfx.draw(State.logo, ScreenWidth/2.0-State.logo:getWidth()/2.0, my)
        elseif State.leaf == 5 then
            gfx.setColor(0.1,0.7,0.1)
            gfx.rectangle("fill", 0, 0, ScreenWidth, ScreenHeight)
            gfx.setColor(255, 255, 255, 255)
            gfx.push()
            local scalex = ScreenWidth/State.helpbg:getWidth()
            local scaley = ScreenHeight/State.helpbg:getHeight()
            gfx.scale(scalex, scaley)
            gfx.draw(State.helpbg, 0, 0)
            gfx.pop()
            gfx.setColor(0.72,0.59,0.33)
            local beyondbuttonw, beyondbuttonh = translatexy(0.2, 0.2)
            gfx.rectangle("fill", Buttons[State.leaf][2].x-beyondbuttonw, Buttons[State.leaf][2].y+Buttons[State.leaf][2].height, Buttons[State.leaf][2].width+ 2*beyondbuttonw, Buttons[State.leaf][3].y-(Buttons[State.leaf][2].y+Buttons[State.leaf][2].height))
            gfx.setColor(1,1,1)
            gfx.rectangle("line", Buttons[State.leaf][2].x-beyondbuttonw, Buttons[State.leaf][2].y+Buttons[State.leaf][2].height, Buttons[State.leaf][2].width+ 2*beyondbuttonw, Buttons[State.leaf][3].y-(Buttons[State.leaf][2].y+Buttons[State.leaf][2].height))
            gfx.print(State.help_text, Buttons[State.leaf][2].x-beyondbuttonw+State.helppadding, Buttons[State.leaf][2].y+Buttons[State.leaf][2].height+State.helppadding)
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

        --first after custom leaves is banner
        gfx.setFont(SmallFont)
        gfx.setColor(255, 255, 255, 255)
        for i=1,ScreenWidth do
            gfx.draw(State.banner, i-1, 0)
        end
        local text = "Doctor Sauerkraut"
        gfx.setColor(1,1,1)
        for i=1, SMALLFONTDRAWS do
            gfx.print(text, ScreenWidth/2.0 - SmallFont:getWidth(text)/2.0, State.banner:getHeight()/2.0-SmallFont:getHeight(text)/2.0)
        end
        gfx.push()
        local scale = State.banner:getHeight()/State.bannerx:getHeight()
        gfx.scale(scale, scale)
        gfx.draw(State.bannerx, ScreenWidth/scale-State.bannerx:getWidth(), 0)
        gfx.pop()
        gfx.push()
        local scale = State.banner:getHeight()/State.bannerm:getHeight()
        gfx.scale(scale, scale)
        gfx.draw(State.bannerm, ScreenWidth/scale-2*State.bannerm:getWidth(), 0)
        gfx.pop()

        if State.hoover < 0 then
            gfx.setColor(CommandLine.focusedcolor)
        else
            gfx.setColor(CommandLine.color)
        end
        gfx.rectangle("fill", CommandLine.x, CommandLine.y, CommandLine.width, CommandLine.height)
        gfx.setColor(255, 255, 255, 255)
        gfx.push()
        local scale = CommandLine.height/CommandLine.button:getHeight()
        gfx.scale(scale, scale)
        gfx.draw(CommandLine.button, CommandLine.x/scale + CommandLine.width/scale-CommandLine.button:getWidth(), CommandLine.y/scale)
        gfx.pop()
        local color
        if State.hoover >= 0 then
            color = CommandLine.focusedcolor
        else
            color = CommandLine.color
        end
        gfx.setColor(color)
        for i=1, SMALLFONTDRAWS do
            gfx.print(CommandLine.text, CommandLine.x, CommandLine.y+CommandLine.height/2.0-SmallFont:getHeight(CommandLine.text)/2.0)
            if CommandLine.focusswitch == true then
                gfx.print(CommandLine.focuspostfix, CommandLine.x+SmallFont:getWidth(CommandLine.text), CommandLine.y+CommandLine.height/2.0-SmallFont:getHeight(CommandLine.text)/2.0)
            end
        end

        print_to_debug(ScreenWidth.."x"..ScreenHeight..", vsync="..love.window.getVSync()..", fps="..love.timer.getFPS()..", mem="..string.format("%.3f", collectgarbage("count")/1000.0).."MB, mapnumber="..MapTotal..", randomseed="..Randomseed)
    end
end
