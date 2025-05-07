label = "Set link action"

about = "Assigns a link action to the objects and groups them if they are not already grouped."

function run(model)
    local sel = model:selection()
    local p = model:page()
    local prim = p:primarySelection()
    if not prim then model.ui:explain("no selection") return end
    local obj = p[prim]

    if obj:type() ~= "group" then
        model:saction_group()
    end

    model:saction_set_link_action()

end

----------------------------------------

shortcuts.ipelet_1_link = "Z"