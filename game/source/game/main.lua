MAPW = 1024
MAPH = 1024

map = {}
for i=1,MAPW do
    map[i] = {}     -- create x
    for j=1,MAPH do
        map[i][j] = 0
    end
end

local tab = {map}

local t = {}
for n = 1, ITEMS do
    t[n] = {}
end

local time = os.clock()
for n = 1, ITEMS do
    table.insert(tab, t[n])
end
print(('table.insert: %.4f'):format(os.clock() - time))

local time = os.clock()
for n = ITEMS, 1, -2 do
    table.remove(tab, n)
end
print(('table.remove: %.4f'):format(os.clock() - time))

local time = os.clock()
for m = 1, ITER do
    for n = 1, #tab do
        assert(tab[n])
    end
end
    print(('table iterate: %.4f'):format(os.clock() - time))

function love.draw()
    love.graphics.print("Hello World", 400, 300)
end

