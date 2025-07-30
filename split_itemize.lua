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
    for _,i  in ipairs(model:selection()) do
        if p[i]:type() ~= "text" then
            model.ui:explain("some selection is not text")
            return
        end
        objects[#objects + 1] = i
    end
    larger_y(p,objects)
    local items = ""
    for _,i in ipairs(objects) do
        if p[i]:get("textstyle") == "item" then
            items = items .. "    \\item " .. p[i]:text() .. "\n"
        elseif p[i]:get("textstyle") == "itemize" then
            items = items .. p[i]:text() .. "\n"
        else
            if items ~= "" then
                text = text .."\\begin{itemize}\n" .. items .. "\\end{itemize}\n"
                text = text .. p[i]:text() .. "\n"
                items = ""
            else 
                text = text .. p[i]:text() .. "\n"
            end
        end
    end
    if items ~= "" then 
        text = text .."\\begin{itemize}\n" .. items .. "\\end{itemize}\n"
    end
    text = string.gsub(text, "\n+$", "")
    p[prim]:setText(text)
    p[prim]:set("textstyle", "normal")
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

    iterate_spliting(model, style, 0)
    
    -- model:autoRunLatex()
end

function iterate_spliting(model, style, iteration)
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
    if style ~= "itemize" then
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
    iterate_spliting(model, style, iteration + 1)
end

methods = {
    { label = "split itemize", run = split},
    { label = "merge", run = merge},
  }


---------------------------------------------

shortcuts.ipelet_1_split_itemize = "Alt+X"
shortcuts.ipelet_2_split_itemize = "Alt+J