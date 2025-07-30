label="split itemize"

function split_text(text)
    local first_pos = string.find(text, "\\item", 1, true)
    local second_pos = string.find(text, "\\item", first_pos + 1, true)

    if second_pos then
        local part1 = string.sub(text, 1, second_pos - 1)
        local part2 = string.sub(text, second_pos)
        return part1,part2
    else
     return text,nil
    end
end

function iterate_spliting(model, style, iteration,pos)
    local p = model:page()
	local prim = p:primarySelection()
    local obj = p[prim]
    local text = obj:text()
    local part1,part2 = split_text(text)
    if part2 == nil then 
        model.ui:explain("only a single item in itemize")
        return false
    end
    if type ~= "itemize" then
        part2 = "\\addtocounter{enumi}{" .. iteration + 1 .. "}" .. part2
    end
    -- local pbox = p:bbox(prim)
    -- local pos = obj:matrix() * ipe.Vector(pbox:left(),pbox:bottom())
    local new_obj = ipe.Text({textstyle=style, stroke=obj:get("stroke"),textsize = obj:get("textsize"), verticalalignment = "baseline"}, part2, pos, obj:get("width"))
    new_obj:set("verticalalignment", "bottom")
    p:deselectAll()
	p:insert(nil, new_obj, 1, p:layerOf(prim))
    model:autoRunLatex()
    model:autoRunLatex()
    local box = p:bbox(prim)
	local vy = box:top() - box:bottom()
    p:transform(prim, ipe.Translation(ipe.Vector(0, vy)))
    local new_pos = ipe.Vector(box:left(),box:top())
    obj:set("verticalalignment", "top")
    p[prim]:setText(part1)
    model:autoRunLatex()
    return true
    -- iterate_spliting(model, style, iteration + 1)
end

function larger_y(p,objects)
    table.sort(objects, function (a,b)
                local abox = p:bbox(a)
                local bbox = p:bbox(b)
                if abox:bottom() == bbox:bottom() then
                    if abox:top() == bbox:top() then
                        if abox:left() == bbox:left() then
                            if abox:right() == bbox:right() then
                                return a > b
                            else 
                                return abox:right() > bbox:right()
                            end
                        else 
                            return abox:left() > bbox:left()
                        end
                    else 
                        return abox:top() > bbox:top()
                    end
                else 
                    return abox:bottom() > bbox:bottom()
                end
			end)
end


function merge(model)
    local p = model:page()
	local prim = p:primarySelection()
    if not prim then
        model.ui:explain("no selection")
        return
    end
    local text = ""
    local objects = {}
    for i, _, _ , _  in ipairs(model:selection()) do
        if p[i]:type() ~= "text" then
            model.ui:explain("some selection is not text")
            return
        end
        objects[#objects + 1] = i
    end
    larger_y(p,objects)
    for _,i in ipairs(objects) do
        if p[i]:get("textstyle") == "item" then
            text = text .. "\\begin{itemize}\n\\item " .. p[i]:text() .. "\n\\end{itemize}\n\n"
        else
        text = text .. p[i]:text() .. "\n\n"
        end
    end
    text = string.gsub(text, "\n+$", "")
    p[prim]:setText(text)
    table.sort(objects, function(a,b) return a < b end)
    for i=#objects,1,-1 do
        if objects[i] ~= prim then
            p:remove(objects[i])
        end
    end
    
    model:autoRunLatex()
end


function split(model)
    local p = model:page()
	local prim = p:primarySelection()
    if not prim then
        model.ui:explain("no selection")
        return
    end
    if p[prim]:type() ~= "text" then
        model.ui:explain("selection is not text")
        return
    end
    local style = p[prim]:get("textstyle")
    local i = 0
    local pbox = p:bbox(prim)
    local pos = ipe.Vector(pbox:left(),pbox:bottom())
    while iterate_spliting(model, style, i, pos) do
        i = i+1
    end
    
    model:autoRunLatex()
end

function new_split(model)
    local p = model:page()
	local prim = p:primarySelection()
    if not prim then
        model.ui:explain("no selection")
        return
    end
    if p[prim]:type() ~= "text" then
        model.ui:explain("selection is not text")
        return
    end
    local style = p[prim]:get("textstyle")

    new_iterate_spliting(model, style, 0)
    
    -- model:autoRunLatex()
end

function new_iterate_spliting(model, style, iteration)
    model:autoRunLatex()
    model:autoRunLatex()
    local p = model:page()
	local prim = p:primarySelection()
    local obj = p[prim]
    local pbox = p:bbox(prim)
    local pos = ipe.Vector(pbox:left(),pbox:bottom())
    local text = obj:text()
    local part1,part2 = split_text(text)
    if part2 == nil then
        return false
    end
    if type ~= "itemize" then
        part2 = "\\addtocounter{enumi}{" .. iteration + 1 .. "}" .. part2
    end
    local new_obj = ipe.Text({textstyle=style, stroke=obj:get("stroke"),textsize = obj:get("textsize")}, part2, pos, obj:get("width"))
    obj:setText(part1)
    p:deselectAll()
	p:insert(nil, new_obj, 1, p:layerOf(prim))
    model:autoRunLatex()
    model:autoRunLatex()
    local new_prim = p:primarySelection()
    local box = p:bbox(new_prim)
	local vy = box:top() - box:bottom()
    p:transform(new_prim,ipe.Translation(ipe.Vector(0, vy)))
    -- model:autoRunLatex()
    new_iterate_spliting(model, style, iteration + 1)
end

methods = {
    { label = "split itemize", run = new_split},
    { label = "merge", run = merge},
  }


---------------------------------------------

shortcuts.ipelet_1_split_itemize = "Alt+X"