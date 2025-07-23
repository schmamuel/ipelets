label = "polygons"

function close_polygon(model)
    local p = model:page()
    local selection = model:selection()
    local t = {
        label = "close polygon",
        pno = model.pno,
       selection = selection,
       original = p:clone(),
       undo = _G.revertOriginal
     }
    t.redo = function (t, doc)
        for _,i in ipairs(selection) do
            if p[i]:type() == "path" then
                if not string.find(p[i]:xml(), "h\r?\n</path>") then
                local xml = p[i]:xml():gsub("</path>", "h\n</path>")
                print(xml)
			    local obj = _G.ipe.Object(xml)
                p:replace(i, obj)
                end
            end
        end
    end
    model:register(t) 
 end

 function reverse_arrows(model)
    local p = model:page()
    local selection = model:selection()
    local t = {
        label = "reverse arrows",
        pno = model.pno,
       selection = selection,
       original = p:clone(),
       undo = _G.revertOriginal
     }
    t.redo = function (t, doc)
        for _,i in ipairs(selection) do
            if p[i]:type() == "path" then
                local farr = p[i]:get("farrow")
                local rarr = p[i]:get("rarrow")
                if farr then
                    p[i]:set("rarrow",true)
                else
                    p[i]:set("rarrow",false)
                end
                if rarr then
                    p[i]:set("farrow",true)
                else
                    p[i]:set("farrow",false)
                end
            end
        end
    end
    model:register(t) 
 end

 methods = {
    { label = "close polygon", run = close_polygon},
    { label = "reverse arrows", run = reverse_arrows},
  }

  -------------------

shortcuts.ipelet_1_polygons = "Alt+C"
shortcuts.ipelet_2_polygons = "Ctrl+Alt+R"