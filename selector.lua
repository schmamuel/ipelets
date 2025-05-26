label = "Selector"

function findIndex(array, target)
    for i, value in ipairs(array) do
        if value == target then
            return i
        end
    end
    return nil  -- not found
end

function smaller_y(p,objects)
    table.sort(objects, function (a,b)
                local apos = p:bbox(a):bottomLeft()
                local bpos = p:bbox(b):bottomLeft()
                if apos.y == bpos.y then
                    if apos.x == apos.x then
                        return a < b
                    else
                        return apos.x < bpos.x
                    end
                else 
                    return apos.y < bpos.y
                end
			end)
end

function larger_y(p,objects)
    table.sort(objects, function (a,b)
                local apos = p:bbox(a):bottomLeft()
                local bpos = p:bbox(b):bottomLeft()
                if apos.y == bpos.y then
                    if apos.x == apos.x then
                        return a > b
                    else
                        return apos.x > bpos.x
                    end
                else 
                    return apos.y > bpos.y
                end
			end)
end

function smaller_x(p,objects)
    table.sort(objects, function (a,b)
                local apos = p:bbox(a):bottomLeft()
                local bpos = p:bbox(b):bottomLeft()
                if apos.x == bpos.x then
                    if apos.y == apos.y then
                        return a < b
                    else
                        return apos.y < bpos.y
                    end
                else 
                    return apos.x < bpos.x
                end
			end)
end

function larger_x(p,objects)
    table.sort(objects, function (a,b)
                local apos = p:bbox(a):bottomLeft()
                local bpos = p:bbox(b):bottomLeft()
                if apos.x == bpos.x then
                    if apos.y == apos.y then
                        return a > b
                    else
                        return apos.y > bpos.y
                    end
                else 
                    return apos.x > bpos.x
                end
			end)
end

function run(model, num) 
    local p = model:page()
    local currView = model.vno
    local prim = p:primarySelection()
    if prim == nil then
        model.ui:explain("nothing selected")
    end
    local objects = {}
    local prim_type = p[prim]:type()
    for i, _, _ , _  in p:objects() do
        if p:visible(currView, i) and p[i]:type() == prim_type then
            objects[#objects + 1] = i
        end
    end
    methods[num].sort(p,objects)
    p:deselectAll()
    local index = findIndex(objects,prim)
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

shortcuts.ipelet_1_selector = "Alt+PgDown"
shortcuts.ipelet_2_selector = "Alt+PgUp"
shortcuts.ipelet_3_selector = "Ctrl+Alt+PgDown"
shortcuts.ipelet_4_selector = "Ctrl+Alt+PgUp"