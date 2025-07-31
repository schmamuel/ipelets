label = "Selector"

function smaller_y(p,objects)
    table.sort(objects, function (a,b)
                local abox = p:bbox(a)
                local bbox = p:bbox(b)
                if abox:bottom() == bbox:bottom() then
                    if abox:top() == bbox:top() then
                        if abox:left() == bbox:left() then
                            if abox:right() == bbox:right() then
                                return a < b
                            else 
                                return abox:right() < bbox:right()
                            end
                        else 
                            return abox:left() < bbox:left()
                        end
                    else 
                        return abox:top() < bbox:top()
                    end
                else 
                    return abox:bottom() < bbox:bottom()
                end
			end)
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

function smaller_x(p,objects)
    table.sort(objects, function (a,b)
                local abox = p:bbox(a)
                local bbox = p:bbox(b)
                if abox:left() == bbox:left() then
                    if abox:right() == bbox:right() then
                        if abox:bottom() == bbox:bottom() then
                            if abox:top() == bbox:top() then
                                return a < b
                            else 
                                return abox:top() < bbox:top()
                            end
                        else 
                            return abox:bottom() < bbox:bottom()
                        end
                    else 
                        return abox:right() < bbox:right()
                    end
                else 
                    return abox:left() < bbox:left()
                end
			end)
end

function larger_x(p,objects)
    table.sort(objects, function (a,b)
                local abox = p:bbox(a)
                local bbox = p:bbox(b)
                if abox:left() == bbox:left() then
                    if abox:right() == bbox:right() then
                        if abox:bottom() == bbox:bottom() then
                            if abox:top() == bbox:top() then
                                return a > b
                            else 
                                return abox:top() > bbox:top()
                            end
                        else 
                            return abox:bottom() > bbox:bottom()
                        end
                    else 
                        return abox:right() > bbox:right()
                    end
                else 
                    return abox:left() > bbox:left()
                end
			end)
end

function run(model, num) 
    local p = model:page()
    local currView = model.vno
    local prim = p:primarySelection()
    if prim == nil then
        model.ui:explain("nothing selected")
        return
    end
    local objects = {}
    local prim_type = p[prim]:type()
    for i, _, _ , _  in p:objects() do
        if p:visible(currView, i) and p[i]:type() == prim_type and not p:isLocked(p:layerOf(i)) then
            objects[#objects + 1] = i
        end
    end
    methods[num].sort(p,objects)
    p:deselectAll()
    local index = _G.findIndex(objects,prim)
    if index == #objects then
        index = 1
    else
        index = index + 1
    end
    p:setSelect(objects[index],1)
    
end

methods = {
    { label = "next object in y-direction", sort=larger_y},
    { label = "previous object in y-direction", sort=smaller_y},
    { label = "next object in x-direction", sort=larger_x},
    { label = "previous object in x-direction", sort=smaller_x},
  }

----------

shortcuts.ipelet_1_selector = "Tab"
shortcuts.ipelet_2_selector = "Ctrl+Tab"
shortcuts.ipelet_3_selector = "Alt+PgDown"
shortcuts.ipelet_4_selector = "Alt+PgUp"