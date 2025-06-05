label = "list shortcuts" 


function run(model)
    local shortcuts = {}
    local s = ""
    for label, shortcut in pairs(_G.shortcuts) do
        table.insert(shortcuts, {label,shortcut})
    end

    table.sort(shortcuts, function(a, b)
        local atemp = a[1]:gsub("^ipelet_%d+_", "")
        local btemp = b[1]:gsub("^ipelet_%d+_", "")
        
        if atemp == btemp then
            atemp = tonumber(a[1]:gsub("%D", ""))
            btemp = tonumber(b[1]:gsub("%D", ""))
        end
            return atemp < btemp
    end)

    for label, shortcut in ipairs(shortcuts) do
        s = s .. "shortcuts." .. shortcut[1] .. "='" .. shortcut[2] .."'\n"
    end
    s = s:gsub("\n$", "")

    local d = ipeui.Dialog(model.ui:win(), "Show shortcuts")
    d:add("xml", "text", { syntax="xml", focus=true }, 1, 1)
    d:set("xml", s)
    
    _G.externalEditor(d, "xml")

    d:accept()
end
