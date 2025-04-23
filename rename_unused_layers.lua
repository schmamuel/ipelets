label = "Rename unused layers"

about = [[ An Ipelet that renames all layers from the current page that are not visible on any layer. ]]

function run(model)
    local t = {
        label = "rename unused layers",
        model = model,
    }
    -- store some information about the current situation to be able to undo the removal
    t.layers = collect_data(model:page())
    t.page = model.pno
    t.redo = function(t, doc)
        local p = model:page()
        local counter = 0
        for _, l in pairs(p:layers()) do
            local used = false
            for v =1,p:countViews() do
                if p:visible(v,l) then
                    used = true
                end
            end
            if not used then
                counter = counter + 1
                p:renameLayer(l,"unused_" .. l)
            end
        end
        if counter > 0 then
            model:warning(counter .. " layers are unused")
        end
    end
    t.undo = function(t, doc)
        undo(t.model, t.layers, t.page)
    end
    model:register(t)
end

-- Collect data needed to undo the removal
function collect_data(p)
    local layers = {}
    -- Store the correct order of layers and on which views the layers are visible
    for i, l in pairs(p:layers()) do
        layers[i] = l
    end
    return layers
end

function redo(model)
    local p = model:page()
    local counter = 0
    for _, l in pairs(p:layers()) do
        local used = false
        for v =1,p:countViews() do
            if p:visible(v,l) then
                used = true
            end
        end
        if not used then
            counter = counter + 1
            p:renameLayer(l,"unused_" .. l)
        end
    end
    if counter > 0 then
        model:warning(counter .. " layers are unused")
    end
end

function undo(model, layers, page)
    local p = model.doc[page]

    for i, l in pairs(p:layers()) do
        p:renameLayer(l,layers[i])
    end
end

------------------------------------
shortcuts.ipelet_1_rename_unused_layers = "Ctrl+Del"