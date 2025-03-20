MAPW = 1024
MAPH = 1024

local map = {}
for i=1,MAPW do
    map[i] = {}     -- create x
    for j=1,MAPH do
        map[i][j] = 0
    end
end

local save = {map}

local datastream = love.data.pack("data", "I", save)

local FilePath = SKIN:MakePathAbsolute('./save/save1')
local File = io.open(FilePath, 'w')
File:write(datastream)
File:close()

local File = io.open(FilePath, 'r')
datastream = io.read()
save = love.data.unpack("I", datastream, 1)

love.graphics.print(save[1][1]+" "+save[1][1]+" "+save[2][2], 400, 300)


