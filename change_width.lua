label = "Change Width"

local function boxshape(v1, v2)
    return { type="curve", closed=true;
         { type="segment"; v1, _G.V(v1.x, v2.y) },
         { type="segment"; _G.V(v1.x, v2.y), v2 },
         { type="segment"; v2, _G.V(v2.x, v1.y) } }
end

CHANGEWIDTHTOOL = {}
CHANGEWIDTHTOOL.__index = CHANGEWIDTHTOOL

function CHANGEWIDTHTOOL:new(model, prim, obj, selection)
  local tool = {}
  _G.setmetatable(tool, CHANGEWIDTHTOOL)
  tool.model = model
  tool.prim = prim
  tool.obj = obj
  tool.pos = obj:matrix() * obj:position()
  tool.wid = obj:get("width")
  tool.align = obj:get("horizontalalignment")
  tool.selection = selection
  tool.page = model:page()
  if tool.align == "right" then
    tool.posfactor = -1
    tool.dir = -1
  elseif tool.align == "hcenter" then
    tool.posfactor = -0.5
    tool.dir = 1
  else
    tool.posfactor = 0
    tool.dir = 1
  end
  model.ui:shapeTool(tool)
  tool.setColor(1.0, 0, 1.0)
  local pos = tool.pos + _G.V(tool.posfactor * tool.wid, 0)
  tool.setShape( { boxshape(pos, pos + _G.V(tool.wid, -20)) } )
  model.ui:update(false) -- update tool
  return tool
end

function CHANGEWIDTHTOOL:compute()
  local w = self.model.ui:pos()
  self.nwid = self.wid + self.dir * (w.x - self.v.x)
  local pos = self.pos + _G.V(self.posfactor * self.nwid, 0)
  self.shape = boxshape(pos, pos + _G.V(self.nwid, -20))
end

function CHANGEWIDTHTOOL:mouseButton(button, modifiers, press)
  if press then
    if not self.v then self.v = self.model.ui:pos() end
    if self.align == "hcenter" and self.v.x < self.pos.x then self.dir = -1 end
  else
    self:compute()
    self.model.ui:finishTool()
    if self.nwid <= 0 then
      self.model:warning("The width of a text object should be positive.")
      return
    end
    local p = self.model:page()
    local non_minipages = 0
    for _,i in ipairs(self.selection) do
        if p[i]:type() == "text" and p[i]:get("minipage") then
            self.model:setAttributeOfPrimary(i, "width", self.nwid)
        else
          non_minipages = non_minipages + 1
        end
    end

    if non_minipages > 0 then
      self.model:warning(non_minipages .. " non-minipage")
    end
    self.model:autoRunLatex()
  end
end

function CHANGEWIDTHTOOL:mouseMove()
  if self.v then
    self:compute()
    self.setShape( { self.shape } )
    self.model.ui:update(false) -- update tool
  end
end

function CHANGEWIDTHTOOL:key(text, modifiers)
  if text == "\027" then
    self.model.ui:finishTool()
    return true
  else
    return false
  end
end

function run(model)
    local p = model:page()
    local prim = p:primarySelection()
    if not prim then
        model.ui:explain("no selection")
        return
    end

    if p[prim]:type() ~= "text" or not p[prim]:get("minipage") then
        model.ui:explain("the primary selection is not a minipage")
        return
    end
    CHANGEWIDTHTOOL:new(model, prim, p[prim], model:selection())
end 

--------------------------

shortcuts.ipelet_1_change_width = shortcuts.change_width
shortcuts.change_width = nil