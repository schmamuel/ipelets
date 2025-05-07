label = "Regular n-gon"

revertOriginal = _G.revertOriginal

about = [[
modification of the ipe native "regular k-gon" so that the bottom edge of the k-gon is horizontal
]]

V = ipe.Vector





function checkPrimaryIsCircle(model, arc_ok)
  local p = model:page()
  local prim = p:primarySelection()
  if not prim then model.ui:explain("no selection") return end
  local obj = p[prim]
  if obj:type() == "path" then
    local shape = obj:shape()
    if #shape == 1 then
      local s = shape[1]
      if s.type == "ellipse" then
	return prim, obj, s[1]:translation(), shape
      end
      if arc_ok and s.type == "curve" and #s == 1 and s[1].type == "arc" then
	return prim, obj, s[1].arc:matrix():translation(), shape
      end
    end
  end
  if arc_ok then
    model:warning("Primary selection is not an arc, a circle, or an ellipse")
  else
    model:warning("Primary selection is not a circle or an ellipse")
  end
end



local function incorrect_input(model)
  model:warning("Cannot create parabolas",
		"Primary selection is not a segment, or " ..
		  "other selected objects are not marks")
end

function run(model)
  local prim, obj, pos, shape = checkPrimaryIsCircle(model, false)
  if not prim then return end

  local str = model:getString("Enter number of corners")
  if not str or str:match("^%s*$)") then return end
  local k = tonumber(str)
  if not k then
    model:warning("Enter a number between 3 and 1000!")
    return
  end

  local m = shape[1][1]
  local center = m:translation()
  local v = m * V(1,0)
  local radius = (v - center):len()

  local curve = { type="curve", closed=true }
  local alpha = 2 * math.pi / k
  local offset = (math.pi + ((k + 1) % 2) * alpha) / 2

  local v0 = center + radius * ipe.Direction(offset)

  for i = 1,k-1 do
    local v1 = center + radius * ipe.Direction(i * alpha + offset)
    curve[#curve + 1] = { type="segment", v0, v1 }
    v0 = v1
  end

  local kgon = ipe.Path(model.attributes, { curve } )
  kgon:setMatrix(obj:matrix())
  model:creation("create regular k-gon", kgon)
end

----------------------------------------------------------------------
shortcuts.ipelet_1_regular_n_gon = "n"