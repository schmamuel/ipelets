label = "change grid size"

about = [[
This ipelet adds shortcuts to change the gridsize.
]]

function get_gridsizes(model)
    local sheets = model.doc:sheets()
    local syms =  sheets:allNames("gridsize")
    local values = {}
    for _,sym in ipairs(syms) do
        values[#values + 1] = sheets:find("gridsize", sym)
    end
    table.sort(values)
    return values
end


function run(model, num)    
    model.ui:explain(methods[num].label)
    local gridsizes = get_gridsizes(model)
    local currentIndex = _G.findIndex(gridsizes,model.snap.gridsize)
    if methods[num].next then
        if currentIndex < #gridsizes then
            model.snap.gridsize = gridsizes[currentIndex + 1]
        else
            model.snap.gridsize = gridsizes[1]
        end
    else
        if currentIndex > 1 then
            model.snap.gridsize = gridsizes[currentIndex - 1]
        else
            model.snap.gridsize = gridsizes[#gridsizes]
        end
    end
    model.ui:setGridAngleSize(model.snap.gridsize, model.snap.anglesize)
    model:setSnap()
end 


methods = {
  { label = "increase grid size", next = true},
  { label = "decrease grid size", next = false},
}

---------------------------------------------------

shortcuts.ipelet_1_change_gridsize = "Up"
shortcuts.ipelet_2_change_gridsize = "Down"