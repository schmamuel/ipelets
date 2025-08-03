label = "Spline Offset"

-- Helper: Unit normal to vector (dx, dy)
local function unit_normal(dx, dy)
  local len = math.sqrt(dx*dx + dy*dy)
  if len == 0 then return 0, 0 end
  return -dy / len, dx / len
end

-- Helper: Sample cubic Bézier segment and compute offset points
local function offset_spline(segments, d, n_samples)
  local pts = {}

  for i = 1, #segments - 1, 3 do
    local p0 = segments[i]
    local p1 = segments[i+1]
    local p2 = segments[i+2]
    local p3 = segments[i+3]

    for j = 0, n_samples do
      local t = j / n_samples
      local u = 1 - t

      -- De Casteljau's formula for Bézier point
      local x = u^3 * p0.x + 3*u^2*t * p1.x + 3*u*t^2 * p2.x + t^3 * p3.x
      local y = u^3 * p0.y + 3*u^2*t * p1.y + 3*u*t^2 * p2.y + t^3 * p3.y

      -- Derivative (tangent)
      local dx = -3*p0.x*u^2 + 3*p1.x*(u^2 - 2*u*t) + 3*p2.x*(2*u*t - t^2) + 3*p3.x*t^2
      local dy = -3*p0.y*u^2 + 3*p1.y*(u^2 - 2*u*t) + 3*p2.y*(2*u*t - t^2) + 3*p3.y*t^2

      local nx, ny = unit_normal(dx, dy)
      table.insert(pts, {x = x + d * nx, y = y + d * ny})
    end
  end

  return pts
end


local function make_splinegon(points)
  local segs = { type="closedspline" }
  for i = 1, #points do
    segs[#segs+1] =  ipe.Vector(points[i].x,points[i].y)
  end
  return segs
end


local function make_spline(points)

  local segs = { type="spline" }
  for i = 1, #points do
    segs[#segs+1] =  ipe.Vector(points[i].x,points[i].y)
  end
  local shape = { type="curve", closed=false}
  shape[#shape + 1] = segs
  return shape
end

function getInt(model, string)
   local str
   if ipeui.getString ~= nil then
      str = ipeui.getString(model.ui, string)
   else 
      str = model:getString(string)
   end
   if not str or str:match("^%s*$)") then return 0 end
   return tonumber(str)
end

-- Main entry point
function run(model,num)
  local p = model:page()
  local sel = model:selection()
  local prim = p:primarySelection()
  if not prim then
    model:warning("Please select exactly one spline path.")
    return
  end

  local offset = getInt(model, "Enter distance")

  local obj = p[prim]
  if obj:type() ~= "path" then
    model:warning("Selected object is not a path.")
    return
  end

  local shape = obj:shape()

  if not shape or #shape ~= 1 then
    model:warning("The path must be a single spline.")
    return
  end

  local spline_segments = shape[1][1]
  local offset_points = offset_spline(spline_segments, offset, 100)


  local new_path = ipe.Path(model.attributes, {methods[num].make(offset_points)})
  new_path:setMatrix(obj:matrix())
  model:creation("create arc", new_path)
end

methods = {
    { label = "offset spline", run=run, make=make_spline},
    { label = "offset splinegon", run=run, make=make_splinegon},
  }

shortcuts.ipelet_1_splines = "Alt+Shift+S"