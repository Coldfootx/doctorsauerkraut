SCREENSPACE = 0.88
SMALLFONT = 0.0125
BIGFONT = 0.02
BIGSQUARESCALE = 1.3
BANNERH = 0.045
LOGOW = 0.5
ALCHEMYWINDOWSIZE = 1/1.5 -- times ScreenWidth and ScreenHeight, suorakulmio ei nelio

MAP_W = 512
MAP_H = 512
SMALLFONTDRAWS = 3
SCROLLLINESMAP = 2
SCROLLLINES = 9
SQUAREAMOUNT = 20

FPS = 75
WALKSPEED = 1/FPS*10

HOUSEAMOUNT = math.floor(MAP_W*0.5859375) --- 512 is 300
RIVERAMOUNT = math.floor(MAP_W*0.015) --512 is 7
RIVERWIDTH = 5
HOUSESIZE = 10
HOUSESIZEVARY = 5
LAKESIZE = 30
LAKESIZEVARY = 10
LAKEAMOUNT = math.floor(MAP_W*0.02)
FLOWERAMOUNT = math.floor(MAP_W*0.5)*100
ROADAMOUNT = math.floor(MAP_W*0.022) -- both roads use this so its times two basically 1080/

SAVEFILE = "savefile" -- +n
COMPRESSION = "zlib"
RANDOMNESSFILE = "randomness"
SAVENAMEFILE = "savenames"
SAVEFILEAMOUNT = 10

--STATEMENTS
STARTING_RANDOMNESS = 300

HELP_TEXT = 'Look at folder %APPDATA%/LOVE to save some space! This folder is \nfor starting directly from code.\n \nAnd look at folder %APPDATA%/gamename or simply /game. This folder is \nfor starting from the compiled executable.\n \nIf you delete the file "randomness" it is regenerated but edit its \ncontained number to avoid same map generation. Ideally it should be \naccumulating forever to avoid them.\n\nIn Linux look for these\n$XDG_DATA_HOME/love/ or ~/.local/share/love/\nlove may be replaced by game name or simply "game"\n\n\nAND NOW FOR LICENSES\n\n\nAdditional licenses not mentioned in the license file in the game folder \nand folder love in the source distribution\n\n\nThis game\nby Purlov\nnewest GPL\nhttps://www.gnu.org/licenses/gpl-3.0.html\n\n\n----Libraries----\n\n\nlume\nA collection of functions for Lua, geared towards game development.\nUsing it for serializing data before compression.\nhttps://github.com/rxi/lume\nMIT \n--\n-- lume\n--\n-- Copyright (c) 2020 rxi\n--\n-- Permission is hereby granted, free of charge, to any person obtaining a copy of\n-- this software and associated documentation files (the "Software"), to deal in\n-- the Software without restriction, including without limitation the rights to\n-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies\n-- of the Software, and to permit persons to whom the Software is furnished to do\n-- so, subject to the following conditions:\n--\n-- The above copyright notice and this permission notice shall be included in all\n-- copies or substantial portions of the Software.\n--\n-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n-- SOFTWARE.\n--\n\n\n----Graphics----\n\n\nBackground love potion - graphics/potion.jpg\nhttps://en.wikipedia.org/wiki/File:Filtre_d%27Amour.jpg\nFrom user https://commons.wikimedia.org/wiki/User:Arnaud_25 - Arnaud_25\nCreative Commons Attribution-Share Alike 4.0 International\nhttps://creativecommons.org/licenses/by-sa/4.0/deed.en\n\n\nWater tile - graphics/water.jpg\nhttps://opengameart.org/content/texture-water\nFrom user www.GodsAndIdols.com and https://opengameart.org/users/jattenalle\nCC-BY 3.0\nhttps://creativecommons.org/licenses/by/3.0/\n\n\nFlower tiles - graphics/flower%n.png\nI changed their colours somewhat\nhttps://opengameart.org/content/pixel-flower-icons\nFrom user https://opengameart.org/users/sicklyseraph - sicklyseraph\nCC-BY 4.0\nhttps://creativecommons.org/licenses/by/4.0/\n\n\nRoad textures - graphics/road.png\nI am using the desert one\nhttps://opengameart.org/content/road-textures\nFrom user https://opengameart.org/users/dakal - dakal\nCC-BY-SA 3.0\nhttps://creativecommons.org/licenses/by-sa/3.0/\n\n\nRed outfit for main character - graphics/charright & left.png\nhttps://opengameart.org/content/occupational-icons\nFrom user https://opengameart.org/users/technopeasant - technopeasant\nTiles have been drawn by David E. Gervais, and are published under the Creative \nCommons license. You are free to copy, distribute and transmit those tiles \nas long as you credit David Gervais as their creator.\nCC-BY 3.0\nhttp://creativecommons.org/licenses/by/3.0/\n\n\nA sand road - graphics/road2.png\nhttps://opengameart.org/content/pixel-art-top-down-tileset\nFrom user https://opengameart.org/users/dustdfg - Yevhen Babiichuk (DustDFG)\nCC-BY-SA 4.0\nhttps://creativecommons.org/licenses/by-sa/4.0/\n\n\nGold stuff in the Main Menu background\nby Bonsaiheldin\nPublic Domain'

do
    local love = require("love")
    local lume = require("lib.lume")
    local utf8 = require("utf8")

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
        Save.positionx = State.xprefix + math.floor(ScreenWidth/SQUAREAMOUNT/2)
        Save.positiony = State.yprefix + math.floor(ScreenHeight/SQUAREAMOUNT/2)

        local compressed = love.data.compress("string", COMPRESSION, lume.serialize(Save), 9)

        love.filesystem.write(SAVEFILE..save_number, compressed)
    end

    local function debugbox(value)
        love.window.showMessageBox("Debug Info", value, {"OK"}, "info", true)
    end

    local function load_file(save_number)
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

    local function change_page(n)
        State.oldleaf = State.leaf
        State.leaf = n
        State.hoover = 0
        State.waitingforsavename = false
        State.waitingforalchcombine = false
        State.waitingforalchremove = false
        find_hoovered_button(Currentx, Currenty)
    end

    local function save_game()
        change_page(3)
    end

    local function save_file(i)
        local pressedbutton = love.window.showMessageBox("Want to save slot "..i.."?", "Old data will be lost.", {"OK", "No!", enterbutton = 2}, "warning", true)
        if pressedbutton == 1 then
            debugbox("Close this dialog, Press ENTER, Write Name, Press ENTER - Slot "..i)
            State.waitingforsavename = true
            State.waitingforsavename_n = i
        end
    end

    local function calculate_prefix(px, py)
        State.xprefix = px-math.floor(ScreenWidth/SQUAREAMOUNT/2)
        State.yprefix = py-math.floor(ScreenHeight/SQUAREAMOUNT/2)
    end

    local function randomlocation()
        local px, py
        repeat
            px = randomgen:random(MAP_W-RIVERWIDTH-1)
            py = randomgen:random(MAP_H)
        until Tiles[Save.map[px][py]].obstacle == false
        calculate_prefix(px,py)
    end

    local function moveoffset(x,y)

    end

    local function format_map()
        local map = {}
        for i=1,MAP_W do
            map[i] = {}     -- create x
            for j=1,MAP_H do
                map[i][j] = randomgen:random(2)
            end
        end
        return map
    end

    local function generate_map()
        local map = format_map()

        for n = 1, LAKEAMOUNT do
            -- This code is partly contributed by chandan_jnu
            local rx = randomgen:random(LAKESIZE-LAKESIZEVARY, LAKESIZE+LAKESIZEVARY)
            local ry = randomgen:random(LAKESIZE-LAKESIZEVARY, LAKESIZE+LAKESIZEVARY)
            local xc = randomgen:random(1,MAP_W)
            local yc = randomgen:random(1,MAP_H)

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

            local obstacle = false
            if endpointx > MAP_W then
                endpointx = MAP_W
            end
            if endpointy > MAP_H then
                endpointy = MAP_H
            end
            for i=housex, endpointx do
                if map[i][housey] ==6 or map[i][endpointy] == 6 then
                    obstacle = true
                end
                for y = housey+1, endpointy-1 do
                    for x = i+1, i+endpointx-1 do
                        if map[i][y] == 6 then
                            obstacle = true
                        end
                    end
                end
            end

            if obstacle == false then

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
                local whichwall = randomgen:random(4)
                if whichwall == 1 then
                    local along = randomgen:random(housey+1, endpointy-1)
                    map[housex][along] = 4
                elseif whichwall == 2 then
                    local along = randomgen:random(housey+1, endpointy-1)
                    local position = math.min(housex+housew, endpointx)
                    map[position][along] = 4
                elseif whichwall == 3 then
                    local along = randomgen:random(housex+1, endpointx-1)
                    map[along][housey] = 4
                elseif whichwall == 4 then
                    local along = randomgen:random(housex+1, endpointx-1)
                    local position = math.min(housey+househ, endpointy)
                    map[along][housey] = 4
                end
            end
        end

        for n=1,RIVERAMOUNT do
            local xposition = randomgen:random(1,MAP_W)
            local yposition = 1
            for j = yposition, MAP_H do
                local amountfree = 0
                for i = xposition, MAP_W do
                    if Tiles[map[i][j]].obstacle == false or map[i][j] == 6 then
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

        for n=1, FLOWERAMOUNT do
            local fx = randomgen:random(MAP_W)
            local fy = randomgen:random(MAP_H)
            if Tiles[map[fx][fy]].obstacle == false and map[fx][fy] ~= 4 then
                local choice = randomgen:random(6)
                if choice == 1 then
                    map[fx][fy] = 7
                elseif choice == 2 then
                    map[fx][fy] = 8
                elseif choice == 3 then
                    map[fx][fy] = 11
                elseif choice == 4 then
                    map[fx][fy] = 12
                elseif choice == 5 then
                    map[fx][fy] = 13
                elseif choice == 6 then
                    map[fx][fy] = 14
                end
            end
        end

        for amount=1, ROADAMOUNT do
            local random = randomgen:random(4)
            local cx
            local cy
            local suunta
            if random == 1 then
                cx = 1
                cy = randomgen:random(MAP_H-1)
                suunta = 1
            elseif random == 2 then
                cx = MAP_W-1
                cy = randomgen:random(MAP_H-1)
                suunta = -1
            elseif random == 3 then
                cx = randomgen:random(MAP_W-1)
                cy = 1
                suunta = 2
            elseif random == 4 then
                cx = randomgen:random(MAP_W-1)
                cy = MAP_H-1
                suunta = -2
            end

            local function randomsuunta()
                local random = randomgen:random(4)
                local suunta
                if random == 1 then
                    suunta = 1
                elseif random == 2 then
                    suunta = -1
                elseif random == 3 then
                    suunta = 2
                elseif random == 4 then
                    suunta = -2
                end
                return suunta
            end

            for n=1, 999999 do
                if suunta == 1 then
                    local cxtest = math.min(cx+1, MAP_W)
                    if Tiles[map[cxtest][cy]].obstacle == false then
                        cx = cxtest
                        map[cx][cy] = 9
                    else
                        suunta = randomsuunta()
                    end
                elseif suunta == -1 then
                    local cxtest = math.max(cx-1, 1)
                    if Tiles[map[cxtest][cy]].obstacle == false then
                        cx = cxtest
                        map[cx][cy] = 9
                    else
                        suunta = randomsuunta()
                    end
                elseif suunta == 2 then
                    local cytest = math.min(cy+1, MAP_H)
                    if Tiles[map[cx][cytest]].obstacle == false then
                        cy = cytest
                        map[cx][cy] = 9
                    else
                        suunta = randomsuunta()
                    end
                elseif suunta == -2 then
                    local cytest = math.max(cy-1, 1)
                    if Tiles[map[cx][cytest]].obstacle == false then
                        cy = cytest
                        map[cx][cy] = 9
                    else
                        suunta = randomsuunta()
                    end
                end
            end
        end

        --second road
        for amount=1, ROADAMOUNT do
            local random = randomgen:random(4)
            local cx
            local cy
            local suunta
            if random == 1 then
                cx = 1
                cy = randomgen:random(MAP_H-1)
                suunta = 1
            elseif random == 2 then
                cx = MAP_W-1
                cy = randomgen:random(MAP_H-1)
                suunta = -1
            elseif random == 3 then
                cx = randomgen:random(MAP_W-1)
                cy = 1
                suunta = 2
            elseif random == 4 then
                cx = randomgen:random(MAP_W-1)
                cy = MAP_H-1
                suunta = -2
            end

            local function randomsuunta()
                local random = randomgen:random(4)
                local suunta
                if random == 1 then
                    suunta = 1
                elseif random == 2 then
                    suunta = -1
                elseif random == 3 then
                    suunta = 2
                elseif random == 4 then
                    suunta = -2
                end
                return suunta
            end

            for n=1, 999999 do
                if suunta == 1 then
                    local cxtest = math.min(cx+1, MAP_W)
                    if Tiles[map[cxtest][cy]].obstacle == false then
                        cx = cxtest
                        map[cx][cy] = 10
                    else
                        suunta = randomsuunta()
                    end
                elseif suunta == -1 then
                    local cxtest = math.max(cx-1, 1)
                    if Tiles[map[cxtest][cy]].obstacle == false then
                        cx = cxtest
                        map[cx][cy] = 10
                    else
                        suunta = randomsuunta()
                    end
                elseif suunta == 2 then
                    local cytest = math.min(cy+1, MAP_H)
                    if Tiles[map[cx][cytest]].obstacle == false then
                        cy = cytest
                        map[cx][cy] = 10
                    else
                        suunta = randomsuunta()
                    end
                elseif suunta == -2 then
                    local cytest = math.max(cy-1, 1)
                    if Tiles[map[cx][cytest]].obstacle == false then
                        cy = cytest
                        map[cx][cy] = 10
                    else
                        suunta = randomsuunta()
                    end
                end
            end
        end

        Save.map = map

        randomlocation()
    end

    local function init_save()
        --initialize savedata
        local map = {}
        for i=1,MAP_W do
            map[i] = {}
            for j=1,MAP_H do
                map[i][j] = 1
            end
        end
        Save = {map=map, npcs={}, positionx = 1, positiony = 1, alchinventory = {}}
    end

    local function newgame()
        local pressedbutton = love.window.showMessageBox("Remember to save map first", "Entering new game formats the current map in memory. Want to continue?", {"OK", "No!", enterbutton = 2}, "warning", true)
        if pressedbutton == 1 then
            init_save()
            change_page(2)
        end
        
    end

    local function loadgame()
        change_page(4)
    end

    local function continuegame()
        change_page(6)
    end

    local function refreshalchinventory()
        if #Save.alchinventory == 0 then
            State.printingalchinventorytext = "Empty Alchemy Bag"
        else
            State.printingalchinventorytext = ""
            for i=1, #Save.alchinventory do
                if Save.alchinventory[i] ~= 0 then
                    State.printingalchinventorytext = State.printingalchinventorytext..i..". "..AlchItems[Save.alchinventory[i]].name.."\n"
                end
            end
        end
        State.printingalchinventory = true
    end

    local function newalchemy()
        refreshalchinventory()
        change_page(7)
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
        local nstring = table.concat(sliced, "\n")
        State.savedhelpprefix = prefix
        return nstring
    end

    local function helpwindow()
        change_page(5)
        State.help_text = load_help_text(State.savedhelpprefix)
    end

    local function quitgame()
        quitmessage()
    end

    local function save_n(n)
        savefile(n)
        Buttons[3][n].text = CommandLine.text
        Buttons[4][n].text = CommandLine.text
        local names = {}
        for i = 1, SAVEFILEAMOUNT do
            names[i] = Buttons[3][i].text
        end
        love.filesystem.write(SAVENAMEFILE, lume.serialize(names))
        debugbox("Saved!")
    end

    local function load_n(n)
        if love.filesystem.getInfo(SAVEFILE..n) == nil then
            debugbox("Unloaded Save File")
        else
            local pressedbutton = love.window.showMessageBox("Lose all data when loading", "Loading a game formats the current memory. Want to continue?", {"OK", "No!", enterbutton = 2}, "warning", true)
            if pressedbutton == 1 then
                load_file(n)
                calculate_prefix(Save.positionx, Save.positiony)
                debugbox("Loaded!")
                change_page(6)
            end
        end
    end

    local function has_value (tab, val)
        for index, value in ipairs(tab) do
            if value == val then
                return true
            end
        end
    
        return false
    end
    

    function love.keypressed(key, scancode, isrepeat)
        if State.hoover >= 0 then
            if key == "return" then
                State.hoover = -2
            end
        elseif key == "return" and State.hoover == -2 then
            if State.waitingforsavename == true then
                save_n(State.waitingforsavename_n)
                State.waitingforsavename = false
            elseif State.waitingforalchcombine == true then
                local first = true
                local text = ""
                local usedlocs = {}
                for i in string.gmatch(CommandLine.text, "%d+") do
                    if first == true then
                        text = i.."."
                        first = false
                        table.insert(usedlocs, i)
                    elseif has_value(usedlocs, i) == false then
                        text = text.." + "..i.."."
                        table.insert(usedlocs, i)
                    end
                end
                debugbox(text)
                State.printingalchinventorytext = "\n\n\n\n\n\n"..text
                State.waitingforalchcombine = false
            end
        elseif key == "backspace"and State.hoover == -2 then
            if string.len(CommandLine.text) > 0 then
                CommandLine.text = CommandLine.text:sub(1,utf8.offset(CommandLine.text, -1)-1)
            end
        end
    end

    function love.keyreleased(key, scancode, isrepeat)
        if  key == "escape" then
            if State.leaf == 1 and State.oldleaf == 1 then
                quitmessage()
            else
                change_page(State.oldleaf)
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
            gfx.print(text, width, height)
        end
    end

    local function generate_npc()
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
        Hooveredx, Hooveredy = math.floor(x/SQUAREAMOUNT), math.floor(y/SQUAREAMOUNT)
        Currentx, Currenty = x,y
    end

    local function backtomain()
        change_page(1)
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

    local function getposfromhoover()
        local posx = math.min(math.max(State.xprefix+Hooveredx,1), MAP_W)
        local posy = math.min(math.max(State.yprefix+Hooveredy,1), MAP_H)
        return posx, posy
    end

    local function startalchcombine()
        State.waitingforalchcombine=true
        debugbox("Close this dialog. Hit enter. Type number+number+number+.. . Hit enter.")
    end

    local function startalchremove()
        State.waitingforalchremove= true
        debugbox("Close this dialog. Hit enter. Type the number to delete. Hit enter.")
    end

    local function alchcollect()
        local centerw = math.floor(ScreenWidth/SQUAREAMOUNT/2)
        local centerh = math.floor(ScreenHeight/SQUAREAMOUNT/2)
        for n=1,#TilestoAlch do
            local tile = Save.map[State.xprefix+centerw][math.max(State.yprefix+centerh)]
            if tile == TilestoAlch[n][1] then
                table.insert(Save.alchinventory, TilestoAlch[n][2])
                if AlchItems[TilestoAlch[n][2]].obstacle == false then
                    Save.map[State.xprefix+centerw][math.max(State.yprefix+centerh)] = 1
                end
                refreshalchinventory()
            end
        end
    end

    local function alchscrollup()
    end

    local function alchscrolldown()
    end

    function love.load()
        love.window.setVSync(1)
        love.window.setTitle("Doctor Sauerkraut")
        love.keyboard.setKeyRepeat(true)
        ScreenWidth, ScreenHeight = love.window.getDesktopDimensions()
        ScreenWidth, ScreenHeight = ScreenWidth*SCREENSPACE, ScreenHeight*SCREENSPACE
        love.window.setMode(ScreenWidth, ScreenHeight, {resizable =false, borderless= true, y=ScreenHeight*(1-SCREENSPACE)/2.0, x=ScreenWidth*(1-SCREENSPACE)/2.0})
        Canvas = gfx.newCanvas(ScreenWidth, ScreenHeight)

        init_save()

        local fontsize, y = translatexy(SMALLFONT,SMALLFONT)
        SmallFont = gfx.newFont(fontsize)
        fontsize, y = translatexy(BIGFONT, BIGFONT)
        BigFont = gfx.newFont(fontsize)

        local newgamebuttonw, newgamebuttonh = translatexy(0.25, 0.07)
        local newbuttonstartw, newbuttonstarth = translatexy(0.5, 0.3)
        local wt, newgamebuttonpadding = translatexy(0.5, 0.02)

        Buttons = {{}}
        Buttons[1] = {{size=1, text="Continue", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth, width = newgamebuttonw, height=newgamebuttonh, call = continuegame}, {size=1, text="New Game", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+newgamebuttonh+newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = newgame},{size=1, text="Save Game", x = ScreenWidth/2.0-newgamebuttonw/2.0, y =  newbuttonstarth+2*newgamebuttonh+2*newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = save_game}, {size=1, text="Load Game", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+3*newgamebuttonh+3*newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = loadgame}, {size=1, text="Help", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+4*newgamebuttonh+4*newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = helpwindow}, {size=1, text="Quit", x = ScreenWidth/2.0-newgamebuttonw/2.0, y = newbuttonstarth+5*newgamebuttonh+5*newgamebuttonpadding, width = newgamebuttonw, height=newgamebuttonh, call = quitgame}}

        local newbuttonwidth, newbuttonheight = translatexy(0.2,0.05)
        local paddingx, paddingy = translatexy(0.01,0.01)
        local startpaddingx, startpaddingy = translatexy(0.1,0.1)
        Buttons[2] = {
            {size=1, text="Generate MAP", x = 0, y = startpaddingy, width = newbuttonwidth, height=newbuttonheight, call = generate_map},
            {size=1, text="Save MAP", x = 0, y = newbuttonheight+paddingy+startpaddingy, width = newbuttonwidth, height=newbuttonheight, call = save_game},
            {size=1, text="Back to Main", x = 0, y = 2*newbuttonheight+2*paddingy+startpaddingy, width = newbuttonwidth, height=newbuttonheight, call = backtomain},
        }

        Buttons[3] = {{}}
        local buttonwidth, buttonheight = translatexy(0.2, 0.05)
        local continuebuttonx, continuebuttony = translatexy(0.18, 0.035)
        local buttonpadding, __ = translatexy(0.01, 0)
        for i = 1, SAVEFILEAMOUNT do
            Buttons[3][i] = {size=1, text="Empty MAP File "..i, x = continuebuttonx, y = continuebuttony+buttonheight*i+buttonpadding*i, width = buttonwidth, height=buttonheight, call = save_file}
        end
        local amount = SAVEFILEAMOUNT+1
        Buttons[3][amount] = {size=1, text="Back to Main", x = continuebuttonx, y = continuebuttony+buttonheight*amount+buttonpadding*amount, width = buttonwidth, height=buttonheight, call = backtomain}

        Buttons[4] = {{}}
        buttonwidth, buttonheight = translatexy(0.2, 0.05)
        continuebuttonx, continuebuttony = translatexy(0.18, 0.035)
        buttonpadding, __ = translatexy(0.01, 0)
        for i = 1, SAVEFILEAMOUNT do
            Buttons[4][i] = {size=1, text="Empty MAP File "..i, x = continuebuttonx, y = continuebuttony+buttonheight*i+buttonpadding*i, width = buttonwidth, height=buttonheight, call = load_n}
        end
        amount = SAVEFILEAMOUNT+1
        Buttons[4][amount] = {size=1, text="Back to Main", x = continuebuttonx, y = continuebuttony+buttonheight*amount+buttonpadding*amount, width = buttonwidth, height=buttonheight, call = backtomain}

        local helpbuttonw, helpbuttonh = translatexy(0.3, 0.07)
        local helpbuttonstartx, helpbuttonstarty = translatexy(0, 0.1)
        local centeredx = ScreenWidth/2.0-helpbuttonw/2.0
        Buttons[5] = {{size=1, text="Back to Main", x = centeredx, y = helpbuttonstarty, width = helpbuttonw, height=helpbuttonh, call = backtomain}, {size=1, text="Scroll Up", x = centeredx, y = helpbuttonstarty+helpbuttonh, width = helpbuttonw, height=helpbuttonh, call = scrollhelpup}, {size=1, text="Scroll Down", x = centeredx, y = helpbuttonstarty+10*helpbuttonh, width = helpbuttonw, height=helpbuttonh, call = scrollhelpdown}}

        local gamebuttonw, gamebuttonh = translatexy(0.115, 0.03)
        local wpadding, hpadding = translatexy(0,0.15)
        Buttons[6] = {{size=2, text="Alchemy", x = 0, y = 0*gamebuttonh+hpadding, width = gamebuttonw, height=gamebuttonh, call = newalchemy}, {size=2, text="Back to Main", x = 0, y = 1*gamebuttonh+hpadding, width = gamebuttonw, height=gamebuttonh, call = backtomain}}

        local alchbuttonw, alchbuttonh = translatexy(0.13, 0.03)
        local alchwpadding, alchhpadding = translatexy(0.1,0.15)
        Buttons[7] = {
            {size=2, text="Combine", x = alchwpadding, y = 0*alchbuttonh+alchhpadding, width = alchbuttonw, height=alchbuttonh, call = startalchcombine},
            {size=2, text="Remove", x = alchwpadding, y = 1*alchbuttonh+alchhpadding, width = alchbuttonw, height=alchbuttonh, call = startalchremove},
            {size=2, text="Collect from ground", x = alchwpadding, y = 2*alchbuttonh+alchhpadding, width = alchbuttonw, height=alchbuttonh, call = alchcollect},
            {size=2, text="Inventory", x = alchwpadding, y = 3*alchbuttonh+alchhpadding, width = alchbuttonw, height=alchbuttonh, call = refreshalchinventory}, {size=2, text="Back to Game", x = alchwpadding, y = 4*alchbuttonh+alchhpadding, width = alchbuttonw, height=alchbuttonh, call = continuegame},
            {size=2, text="Scroll Up", x = alchwpadding+alchbuttonw+ScreenWidth*ALCHEMYWINDOWSIZE-alchbuttonw, y = alchhpadding, width = alchbuttonw, height=alchbuttonh, call = alchscrollup}, {size=2, text="Scroll Down", x = alchwpadding+alchbuttonw+ScreenWidth*ALCHEMYWINDOWSIZE-alchbuttonw, y = alchhpadding+ScreenHeight*ALCHEMYWINDOWSIZE-alchbuttonh, width = alchbuttonw, height=alchbuttonh, call = alchscrolldown}}

        if love.filesystem.getInfo(SAVENAMEFILE) == nil then
            local names = {}
            for n=1,SAVEFILEAMOUNT do
                names[n] = "Unloaded File "..n
            end
            love.filesystem.write(SAVENAMEFILE, lume.serialize(names))
        end
        local names = lume.deserialize(love.filesystem.read(SAVENAMEFILE))
        for n=1, SAVEFILEAMOUNT do
            Buttons[3][n].text = names[n]
            Buttons[4][n].text = names[n]
        end

        local commandlinewidth=ScreenWidth/1.4
        CommandLine = {width=commandlinewidth, height=SmallFont:getHeight("debug"), x=ScreenWidth/2.0-commandlinewidth/2.0, y=ScreenHeight-ScreenHeight/10.0, button=gfx.newImage("graphics/enterbutton.png"), color = {1, 1, 1, 1}, focusedcolor = {0.2, 0.2, 0.2, 1}, focuspostfix="x_", focusswitch = true, focustime=0.7, focusmax = 0.7, text="dr"}
        
        State = {leaf = 1, oldleaf = 1, hoover = 0, logo = gfx.newImage("graphics/logo.png"), banner = gfx.newImage("graphics/banner.png"), bannerx = gfx.newImage("graphics/red.png"), bannerm = gfx.newImage("graphics/yellow.png"), helpbg = gfx.newImage("graphics/forest.png"), helppadding = ScreenWidth*0.2*0.1, savedhelpprefix=0, xprefix=0, yprefix=0, walkingwait = WALKSPEED, charleft = gfx.newImage("graphics/charleft.png"), charright = gfx.newImage("graphics/charright.png"), charchosen = gfx.newImage("graphics/charright.png"), lovepotion=gfx.newImage("graphics/potion.jpg"), waitingforsavename = false, waitingforsavename_n = 0, printingalchinventory = false, printingalchinventorytext = "Refresh inventory", waitingforalchcombine = false, waitingforalchremove=false, alchbottle = gfx.newImage("graphics/bottle.png"), alchdoc= gfx.newImage("graphics/doc.png"), alchankh = gfx.newImage("graphics/ankh.png"), mainmenubgs = {}, mainmenubgslocation = {}, mainmenubgsamount= 10, mainmenurepeat = 10}

        for i=1,State.mainmenubgsamount do
            State.mainmenubgs[i] = gfx.newImage("graphics/mainmenu/"..i..".png")
        end

        for i=1,State.mainmenubgsamount do
            for j=1, State.mainmenurepeat do
                State.mainmenubgslocation[j+(i-1)*State.mainmenurepeat] = {i,randomgen:random(1,ScreenWidth-State.mainmenubgs[i]:getWidth()), randomgen:random(1,ScreenHeight-State.mainmenubgs[i]:getHeight())}
            end
        end

        Hooveredx, Hooveredy = 0, 0

        Tiles={
            {i = 1, name="Sparse grass", file = gfx.newImage("graphics/sparse_grass.png"), obstacle = false},
            {i = 2, name="Dense grass", file = gfx.newImage("graphics/dense_grass.png"), obstacle = false},
            {i = 3, name="Wooden wall", file = gfx.newImage("graphics/wooden_wall.png"), obstacle = true},
            {i = 4, name="Wooden floor", file = gfx.newImage("graphics/wooden_floor.png"), obstacle = false},
            {i = 5, name="River", file = gfx.newImage("graphics/river.png"), obstacle = false},
            {i = 6, name="Water", file = gfx.newImage("graphics/water.jpg"), obstacle = true},
            {i = 7, name="Purple flower", file = gfx.newImage("graphics/flower1.png"), obstacle = false},
            {i = 8, name="Light blue flower", file = gfx.newImage("graphics/flower2.png"), obstacle = false},
            {i = 9, name="Sand road", file = gfx.newImage("graphics/road.png"), obstacle = false},
            {i = 10, name="Dark sand road", file = gfx.newImage("graphics/road2.png"), obstacle = false},
            {i = 11, name="Red flower", file = gfx.newImage("graphics/flower3.png"), obstacle = false},
            {i = 12, name="Yellow flower", file = gfx.newImage("graphics/flower4.png"), obstacle = false},
            {i = 13, name="Pink flower", file = gfx.newImage("graphics/flower5.png"), obstacle = false},
            {i = 14, name="White flower", file = gfx.newImage("graphics/flower6.png"), obstacle = false}
        }

        TilestoAlch = {
            {7,1},
            {8,2},
            {11,3},
            {12,4},
            {13,5},
            {14,6},
            {5,7}
        }

        AlchItems={
            {i = 1, name="Purple flower", file = gfx.newImage("graphics/sparse_grass.png"), obstacle = false},
            {i = 2, name="Light blue flower", file = gfx.newImage("graphics/dense_grass.png"), obstacle = false},
            {i = 3, name="Red flower", file = gfx.newImage("graphics/wooden_wall.png"), obstacle = false},
            {i = 4, name="Yellow flower", file = gfx.newImage("graphics/wooden_floor.png"), obstacle = false},
            {i = 5, name="Pink flower", file = gfx.newImage("graphics/river.png"), obstacle = false},
            {i = 6, name="White flower", file = gfx.newImage("graphics/water.jpg"), obstacle = false},
            {i = 7, name="Water", file = gfx.newImage("graphics/water.jpg"), obstacle = true}
        }

        NPC_tiles ={
            {i = 1, name="Skeleton", file = gfx.newImage("graphics/sparse_grass.png")},
            {i = 2, name="Dense grass", file = gfx.newImage("graphics/dense_grass.png")},
            {i = 3, name="Dense grass", file = gfx.newImage("graphics/dense_grass.png")}
        }

        randomlocation()
        --jata magneetti
        --for i=0, 999 do
        --    MapTotal = generate_map()
        --end
    end

    function love.mousereleased(x, y, button, istouch, presses)
        if button == 1 and State.hoover > 0 then
            if State.leaf == 3 or State.leaf == 4 then
                Buttons[State.leaf][State.hoover].call(State.hoover)
            else
                Buttons[State.leaf][State.hoover].call()
            end
        elseif x > CommandLine.x and x < CommandLine.x + CommandLine.width and y > CommandLine.y and y < CommandLine.y + CommandLine.height then
            State.hoover = -2
        elseif x > ScreenWidth-ScreenHeight*BANNERH and x < ScreenWidth and y > 0 and y < ScreenHeight*BANNERH then
            if State.hoover == -2 then
                State.hoover = 0
            else
                quitmessage()
            end
        elseif x > ScreenWidth-2*ScreenHeight*BANNERH and x < ScreenWidth-ScreenHeight*BANNERH and y > 0 and y < ScreenHeight*BANNERH then
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
        love.timer.sleep(timeout)

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
            if State.leaf == 2 then
                if love.keyboard.isDown('w') then
                    State.yprefix = math.floor(State.yprefix - SCROLLLINESMAP)
                    if State.yprefix < 0 then
                        State.yprefix = 0
                    end
                end
                if love.keyboard.isDown('s') then
                    State.yprefix = math.floor(State.yprefix + SCROLLLINESMAP)
                    local check = math.floor(#Save.map[1]-ScreenHeight/SQUAREAMOUNT)
                    if State.yprefix > check then
                        State.yprefix = check
                    end
                end
                if love.keyboard.isDown('a') then
                    State.xprefix = math.floor(State.xprefix - SCROLLLINESMAP)
                    if State.xprefix < 0 then
                        State.xprefix = 0
                    end
                end
                if love.keyboard.isDown('d') then
                    State.xprefix = math.floor(State.xprefix + SCROLLLINESMAP)
                    local check = math.floor(#Save.map-ScreenWidth/SQUAREAMOUNT)
                    if State.xprefix > check then
                        State.xprefix = check
                    end
                end
            elseif State.leaf == 6 then
                State.walkingwait = State.walkingwait - dt
                if State.walkingwait < 0 then
                    State.walkingwait = WALKSPEED
                    local centerw = math.floor(ScreenWidth/SQUAREAMOUNT/2)
                    local centerh = math.floor(ScreenHeight/SQUAREAMOUNT/2)
                    if love.keyboard.isDown('w') then
                        if Tiles[Save.map[State.xprefix+centerw][math.max(State.yprefix+centerh-1, 1)]].obstacle == false then
                            State.yprefix = math.max(State.yprefix - 1,-centerh+1)
                        end
                    end
                    if love.keyboard.isDown('s') then
                        if Tiles[Save.map[State.xprefix+centerw][math.min(State.yprefix+centerh+1,MAP_H)]].obstacle == false then
                            State.yprefix = math.min(State.yprefix + 1, MAP_H-centerh-1)
                        end
                    end
                    if love.keyboard.isDown('a') then
                        if Tiles[Save.map[math.max(State.xprefix+centerw-1, 1)][State.yprefix+centerh]].obstacle == false then
                            State.xprefix = math.max(State.xprefix - 1,-centerw+1)
                            State.charchosen = State.charleft
                        end
                    end
                    if love.keyboard.isDown('d') then
                        if Tiles[Save.map[math.min(State.xprefix+centerw+1, MAP_W)][State.yprefix+centerh]].obstacle == false then
                            State.xprefix = math.min(State.xprefix + 1,MAP_W-centerw-1)
                            State.charchosen = State.charright
                        end
                    end
                end
            end
        end
    end

    function love.textinput(text)
        if State.hoover == -2 then
            CommandLine.text = CommandLine.text..text
        end
    end

    function love.draw()
        gfx.setCanvas(Canvas)
        if State.leaf == 1 then
            gfx.setColor(0.7,0.1,0.1)
            gfx.rectangle("fill", 0, 0, ScreenWidth, ScreenHeight)
            gfx.setColor(255, 255, 255, 255)
            local iconsize, __ = translatexy(0.002, 0)
            gfx.push()
            gfx.scale(iconsize, iconsize)
            for i=1,State.mainmenubgsamount do
                for j=1, State.mainmenurepeat do
                    gfx.draw(State.mainmenubgs[i], State.mainmenubgslocation[j+(i-1)*State.mainmenurepeat][2]/iconsize, State.mainmenubgslocation[j+(i-1)*State.mainmenurepeat][3]/iconsize)
                end
            end
            gfx.pop()
            gfx.push()
            local _, my = translatexy(0, 0.1)
            local scale = ScreenWidth*LOGOW/State.logo:getWidth()
            gfx.scale(scale, scale)
            gfx.draw(State.logo, ScreenWidth/scale/2-State.logo:getWidth()/2, my)
            gfx.pop()
        elseif State.leaf == 2 then
            local xamount = math.floor(ScreenWidth/SQUAREAMOUNT)+1
            local yamount = math.floor(ScreenHeight/SQUAREAMOUNT)+1
            gfx.setColor(255, 255, 255, 255)
            for i=1, xamount do
                for j=1, yamount do
                    gfx.push()
                    local imagefile = Tiles[Save.map[math.min(math.max(1,i+State.xprefix-1),MAP_W)][math.min(math.max(1,j+State.yprefix-1),MAP_H)]].file
                    local scale = ScreenWidth/xamount/imagefile:getWidth()
                    gfx.scale(scale, scale)
                    gfx.draw(imagefile, (i-1)*SQUAREAMOUNT/scale,(j-1)*SQUAREAMOUNT/scale)
                    gfx.pop()
                end
            end
            gfx.setFont(BigFont)
            gfx.setColor(1,1,1)
            local padx, pady = translatexy(0.02, 0.05)
            for i=0, 2 do
                gfx.print("Use W, S, A, D - Don't start on a lake", padx, pady)
            end
        elseif State.leaf == 3 then
            gfx.setColor(0.1,0.45,0.1)
            gfx.rectangle("fill", 0, 0, ScreenWidth, ScreenHeight)
            gfx.setColor(255, 255, 255, 255)
            gfx.push()
            local imagefile = State.lovepotion
            local scale = ScreenHeight/imagefile:getHeight()
            gfx.scale(scale, scale)
            gfx.draw(imagefile, ScreenWidth/scale-imagefile:getWidth(), 0)
            gfx.pop()
        elseif State.leaf == 4 then
            gfx.setColor(0,0,0,1)
            gfx.rectangle("fill", 0, 0, ScreenWidth, ScreenHeight)
            gfx.setColor(0.7,0.1,0.1)
            gfx.push()
            local rotatefile = State.lovepotion
            local rotatescale = ScreenHeight/rotatefile:getHeight()
            gfx.scale(rotatescale, rotatescale)
            gfx.draw(rotatefile, ScreenWidth/rotatescale-rotatefile:getWidth(), math.max(1,ScreenHeight/2-rotatefile:getHeight()/2))
            gfx.pop()
        elseif State.leaf == 5 then
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
        elseif State.leaf == 6 then
            local xamount = math.floor(ScreenWidth/SQUAREAMOUNT)+1
            local yamount = math.floor(ScreenHeight/SQUAREAMOUNT)+1
            gfx.setColor(255, 255, 255, 255)
            for i=1, xamount do
                for j=1, yamount do
                    gfx.push()
                    local imagefile = Tiles[Save.map[math.min(math.max(1,i+State.xprefix-1),MAP_W)][math.min(math.max(1,j+State.yprefix-1),MAP_H)]].file
                    local scale = ScreenWidth/xamount/imagefile:getWidth()
                    gfx.scale(scale, scale)
                    gfx.draw(imagefile, (i-1)*SQUAREAMOUNT/scale,(j-1)*SQUAREAMOUNT/scale)
                    gfx.pop()
                end
            end
            gfx.push()
            local imagefile = State.charchosen
            local scalec = ScreenWidth/xamount/imagefile:getWidth()*BIGSQUARESCALE
            gfx.scale(scalec, scalec)
            gfx.draw(imagefile, SQUAREAMOUNT*math.floor(ScreenWidth/2/SQUAREAMOUNT)/scalec+0.5*SQUAREAMOUNT/scalec-imagefile:getWidth()/2, SQUAREAMOUNT*math.floor(ScreenHeight/2/SQUAREAMOUNT)/scalec+0.5*SQUAREAMOUNT/scalec-imagefile:getHeight()/2)
            gfx.pop()
        elseif State.leaf == 7 then
            gfx.setColor(0.3,0.3,0.3)
            local collectbutton = Buttons[State.leaf][1]
            gfx.rectangle("fill",collectbutton.x+collectbutton.width, collectbutton.y, ScreenWidth*ALCHEMYWINDOWSIZE, ScreenHeight*ALCHEMYWINDOWSIZE)
            gfx.setColor(0.5,0,0)
            gfx.rectangle("line",collectbutton.x+collectbutton.width, collectbutton.y, ScreenWidth*ALCHEMYWINDOWSIZE , ScreenHeight*ALCHEMYWINDOWSIZE )
            gfx.setColor(1,0,0)
            gfx.push()
            local scalesquare = 1/20
            local imagefile = State.alchbottle
            local bottlewidth = imagefile:getWidth()
            local bottleheight = imagefile:getHeight()
            local scalebottle = ScreenWidth/bottlewidth*scalesquare
            gfx.scale(scalebottle, scalebottle)
            gfx.draw(imagefile, (collectbutton.x+collectbutton.width)/scalebottle, collectbutton.y/scalebottle)
            gfx.pop()
            gfx.push()
            imagefile = State.alchdoc
            local docwidth = imagefile:getWidth()
            local docheight = imagefile:getHeight()
            local scaledoc = ScreenWidth/docwidth*scalesquare
            gfx.scale(scaledoc, scaledoc)
            gfx.draw(imagefile, (collectbutton.x+collectbutton.width)/scaledoc, (collectbutton.y+bottleheight*scalebottle)/scaledoc) -- good stretching
            gfx.pop()
            gfx.push()
            imagefile = State.alchankh
            local ankhwidth = imagefile:getWidth()
            local ankhheight = imagefile:getHeight()
            local scaleankh = ScreenWidth/ankhwidth*scalesquare
            gfx.scale(scaleankh, scaleankh)
            gfx.draw(imagefile, (collectbutton.x+collectbutton.width)/scaleankh, (collectbutton.y+ScreenHeight*ALCHEMYWINDOWSIZE)/scaleankh-ankhheight)--good stretching
            gfx.pop()
            if State.printingalchinventory == true then
                gfx.setColor(1,0,0)
                gfx.print(State.printingalchinventorytext, collectbutton.x+collectbutton.width+bottlewidth*scalebottle, collectbutton.y)
            end
            gfx.setColor(0,0,0.8)
            local linepadding = 1/4
            gfx.line(collectbutton.x+collectbutton.width+ankhwidth*scaleankh/2, collectbutton.y + docheight*scaledoc + bottleheight*scalebottle + bottleheight*scalebottle*linepadding, collectbutton.x+collectbutton.width+ankhwidth*scaleankh/2, collectbutton.y+ScreenHeight*ALCHEMYWINDOWSIZE-ankhheight*scaleankh*(1+linepadding))
        end

        local len = table_len(Buttons[State.leaf])
        for i=1,len do
            local button = Buttons[State.leaf][i]
            local width, height
            if button.size == 1 then
                gfx.setFont(BigFont)
                width = BigFont:getWidth(button.text)
                height = BigFont:getHeight(button.text)
            elseif button.size == 2 then
                gfx.setFont(SmallFont)
                width = SmallFont:getWidth(button.text)
                height = SmallFont:getHeight(button.text)
            end
            if State.hoover == i then
                gfx.setColor(0,0,0)
                gfx.rectangle("fill", button.x, button.y, button.width, button.height)
                gfx.setColor(1,1,1)
                gfx.rectangle("line", button.x, button.y, button.width, button.height)
                gfx.print(button.text, button.x+button.width/2.0-width/2.0, button.y+button.height/2.0-height/2.0)
            else
                gfx.setColor(1,1,1)
                gfx.rectangle("fill", button.x, button.y, button.width, button.height)
                gfx.rectangle("line", button.x, button.y, button.width, button.height)
                gfx.setColor(0,0,0)
                gfx.print(button.text, button.x+button.width/2.0-width/2.0, button.y+button.height/2.0-height/2.0)
            end
        end

        --first after custom leaves is banner
        gfx.setFont(SmallFont)
        gfx.setColor(255, 255, 255, 255)
        gfx.push()
        local theheight = ScreenHeight*BANNERH
        local scale = theheight/State.banner:getHeight()
        gfx.scale(scale, scale)
        for i=0,ScreenWidth/scale/(State.banner:getWidth()) do
            gfx.draw(State.banner, i*State.banner:getWidth(), 0)
        end
        gfx.pop()
        gfx.push()
        scale = theheight/State.bannerx:getHeight()
        gfx.scale(scale, scale)
        local boxsize = State.bannerx:getWidth()
        gfx.draw(State.bannerx, ScreenWidth/scale-boxsize, 0)
        gfx.draw(State.bannerm, ScreenWidth/scale-2*boxsize, 0)
        gfx.pop()
        local text = "Doctor Sauerkraut"
        gfx.setColor(1,1,1)
        for i=1, SMALLFONTDRAWS do
            gfx.print(text, ScreenWidth/2.0 - SmallFont:getWidth(text)/2.0, theheight/2.0-SmallFont:getHeight(text)/2.0)
        end

        if State.hoover < 0 then
            gfx.setColor(CommandLine.focusedcolor)
        else
            gfx.setColor(CommandLine.color)
        end
        gfx.rectangle("fill", CommandLine.x, CommandLine.y, CommandLine.width, CommandLine.height)
        gfx.setColor(255, 255, 255, 255)
        gfx.push()
        scale = CommandLine.height/CommandLine.button:getHeight()
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

        local posx, posy = getposfromhoover()

        print_to_debug(ScreenWidth.."x"..ScreenHeight..", vsync="..love.window.getVSync()..", fps="..love.timer.getFPS()..", mem="..string.format("%.3f", collectgarbage("count")/1000.0).."MB, randomseed="..Randomseed..", xpos="..Save.positionx.."|"..posx..", ypos="..Save.positiony.."|"..posy..", mousehoover="..Tiles[Save.map[posx][posy]].name)
        
        gfx.setCanvas()
        gfx.setColor(1, 1, 1, 1)
        gfx.draw(Canvas, 0,0)
    end
end
