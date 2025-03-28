SCREENSPACE = 0.88
SMALLFONT = 0.0125
SMALLFONTDRAWS = 3
BIGFONT = 0.02
SCROLLLINES = 9

MAP_W = 512
MAP_H = 512
HOUSEAMOUNT = math.floor(MAP_W*0.5859375) --- 512 is 300
RIVERAMOUNT = math.floor(MAP_W*0.015) --512 is 7
SQUARESIZE = 20
RIVERWIDTH = 5
SCROLLLINESMAP = 2
HOUSESIZE = 10
HOUSESIZEVARY = 5
LAKESIZE = 30
LAKESIZEVARY = 10
LAKEAMOUNT = math.floor(MAP_W*0.02)

FPS = 75

SAVEFILE = "savefile" -- +n
COMPRESSION = "zlib"
RANDOMNESSFILE = "randomness"

--STATEMENTS
STARTING_RANDOMNESS = 300

HELP_TEXT = 'Clean folder %APPDATA%/LOVE to save some space! This folder is \nfor starting directly from code.\n \nAnd clean folder %APPDATA%/gamename or simply /game. This folder is \nfor starting from the compiled executable.\n \nIf you delete the file "randomness"it is regenerated but edit its \ncontained number to avoid same map generation. Ideally it should be \naccumulating forever to avoid them.\n\nIn Linux look for these\n$XDG_DATA_HOME/love/ or ~/.local/share/love/\nlove may be replaced by game name or simply "game"\n\n\nAND NOW FOR LICENSES\n\n\nAdditional licenses not mentioned in the license file in the game folder \nand folder love in the source distribution\n\n\nThis game \nnewest GPL\n\n\n----Libraries----\n\n\nlume\nA collection of functions for Lua, geared towards game development.\nUsing it for serializing data before compression.\nhttps://github.com/rxi/lume\nMIT \n--\n-- lume\n--\n-- Copyright (c) 2020 rxi\n--\n-- Permission is hereby granted, free of charge, to any person obtaining a copy of\n-- this software and associated documentation files (the "Software"), to deal in\n-- the Software without restriction, including without limitation the rights to\n-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies\n-- of the Software, and to permit persons to whom the Software is furnished to do\n-- so, subject to the following conditions:\n--\n-- The above copyright notice and this permission notice shall be included in all\n-- copies or substantial portions of the Software.\n--\n-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n-- SOFTWARE.\n--\n\n\n----Graphics----\n\n\nMain Menu background money notes - graphics/100.jpg\nhttps://en.wikipedia.org/wiki/File:DAN-13-Danzig-100_Mark_(1922).jpg\nFrom user https://commons.wikimedia.org/wiki/User:Godot13 - Godot13\nAttribution National Numismatic Collection, National Museum of American History\nCreative Commons Attribution-Share Alike 4.0 International\n\n\nBackground love potion - graphics/potion.jpg\nhttps://en.w ikipedia.org/wiki/File:Filtre_d%27Amour.jpg\nFrom user https://commons.wikimedia.org/wiki/User:Arnaud_25 - Arnaud_25\nCreative Commons Attribution-Share Alike 4.0 International\n\n'

--[[
    url,website logo,game logo and game title and game banner's text. only 5 places for name
    name about me and github
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

    local function quitmessage()
        local pressedbutton = love.window.showMessageBox("Want to Quit?", "All unsaved progress will be lost", {"OK", "No!", enterbutton = 2}, "warning", true)
        if pressedbutton == 1 then
            love.event.quit()
        end
    end

    local function savegame()

    end

    local function newgame()
        State.leaf = 2
        State.hoover = 0
        find_hoovered_button(Currentx, Currenty)
    end

    local function loadgame()

    end

    local function continuegame()
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
        if State.hoover >= 0 then
            if key == "return" then
                State.hoover = -2
            end
        elseif key == "return" and State.hoover == -2 then
            debugbox(CommandLine.text)
        elseif key == "backspace"and State.hoover == -2 then
            CommandLine.text = CommandLine.text:sub(1,-2)
        end
    end

    function love.keyreleased(key, scancode, isrepeat)
        if key == "escape" and State.leaf ~= 1 then
            State.oldleaf = State.leaf
            State.leaf = 1
        elseif key == "escape" then
            if State.oldleaf == 1 then
                quitmessage()
            else
                State.leaf = State.oldleaf
            end
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
                map[i][j] = randomgen:random(2)
                maptotal = maptotal + map[i][j]
            end
        end

        for n = 1, LAKEAMOUNT do
            -- This code is contributed by chandan_jnu
            local rx = math.random(LAKESIZE-LAKESIZEVARY, LAKESIZE+LAKESIZEVARY)
            local ry = math.random(LAKESIZE-LAKESIZEVARY, LAKESIZE+LAKESIZEVARY)
            local xc = math.random(1,MAP_W)
            local yc = math.random(1,MAP_H)

            local x = 0;
            local y = ry

            -- Initial decision parameter of region 1 
            local d1 = ((ry * ry) - (rx * rx * ry) + (0.25 * rx * rx)); 
            local dx = 2 * ry * ry * x
            local dy = 2 * rx * rx * y

            while dx < dy do
                --Print points based on 4-way symmetry 
                --print("(", x + xc, ",", y + yc, ")")
                --print("(",-x + xc,",", y + yc, ")")
                --print("(",x + xc,",", -y + yc ,")")
                --print("(",-x + xc, ",", -y + yc, ")")
                map[math.min(x+xc, MAP_W)][math.min(y+yc, MAP_H)] = 6
                map[math.max(-x+xc,1)][math.min(y+yc, MAP_H)] = 6
                map[math.min(x+xc, MAP_W)][math.max(-y+yc,1)] = 6
                map[math.max(-x+xc,1)][math.max(-y+yc,1)] = 6

                for ix = math.max(-x+xc,1), math.min(x+xc, MAP_W) do
                    for iy = math.max(-y+yc,1), math.min(y+yc, MAP_H) do
                        map[ix][iy] = 6
                    end
                end

                -- Checking and updating value of decision parameter based on algorithm 
                if (d1 < 0) then
                    x = x + 1
                    dx = dx + (2 * ry * ry)
                    d1 = d1 + dx + (ry * ry)
                else
                    x = x + 1; 
                    y = y - 1; 
                    dx = dx + (2 * ry * ry)
                    dy = dy - (2 * rx * rx)
                    d1 = d1 + dx - dy + (ry * ry)
                end
            end
        end

        for times=1, math.floor(HOUSEAMOUNT) do
            local housex, housey = randomgen:random(MAP_W), randomgen:random(MAP_H)
            local housew, househ = randomgen:random(HOUSESIZE-HOUSESIZEVARY,HOUSESIZE+HOUSESIZEVARY), randomgen:random(HOUSESIZE-HOUSESIZEVARY,HOUSESIZE+HOUSESIZEVARY)
            local endpointx = housex+housew
            local endpointy = housey+househ
            if endpointx > MAP_W then
                endpointx = MAP_W
            end
            if endpointy > MAP_H then
                endpointy = MAP_H
            end
            for i=housex, endpointx do
                map[i][housey] = 3
                map[i][endpointy] = 3
                for y = housey+1, endpointy-1 do
                    for x = i+1, i+endpointx-1 do
                        map[i][y] = 4
                    end
                end
            end
            for j=housey, endpointy do
                map[housex][j] = 3
                map[endpointx][j] = 3
            end
            local whichwall = math.random(4)
            if whichwall == 1 then
                local along = math.random(housey+1, endpointy-1)
                map[housex][along] = 4
            elseif whichwall == 2 then
                local along = math.random(housey+1, endpointy-1)
                local position = math.min(housex+housew, endpointx)
                map[position][along] = 4
            elseif whichwall == 3 then
                local along = math.random(housex+1, endpointx-1)
                map[along][housey] = 4
            elseif whichwall == 4 then
                local along = math.random(housex+1, endpointx-1)
                local position = math.min(housey+househ, endpointy)
                map[along][housey] = 4
            end
        end

        for n=1,RIVERAMOUNT do
            local xposition = math.random(1,MAP_W)
            local yposition = 1
            for j = yposition, MAP_H do
                local amountfree = 0
                for i = xposition, MAP_W do
                    if Tiles[map[i][j]].obstacle == false then
                        amountfree = amountfree + 1
                        if amountfree == RIVERWIDTH then
                            local xstart = math.max(i - RIVERWIDTH, 1)
                            for ii = xstart, i do
                                map[math.min(ii+1,MAP_W)][j] = 5
                            end
                            xposition = xstart + 1
                            break
                        end
                    else
                        local jdlimit = math.max(j-RIVERWIDTH, 1)+1
                        local xdlimit = math.min(i+RIVERWIDTH+1, MAP_W)
                        for jd = jdlimit, j do
                            for xd = i,xdlimit do
                                map[xd][jd-1] = 5
                            end
                        end
                        amountfree = 0
                    end
                end
            end
        end

        Save.map = map

        return maptotal
    end

    local function mousepressed(x, y, mouse_button)
        Buttons[State.leaf][State.hoover].call()
    end

    function love.mousemoved(x, y, dx, dy, istouch )
        local found = false
        found = find_hoovered_button(x, y)
        if found == false and x > CommandLine.x and x < CommandLine.x + CommandLine.width and y > CommandLine.y and y < CommandLine.y + CommandLine.height and State.hoover ~= -2 then
            State.hoover = -1
        elseif found == false and State.hoover ~= -2 then
            State.hoover = 0
        end
        Hooveredx, Hooveredy = math.floor(x/SQUARESIZE), math.floor(y/SQUARESIZE)
        Currentx, Currenty = x,y
    end

    local function backtomain()
        State.oldleaf = 1
        State.leaf = 1
        State.hoover = 0
        find_hoovered_button(Currentx, Currenty)
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

        local fontsize, y = translatexy(SMALLFONT,SMALLFONT)
        SmallFont = gfx.newFont(fontsize)
        fontsize, y = translatexy(BIGFONT, BIGFONT)
        BigFont = gfx.newFont(fontsize)

        local newgamebuttonw, newgamebuttonh = translatexy(0.25, 0.07)
        local newbuttonstartw, newbuttonstarth = translatexy(0.5, 0.3)
        local wt, newgamebuttonpadding = translatexy(0.5, 0.02)

        Buttons = {{}}
        Buttons[1] = {{text="Continue", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth, width = newgamebuttonw, height=newgamebuttonh, call = continuegame}, {text="New Game", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+newgamebuttonh+newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = newgame},{text="Save Game", x = ScreenWidth/2.0-newgamebuttonw/2.0, y =  newbuttonstarth+2*newgamebuttonh+2*newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = savegame}, {text="Load Game", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+3*newgamebuttonh+3*newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = loadgame}, {text="Help", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+4*newgamebuttonh+4*newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = helpwindow}, {text="Quit", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+5*newgamebuttonh+5*newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = quitgame}}

        local newbuttonwidth, newbuttonheight = translatexy(0.2,0.05)
        local paddingx, paddingy = translatexy(0.01,0.01)
        local startpaddingx, startpaddingy = translatexy(0.1,0.1)
        Buttons[2] = {
            {text="Generate Houses", x = 0, y = startpaddingy, width = newbuttonwidth, height=newbuttonheight, call = generate_map},
            {text="Generate River", x = 0, y = newbuttonheight+paddingy+startpaddingy, width = newbuttonwidth, height=newbuttonheight, call = generate_map},
            {text="Exit to Main", x = 0, y = 2*newbuttonheight+2*paddingy+startpaddingy, width = newbuttonwidth, height=newbuttonheight, call = backtomain},
        }

        Buttons[3] = {{}}
        Buttons[4] = {{}}

        local helpbuttonw, helpbuttonh = translatexy(0.3, 0.07)
        local helpbuttonstartx, helpbuttonstarty = translatexy(0, 0.1)
        local centeredx = ScreenWidth/2.0-helpbuttonw/2.0
        Buttons[5] = {{text="Back to Main", x = centeredx, y = helpbuttonstarty, width = helpbuttonw, height=helpbuttonh, call = backtomain}, {text="Scroll Up", x = centeredx, y = helpbuttonstarty+helpbuttonh, width = helpbuttonw, height=helpbuttonh, call = scrollhelpup}, {text="Scroll Down", x = centeredx, y = helpbuttonstarty+10*helpbuttonh, width = helpbuttonw, height=helpbuttonh, call = scrollhelpdown}}

        local commandlinewidth=ScreenWidth/1.4
        CommandLine = {width=commandlinewidth, height=SmallFont:getHeight("debug"), x=ScreenWidth/2.0-commandlinewidth/2.0, y=ScreenHeight-ScreenHeight/10.0, button=gfx.newImage("graphics/enterbutton.png"), color = {1, 1, 1, 1}, focusedcolor = {0.2, 0.2, 0.2, 1}, focuspostfix="x_", focusswitch = true, focustime=0.7, focusmax = 0.7, text="dr"}
        
        State = {leaf = 1, oldleaf = 1, hoover = 0, logo = gfx.newImage("graphics/logo.png"), bg = gfx.newImage("graphics/100.jpg"), banner = gfx.newImage("graphics/banner.png"), bannerx = gfx.newImage("graphics/red.png"), bannerm = gfx.newImage("graphics/yellow.png"), helpbg = gfx.newImage("graphics/forest.png"), helppadding = ScreenWidth*0.2*0.1, savedhelpprefix=0, xprefix=0, yprefix=0, charleft = gfx.newImage("graphics/charleft.png"), charrigth = gfx.newImage("graphics/charright.png")}
        -- leaf 1 = main menu, 2 = new game,

        Hooveredx, Hooveredy = 0, 0

        Tiles={
            {i = 1, name="Sparse grass", file = gfx.newImage("graphics/sparse_grass.png"), obstacle = false},
            {i = 2, name="Dense grass", file = gfx.newImage("graphics/dense_grass.png"), obstacle = false},
            {i = 3, name="Wooden wall", file = gfx.newImage("graphics/wooden_wall.png"), obstacle = true},
            {i = 4, name="Wooden floor", file = gfx.newImage("graphics/wooden_floor.png"), obstacle = false},
            {i = 5, name="River", file = gfx.newImage("graphics/river.png"), obstacle = false},
            {i = 6, name="Water", file = gfx.newImage("graphics/water.jpg"), obstacle = false}
        }
        --for i=0, 999 do
            MapTotal = generate_map()
        --end
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

        CommandLine.focustime = CommandLine.focustime - 1/FPS
        if CommandLine.focustime < 0 then
            CommandLine.focustime= CommandLine.focusmax
            if CommandLine.focusswitch == true then
                CommandLine.focusswitch = false
            else
                CommandLine.focusswitch = true
            end
        end
        if State.hoover ~= -2 then
            if love.keyboard.isDown('w') then
                if State.leaf == 2 then
                    State.yprefix = math.floor(State.yprefix - SCROLLLINESMAP)
                    if State.yprefix < 0 then
                        State.yprefix = 0
                    end
                end
            end
            if love.keyboard.isDown('s') then
                if State.leaf == 2 then
                    State.yprefix = math.floor(State.yprefix + SCROLLLINESMAP)
                    local check = math.floor(#Save.map[1]-ScreenHeight/SQUARESIZE)
                    if State.yprefix > check then
                        State.yprefix = check
                    end
                end
            end
            if love.keyboard.isDown('a') then
                if State.leaf == 2 then
                    State.xprefix = math.floor(State.xprefix - SCROLLLINESMAP)
                    if State.xprefix < 0 then
                        State.xprefix = 0
                    end
                end
            end
            if love.keyboard.isDown('d') then
                if State.leaf == 2 then
                    State.xprefix = math.floor(State.xprefix + SCROLLLINESMAP)
                    local check = math.floor(#Save.map-ScreenWidth/SQUARESIZE)
                    if State.xprefix > check then
                        State.xprefix = check
                    end
                end
            end
        end

        local timeout = 1.0/FPS - dt
        if timeout < 0 then
            timeout = 0
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
        elseif State.leaf == 2 then
            local xamount = math.floor(ScreenWidth/SQUARESIZE)
            local yamount = math.floor(ScreenHeight/SQUARESIZE)
            for i=1, xamount do
                for j=1, yamount do
                    gfx.setColor(255, 255, 255, 255)
                    gfx.push()
                    local imagefile = Tiles[Save.map[i+State.xprefix][j+State.yprefix]].file
                    local scale = ScreenWidth/xamount/imagefile:getWidth()
                    gfx.scale(scale, scale)
                    gfx.draw(imagefile, (i-1)*SQUARESIZE/scale,(j-1)*SQUARESIZE/scale)
                    gfx.pop()
                end
            end
            gfx.setFont(BigFont)
            gfx.setColor(1,1,1)
            local padx, pady = translatexy(0.02, 0.05)
            for i=0, 2 do
                gfx.print("Use W, S, A, D", padx, pady)
            end
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

        print_to_debug(ScreenWidth.."x"..ScreenHeight..", vsync="..love.window.getVSync()..", fps="..love.timer.getFPS()..", mem="..string.format("%.3f", collectgarbage("count")/1000.0).."MB, mapnumber="..MapTotal..", randomseed="..Randomseed..", mousehoover="..Tiles[Save.map[State.xprefix+Hooveredx+1][State.yprefix+Hooveredy+1]].name)
    end
end
