label = "connect marks with arc"

function run(model)
    local p = model:page()
    local selection = model:selection()
    local prim = p:primarySelection()
    if not prim then
        model.ui:explain("no selection")
        return
    end
    local sec = nil
    for _,i in ipairs(selection) do
        if i ~= prim then
            sec = i
            break
        end
    end
    if sec == nil then
        model.ui:explain("you need to select two marks")
        return
    end
    local pos1 = p[prim]:position()
    local pos2 = p[sec]:position()
    local diff = pos1 - pos2
    local dist = diff:len() * 0.5
    local mid = pos1 - (diff * 0.5)
    local m = ipe.Matrix(dist, 0, 0, dist, mid.x, mid.y) 
    local a = ipe.Arc(m, pos2.x, pos2.y)
    local curve = { type="curve", closed = false, {type="arc", pos1,pos2, arc=a} }
    local obj = ipe.Path(model.attributes, { curve } )
    model:creation("create arc", obj)
end
