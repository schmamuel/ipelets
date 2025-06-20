label = "list shortcuts" 




--this is a map for the names of the shortcuts

local name_map = {
    ["new_window"] = "New Window",
    ["new"] = "New",
    ["open"] = "Open",
    ["save"] = "Save",
    ["download"] = "Download",
    ["save_as"] = "Save as",
    ["manage_files"] = "Manage files",
    ["export_png"] = "Export as PNG",
    ["export_eps"] = "Export as EPS",
    ["export_svg"] = "Export as SVG",
    ["insert_image"] = "Insert image",
    ["auto_latex"] = "Automatically run Latex",
    ["run_latex"] = "Run Latex",
    ["document_properties"] = "Document properties",
    ["add_style_sheets"] = "Add style sheets",
    ["style_sheets"] = "Style sheets",
    ["update_style_sheets"] = "Update style sheets",
    ["check_style"] = "Check symbolic attributes",
    ["close"] = "Close",
    ["undo"] = "Undo",
    ["redo"] = "Redo",
    ["cut"] = "Cut",
    ["copy"] = "Copy",
    ["paste"] = "Paste",
    ["paste_with_layer"] = "Paste with layer",
    ["paste_at_cursor"] = "Paste at cursor",
    ["delete"] = "Delete",
    ["group"] = "Group",
    ["ungroup"] = "Ungroup",
    ["front"] = "Front",
    ["back"] = "Back",
    ["forward"] = "Forward",
    ["backward"] = "Backward",
    ["before"] = "Just before",
    ["behind"] = "Just behind",
    ["duplicate"] = "Duplicate",
    ["select_all"] = "Select all",
    ["deselect_all"] = "Deselect all",
    ["pick_properties"] = "Pick properties",
    ["apply_properties"] = "Apply properties",
    ["insert_text_box"] = "Insert text box",
    ["change_width"] = "Change text width",
    ["edit"] = "Edit object",
    ["edit_as_xml"] = "Edit object as XML",
    ["edit_group"] = "Edit group",
    ["end_group_edit"] = "End group edit",
    ["mode_select"] = "Select objects",
    ["mode_translate"] = "Translate objects",
    ["mode_rotate"] = "Rotate objects",
    ["mode_stretch"] = "Stretch objects",
    ["mode_shear"] = "Shear objects",
    ["mode_graph"] = "Move graph nodes",
    ["mode_pan"] = "Pan the canvas",
    ["mode_shredder"] = "Shred objects",
    ["mode_laser"] = "Laser pointer",
    ["mode_label"] = "Text labels",
    ["mode_math"] = "Mathematical symbols",
    ["mode_paragraph"] = "Paragraphs",
    ["mode_marks"] = "Marks",
    ["mode_rectangles1"] = "Axis-parallel rectangles",
    ["mode_rectangles3"] = "Rectangles",
    ["mode_parallelogram"] = "Parallelograms",
    ["mode_lines"] = "Lines and polylines",
    ["mode_polygons"] = "Polygons",
    ["mode_splines"] = "Splines",
    ["mode_splinegons"] = "Splinegons",
    ["mode_arc3"] = "Circular arcs (by 3 points)",
    ["mode_circle1"] = "Circles (by center and radius)",
    ["mode_circle2"] = "Circles (by diameter)",
    ["mode_circle3"] = "Circles (by 3 points)",
    ["mode_ink"] = "Ink",
    ["snapvtx"] = "Snap to vertex",
    ["snapctl"] = "Snap to control point",
    ["snapbd"] = "Snap to boundary",
    ["snapint"] = "Snap to intersection",
    ["snapgrid"] = "Snap to grid",
    ["snapcustom"] = "Snap to custom grid",
    ["snapangle"] = "Angular snap",
    ["snapauto"] = "Automatic snap",
    ["set_origin"] = "Set origin",
    ["set_origin_snap"] = "Set origin && snap",
    ["show_axes"] = "Show axes",
    ["set_direction"] = "Set direction",
    ["set_tangent_direction"] = "Set tangent direction",
    ["reset_direction"] = "Reset direction",
    ["set_line"] = "Set line",
    ["set_line_snap"] = "Set line && snap",
    ["fullscreen"] = "Fullscreen",
    ["grid_visible"] = "Grid visible",
    ["pretty_display"] = "Pretty display",
    ["zoom_in"] = "Zoom in",
    ["zoom_out"] = "Zoom out",
    ["normal_size"] = "Normal size",
    ["fit_page"] = "Fit page",
    ["fit_width"] = "Fit width",
    ["fit_top"] = "Fit page top",
    ["fit_objects"] = "Fit objects",
    ["fit_selection"] = "Fit selection",
    ["pan_here"] = "Pan here",
    ["new_layer"] = "New layer",
    ["new_layer_view"] = "New layer, new view",
    ["rename_active_layer"] = "Rename active layer",
    ["select_in_active_layer"] = "Select all in active  layer",
    ["move_to_active_layer"] = "Move to active layer",
    ["next_view"] = "Next view",
    ["previous_view"] = "Previous view",
    ["first_view"] = "First view",
    ["last_view"] = "Last view",
    ["new_view"] = "New view",
    ["delete_view"] = "Delete view",
    ["mark_from_view"] = "Mark views from this view",
    ["unmark_from_view"] = "Unmark views from this view",
    ["jump_view"] = "Jump to view",
    ["edit_view"] = "Edit view",
    ["view_sorter"] = "View sorter",
    ["next_page"] = "Next page",
    ["previous_page"] = "Previous page",
    ["first_page"] = "First page",
    ["last_page"] = "Last page",
    ["new_page"] = "New page",
    ["cut_page"] = "Cut page",
    ["copy_page"] = "Copy page",
    ["paste_page"] = "Paste page",
    ["delete_page"] = "Delete page",
    ["jump_page"] = "Jump to page",
    ["edit_title"] = "Edit title && sections",
    ["edit_notes"] = "Edit notes",
    ["page_sorter"] = "Page sorter",
    ["toggle_notes"] = "Notes",
    ["toggle_bookmarks"] = "Bookmarks",
    ["manual"] = "Ipe &manual",
    ["finger_draw"] = "Draw with finger",
    ["tablet_hints"] = "Hints for tablet users",
    ["preferences"] = "Preferences",
    ["keyboard"] = "Onscreen keyboard",
    ["show_configuration"] = "Show &configuration",
    ["show_libraries"] = "Show &libraries",
    ["about_ipelets"] = "&Ipelet information",
    ["cloud_latex"] = "Enable online Latex-compilation",
    ["developer_reload_ipelets"] = "Reload ipelets",
    ["developer_list_shortcuts"] = "List shortcuts",
}


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
        local name = shortcut[1]
        if string.find(name, "ipelet_") then
            name = name:gsub("^ipelet_%d+_", "")
            local ipelet = _G.find_ipelet(name)
            if ipelet ~= nil then 
                if ipelet.label ~= nil then
                    name = ipelet.label
                end
                if ipelet.methods ~= nil then
                    local number = tonumber(shortcut[1]:gsub("%D", ""))
                    name = "(" .. name ..  " ipelet) " .. ipelet.methods[number].label
                else
                    name = name .. " ipelet"
                end
            end
        else
            if name_map[name] then 
            name = name_map[name] 
        print("ok")
    end
        end
        s = s .. name .. ": '" .. shortcut[2] .."' (shortcuts." .. shortcut[1] .. ")\n"
    end
    s = s:gsub("\n$", "")
    print(s)
    model.ui:explain("printed all shortcuts to the command line")
    -- local d = ipeui.Dialog(model.ui:win(), "Show shortcuts")
    -- d:add("xml", "text", {focus=true }, 1, 1)
    -- d:set("xml", s)
    
    -- _G.externalEditor(d, "xml")

    -- d:accept()
end
