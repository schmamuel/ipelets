label = "enumerate"

local enum_types = {"enumerate_roman", "enumerate_arabic", "enumerate_alph"}

function find_type(name)
    for i,enum_name in ipairs(enum_types) do
        if name == enum_name then return i end
    end
    return nil
end

local function remove_counter(s)
    return s:gsub("^\\addtocounter{enumi}%s*{.-}", ""):gsub("^%s*\\item%s*", "")
end

function run(model)
    -- local doc = model.doc
    local p = model:page()
    -- for i = 1, #doc do
    --     local p = doc[i]
        for _,enum_name in ipairs(enum_types) do
            local objects= {}
            for index, obj, sel, layer in p:objects() do
                if obj:get("textstyle") == enum_name then objects[#objects + 1] = index end
            end
            table.sort(objects, function (a,b)
                local abox = p:bbox(a)
                local bbox = p:bbox(b)
                if abox:top() ~= bbox:top() then
                    return abox:top() > bbox:top()
                end

                if abox:left() ~= bbox:left() then
                    return abox:left() < bbox:left()
                end
                
                return a < b
			end)
            for j,index in ipairs(objects) do
                local obj = p[index]
                local text = obj:text()
                text = remove_counter(text)
                obj:setText("\\addtocounter{enumi}{" .. j - 1 .. "}\\item " .. text)
            end
        end
    -- end
end


----------------------------------------
shortcuts.ipelet_1_enumerate = "Shift+F5"