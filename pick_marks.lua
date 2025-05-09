label = "Pick & Apply Mark Properties"

revertOriginal = _G.revertOriginal

about = [[
Changes the behaviour of pick and apply properties for references to allow picking and applying the markshape.
]]


function _G.MODEL:pick_properties_reference(obj)
	local a = self.attributes
	a.stroke = obj:get("stroke")
	local fill = obj:get("fill")
	print(fill)
	if fill ~= "undefined" then
		a.fill = obj:get("fill")
	end
	a.pen = obj:get("pen")
	a.symbolsize = obj:get("symbolsize")
	local name = obj:get("markshape")
	if name ~= "undefined" then
		a.markshape = name
	end
end

function _G.apply_properties_reference(obj, a)
    obj:set("stroke", a.stroke)
    obj:set("fill", a.fill)
    obj:set("pen", a.pen)
    obj:set("symbolsize", a.symbolsize)
    if obj:get("markshape") ~= "undefined" then
        a.markshape = obj:set("markshape", a.markshape)
    end
end
