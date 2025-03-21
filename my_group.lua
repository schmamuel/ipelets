label = "My_Group"

revertOriginal = _G.revertOriginal

about = [[
This ipelet changes the group and ungroup operations of ipe to not change the layers of the objects
]]

function group(model)
	local p = model:page()
	local selection = model:selection()
	local elements = {}
	for _,i in ipairs(selection) do
	  elements[#elements + 1] = p[i]:clone()
	  elements[#elements]:setCustom(p:layerOf(i))
	end
	local final = ipe.Group(elements)
	local prim = p:primarySelection()
	p:deselectAll()
	local t = { label="group",
		   pno = model.pno,
		   vno = model.vno,
		   original = p:clone(),
		   selection = selection,
		   layer = p:layerOf(prim),
		   final = final,
		   undo = revertOriginal,
		   elements = elements,
		 }
	t.redo = function (t, doc)
		  local p = doc[t.pno]
		  for i = #t.selection,1,-1 do p:remove(t.selection[i]) end
		  p:insert(nil, t.final, 1, t.layer)
		end
    model:register(t)
  end

  --changes the ungroup behaviour to not put everything on the active layer

  function ungroup(model)
	local p = model:page()
	local prim = p:primarySelection()
	if p[prim]:type() ~= "group" then
	  model.ui:explain("primary selection is not a group")
	  return
	end
	p:deselectAll()
	
	local t = { label="ungroup",
			pno = model.pno,
			vno = model.vno,
			original = p[prim]:clone(),
			primary = prim,
			originalLayer = p:layerOf(prim),
			elements = p[prim]:elements(),
			matrix = p[prim]:matrix(),
			layer = p:layerOf(prim),
		  }

	 t.undo = function (t, doc)
	 	   local p = doc[t.pno]
	 	   for i = 1,#t.elements do p:remove(#p) end
	 	   p:insert(t.primary, t.original, nil, t.originalLayer)
	 	 end
	t.redo = function (t, doc)
		   local p = doc[t.pno]
		   layers = p:layers()   
		   p:remove(t.primary)
		   counter = 0
		   for test,obj in ipairs(t.elements) do
			local found = false
			for _, layername in ipairs(layers) do
				if layername == obj:getCustom() then 
					found = true 
				end
			end
			 if (found) then
			 p:insert(nil, obj, 2, obj:getCustom())
			 else 
				p:insert(nil, obj, 2, t.layer)
				counter = counter + 1
			 end
			 p:transform(#p, t.matrix)
		   end
		   p:ensurePrimarySelection()
		   if ( counter > 0 ) then 
        model:warning("Original layer of " .. counter .. " elements was deleted or renamed, they were put on the layer of the group instead")
		   end
		 end
     model:register(t)
	
  end

----------------------------------------------------------------------

methods = {
  { label = "group", run = group },
  { label = "ungroup", run = ungroup },
}
----------------------------------------------------------------------

shortcuts.ipelet_1_my_group = shortcuts.group
shortcuts.ipelet_2_my_group = shortcuts.ungroup
shortcuts.group = nil
shortcuts.ungroup = nil