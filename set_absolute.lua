label = "Set Absolute"

about = [[
Resolve all symbolic attributes (e.g., stroke, fill, pen)
on the current page to their resolved absolute values.
]]

local sizes = {{"verytiny",5},{"tiny", 5},{"scriptsize",7},{"footnote",8},{"small",9},{"normal",10},{"large",12},{"Large",14.4},{"LARGE",17.28},{"huge",20.74},{"Huge",24.88},{"largebf",12}}


function is_absolute(var)
    return _G.type(var) == "number"
end

function get_absolute_textsize(var)
    for _,size in ipairs(sizes) do
        if size[1] == var then 
            return size[2]
        end
    end
    return nil
end

function check_color(sheets, obj, attribute)
    local val = obj:get(attribute)
    if val and val == "KITblack" then
        obj:set(attribute,"black")
    elseif val ~= "black" and val ~= "white" then
        val = sheets:find("color", val)
        obj:set(attribute,val) 
    end
end

function check_size(sheets, obj, attribute)
    local objattr = attribute
    if attribute == "farrowsize" or attribute == "rarrowsize" then attribute = "arrowsize" end
    local val = obj:get(objattr)
    if is_absolute(val) or val == nil then return end
    val = sheets:find(attribute, val)
    obj:set(objattr, val)
end

function check_text(sheets, obj)
    local val = obj:get("textsize")
    if is_absolute(val) or val == nil then return false end
    if val == "largebf" then 
        obj:setText("\\bf " .. obj:text())
    end
    local size = get_absolute_textsize(val)
    if size == nil then return false end
    val = sheets:find("textstretch", val)
    obj:set("textsize", val * size)
    return true
end

function run(model)
    local doc = model.doc
    local sheets = model.doc:sheets()

    for j =1,#doc do
        local p = doc[j]
        local edited_text = false
        for i, obj, _ , _  in p:objects() do
            if obj:type() ~= "group" then
                check_color(sheets, obj, "stroke")
                check_color(sheets, obj, "fill")
                check_size(sheets, obj, "pen")
                check_size(sheets, obj, "farrowsize")
                check_size(sheets, obj, "rarrowsize")
                check_size(sheets, obj, "symbolsize")
                if check_text(sheets,obj) then edited_text = true end
            end
        end
    end
    if edited_text then model:autoRunLatex() end
end
 
-------------------

-- shortcuts.ipelet_1_set_absolute = "Ctrl+T"
-- shortcuts.absolute = nil