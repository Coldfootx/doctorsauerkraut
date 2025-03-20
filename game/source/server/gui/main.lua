-- Make sure the shared library can be found through package.cpath before loading the module.
-- For example, if you put it in the LÖVE save directory, you could do something like this:
-- local lib_path = love.filesystem.getSaveDirectory() .. "/libraries"
-- local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
-- package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)

-- local imgui = require "cimgui" -- cimgui is the folder containing the Lua module (the "src" folder in the github repository)

local imgui, draw

love.load = function()
    -- copy the shared library to the save directory and modify package.cpath so it can be found by ffi.load
    local lib_folder = string.format("libs/%s-%s", jit.os, jit.arch)
    assert(
        love.filesystem.getRealDirectory(lib_folder),
        "The precompiled cimgui shared library is not available for your os/architecture. You can try compiling it yourself."
    )
    love.filesystem.remove(lib_folder)
    love.filesystem.createDirectory(lib_folder)
    for _, v in ipairs(love.filesystem.getDirectoryItems(lib_folder)) do
        local filename = string.format("%s/%s", lib_folder, v)
        assert(love.filesystem.write(filename, love.filesystem.read(filename)))
    end
    local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
    package.cpath = string.format("%s;%s/%s/?.%s", package.cpath, love.filesystem.getSaveDirectory(), lib_folder, extension)

    imgui = require "cimgui"
    imgui.Init()
    draw = require "draw"
end

love.draw = function()
    draw()
    -- code to render imgui
    imgui.Render()
    imgui.RenderDrawLists()
end

love.update = function(dt)
    imgui.Update(dt)
    imgui.NewFrame()
end

love.mousemoved = function(x, y, ...)
    imgui.MouseMoved(x, y)
    if not imgui.GetWantCaptureMouse() then
        -- your code here
    end
end

love.mousepressed = function(x, y, button, ...)
    imgui.MousePressed(button)
    if not imgui.GetWantCaptureMouse() then
        -- your code here 
    end
end

love.mousereleased = function(x, y, button, ...)
    imgui.MouseReleased(button)
    if not imgui.GetWantCaptureMouse() then
        -- your code here 
    end
end

love.wheelmoved = function(x, y)
    imgui.WheelMoved(x, y)
    if not imgui.GetWantCaptureMouse() then
        -- your code here 
    end
end

love.keypressed = function(key, ...)
    imgui.KeyPressed(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- your code here 
    end
end

love.keyreleased = function(key, ...)
    imgui.KeyReleased(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- your code here 
    end
end

love.textinput = function(t)
    imgui.TextInput(t)
    if not imgui.GetWantCaptureKeyboard() then
        -- your code here 
    end
end

love.quit = function()
    return imgui.Shutdown()
end

love.resize = function(w, h)
    local io = imgui.GetIO()
    io.DisplaySize.x, io.DisplaySize.y = w, h
end