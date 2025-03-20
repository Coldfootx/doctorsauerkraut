local imgui = require "cimgui"
local ffi = require "ffi"

local show = {
    demo = ffi.new("bool[1]", false),
    test = ffi.new("bool[1]", true),
    style = ffi.new("bool[1]", false),
    metrics = ffi.new("bool[1]", false),
}

local io = imgui.GetIO()

local original_names = {
    "Bobby", "Beatrice", "Betty",
    "Brianna", "Barry", "Bernard",
    "Bibi", "Blaine", "Bryn"
}
local names = {unpack(original_names)}
local mode = "copy"

local payload

local img = love.graphics.newImage("panda.jpg")

return function()
    if imgui.BeginMainMenuBar() then
        if imgui.BeginMenu("File") then
            if imgui.MenuItem_Bool("Quit") then love.event.quit() end
            imgui.EndMenu()
        end
        if imgui.BeginMenu("View") then
            imgui.MenuItem_BoolPtr("Show test window", nil, show.test)
            if imgui.BeginMenu("Dear ImGui windows") then
                imgui.MenuItem_BoolPtr("Show demo window", nil, show.demo)
                imgui.MenuItem_BoolPtr("Show style editor", nil, show.style)
                imgui.MenuItem_BoolPtr("Show metrics window", nil, show.metrics)
                imgui.EndMenu()
            end
            imgui.EndMenu()
        end
        imgui.EndMainMenuBar()
    end

    if show.test[0] then
        if imgui.Begin("Test window", show.test) then
            if imgui.CollapsingHeader_TreeNodeFlags("Options") then
                local p = ffi.new("int[1]", io.ConfigFlags)
                imgui.CheckboxFlags_IntPtr("Enable docking", p, imgui.ImGuiConfigFlags_DockingEnable)
                io.ConfigFlags = p[0]
                imgui.SameLine()
                imgui.TextDisabled("(?)")
                if imgui.IsItemHovered() then
                    imgui.BeginTooltip()
                    imgui.PushTextWrapPos(imgui.GetFontSize()*30)
                    imgui.TextUnformatted("You will need to open more window through the \"View\" menu to test this.")
                    imgui.PopTextWrapPos()
                    imgui.EndTooltip()
                end
                
                p = ffi.new("bool[1]", love.window.getVSync() == 1)
                if imgui.Checkbox("Enable vsync", p) then
                    love.window.setVSync(p[0] and 1 or 0)
                end
            end

            if imgui.CollapsingHeader_TreeNodeFlags("Drag & drop") then
    

                imgui.Text("Drag and drop to copy/swap items")
                if imgui.RadioButton_Bool("Copy", mode == "copy") then mode = "copy" end
                imgui.SameLine()
                if imgui.RadioButton_Bool("Move", mode == "move") then mode = "move" end
                imgui.SameLine()
                if imgui.RadioButton_Bool("Swap", mode == "swap") then mode = "swap" end
                imgui.SameLine()
                if imgui.Button("Reset") then names = {unpack(original_names)} end

                for i = 1, 9 do
                    imgui.Button(names[i] .. "##" .. i, imgui.ImVec2_Float(60, 60))
                    if imgui.BeginDragDropSource() then
                        imgui.SetDragDropPayload("test", nil, 0)
                        if mode == "copy" then imgui.Text("Copy %s", names[i]) end
                        if mode == "move" then imgui.Text("Move %s", names[i]) end
                        if mode == "swap" then imgui.Text("Swap %s", names[i]) end
                        payload = i
                        imgui.EndDragDropSource()
                    end
                    if imgui.BeginDragDropTarget() then
                        if imgui.AcceptDragDropPayload("test") ~= nil then
                            if mode == "copy" then
                                names[i] = names[payload]
                            elseif mode == "move" then
                                names[i] = names[payload]
                                names[payload] = ""
                            elseif mode == "swap" then
                                names[i], names[payload] = names[payload], names[i]
                            end
                        end
                        imgui.EndDragDropTarget()
                    end

                    if i % 3 ~= 0 then imgui.SameLine() end
                end
                
            end

            if imgui.CollapsingHeader_TreeNodeFlags("Drawing LÖVE images") then
                imgui.Image(img, imgui.ImVec2_Float(img:getDimensions()))
            end
        end
        imgui.End()
    end

    if show.demo[0] then imgui.ShowDemoWindow(show.demo) end
    if show.metrics[0] then imgui.ShowMetricsWindow(show.metrics) end
    if show.style[0] then
        if imgui.Begin("Style editor", show.style) then imgui.ShowStyleEditor() end
        imgui.End()
    end
end