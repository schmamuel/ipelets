label = "Clipping"

about = [[ Adds a shortcut to add a clipping path. ]]

function add_clipping(model)
    model:saction_add_clipping()
end 

function remove_clipping(model)
    model:saction_remove_clipping()
end 

methods = {
   { label = "Add clipping path", run=add_clipping },
   { label = "Remove clipping path", run=remove_clipping },
}

--------------

shortcuts.ipelet_1_clipping = "Alt+C"
shortcuts.ipelet_2_clipping = "Ctrl+Alt+C"
