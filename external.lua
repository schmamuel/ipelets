label = "External editor"

function run(model)
    local p = model:page()
  local prim = p:primarySelection()

  if p[prim]:type() ~= "text" then
    model.ui:explain("selection is not text")
    return
  end
    local text = p[prim]:text()
  local d = ipeui.Dialog(model.ui:win(), "Edit text in external editor")
    d:add("text", "text", { syntax="latex", focus=true, spell_check=true }, 1, 1)
  _G.addEditorField(d, "text")
  d:set("text", text)
    _G.externalEditor(d, "text")
  local text_new = d:get("text")

  local t = { label="edit text in external editor",
		primary = prim,
    pno = model.pno,
    original = p:clone(),
    text_new = text_new,
    undo = _G.revertOriginal,
	      }
    t.redo = function (t, doc)
	       p[prim]:setText(text_new)
         model:autoRunLatex()
	     end
    model:register(t)
end 

-- function _G.MODEL:action_edit()
--   local p = self:page()
--   local prim = p:primarySelection()
--   if not prim then self.ui:explain("no selection") return end
--   local obj = p[prim]
--   if obj:type() == "text" then
--     self:action_edit_text(prim, obj)
--   elseif obj:type() == "path" then
--     self:action_edit_path(prim, obj)
--   elseif obj:type() == "group" then
--     local t = 0
--     for i = 1,obj:count() do
--       if obj:elementType(i) == "text" then t = t + 1 end
--     end
--     if t == 1 then 
--       self:action_edit_group_text(prim, obj) 
--     else
--      self:saction_edit_group()
--     end
--   else
--     self:warning("Cannot edit " .. obj:type() .. " object",
-- 		 "Only text objects, path objects, and groups with text can be edited")
--   end
-- end

-----------------

shortcuts.ipelet_1_external = "Alt+Shift+E"