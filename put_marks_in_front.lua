label = "Put marks in the front"

revertOriginal = _G.revertOriginal

function run(model)
    local t = { 
        label = "put marks in the front",
	    pno = model.pno,
	    original = model:page():clone(),
	    undo = revertOriginal,
    }
    t.redo = function(t, doc)
    local p = doc[t.pno]
    local objects = {}
    local marks = {}

    for objno, obj, _, layer in p:objects() do
        if obj:get("markshape") ~= "undefined" then
            table.insert(marks, {p:layerOf(objno), obj:clone(), p:select(objno)})
        else
            table.insert(objects, {p:layerOf(objno), obj:clone(),p:select(objno)})
        end
    end

    p:deselectAll()

    local i = 1
        for _, obj in ipairs(objects) do
            p:replace(i, obj[2])
            p:setLayerOf(i, obj[1])
            p:setSelect(i, obj[3]) 
            i = i + 1
        end
        for _, obj in ipairs(marks) do
            p:replace(i, obj[2])
            p:setLayerOf(i, obj[1])
            p:setSelect(i, obj[3]) 
            i = i + 1
        end
    end
    model:register(t)
end

--------------------------
shortcuts.ipelet_1_put_marks_in_front = "Alt+Shift+F"
