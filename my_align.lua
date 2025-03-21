----------------------------------------------------------------------
-- align ipelet
----------------------------------------------------------------------
--[[

    This file is part of the extensible drawing editor Ipe.
    Copyright (c) 1993-2024 Otfried Cheong

    Ipe is free software; you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    As a special exception, you have permission to link Ipe with the
    CGAL library and distribute executables, as long as you follow the
    requirements of the Gnu General Public License in regard to all of
    the software in the executable aside from CGAL.

    Ipe is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with Ipe; if not, you can find it at
    "http://www.gnu.org/copyleft/gpl.html", or write to the Free
    Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

--]]

label = "My_Align"

revertOriginal = _G.revertOriginal

about = [[
This ipelet is a slight variation of the built in align ipelet, that respects decorations
]]

V = ipe.Vector

skip = 8.0

deco_size = 8.0

----------------------------------------------------------------------

function set_skip(model)
  local str = model:getString("Enter skip in points")
  if not str or str:match("^%s*$") then return end
  local s = tonumber(str)
  if not s then
    model:warning("Enter distance between consecutive objects in points")
    return
  end
  skip = s
  model.ui:explain("set skip distance to " .. skip .. " points")
end

function set_decoration_size(model)
  local str = model:getString("Enter the size of the decoration in points")
  if not str or str:match("^%s*$") then return end
  local s = tonumber(str)
  if not s then
    model:warning("Enter distance between consecutive objects in points")
    return
  end
  deco_size = s
  model.ui:explain("set decoration size to " .. deco_size .. " points")
end

----------------------------------------------------------------------

function simple_align(model, num)
  local p = model:page()
  if not p:hasSelection() then model.ui:explain("no selection") return end

  local pin = {}
  local selection = {}
  for i, obj, sel, lay in p:objects() do
    if sel == 2 then
      pin[obj:get("pinned")] = true
      selection[#selection + 1] = i
    end
  end
  if #selection == 0 then
     if (num >= 1 and num <= 7) then
	page_align(model, num)
     else
	model.ui:explain("nothing to align")
     end
     return
  end

  if (pin.fixed or
      pin.horizontal and methods[num].need_h or
      pin.vertical and methods[num].need_v) then
    model:warning("Cannot align objects",
		  "Some object is pinned and cannot be moved")
    return
  end

  local prim = p:primarySelection()
  local pbox = p:bbox(prim)
  local pref = pbox:bottomLeft()
  local pobj = p[prim]
  local deco = 0
  if p[prim]:type() == "group" then
	  if p[prim]:get("decoration") ~= "normal" then
      deco = -deco_size
    end
	end
  if pobj:type() == "text" then pref = pobj:matrix() * pobj:position() end

  local t = { label = "align " .. methods[num].label,
	      pno = model.pno,
	      vno = model.vno,
	      selection = selection,
	      original = p:clone(),
	      undo = revertOriginal,
	      pbox = pbox,
	      pref = pref,
	      fn = num,
        deco = deco
	    }

  t.redo = function (t, doc)
	     local p = doc[t.pno]
	     for _,i in ipairs(t.selection) do
	       local box = p:bbox(i)
	       local ref = box:bottomLeft()
         local deco_adj = deco
         if p[i]:type() == "group" then
          if p[i]:get("decoration") ~= "normal" then
            deco_adj = deco + deco_size
          end
        end
	       if (p[i]:type() == "text") then
		 ref = p[i]:matrix() * p[i]:position()
	       end
	       local vx, vy = 0, 0
	       if (t.fn == 1) then        -- top
		 vy = t.pbox:top() - box:top() - deco_adj
	       elseif (t.fn == 2) then    -- bottom
		 vy = t.pbox:bottom() - box:bottom() + deco_adj
	       elseif (t.fn == 3) then    -- left
		 vx = t.pbox:left() - box:left() + deco_adj
	       elseif (t.fn == 4) then    -- right
		 vx = t.pbox:right() - box:right() - deco_adj
	       elseif (t.fn == 5) then    -- center
		 vx = 0.5 * ((t.pbox:left() + t.pbox:right()) -
			   (box:left() + box:right()))
		 vy = 0.5 * ((t.pbox:bottom() + t.pbox:top()) -
			   (box:bottom() + box:top()))
	       elseif (t.fn == 6) then    -- h center
		 vx = 0.5 * ((t.pbox:left() + t.pbox:right()) -
			   (box:left() + box:right()))
	       elseif (t.fn ==  7) then   -- v center
		 vy = 0.5 * ((t.pbox:bottom() + t.pbox:top()) -
			   (box:bottom() + box:top()))
	       elseif (t.fn == 8) then    -- baseline
		 vy = t.pref.y - ref.y + deco_adj
	       end
	       p:transform(i, ipe.Translation(V(vx, vy)))
	     end
	   end
  model:register(t)
end

----------------------------------------------------------------------

function page_align(model, num)
   local p = model:page()
   if not p:hasSelection() then model.ui:explain("no selection") return end

   local pin = {}
   local selection = {}
   for i, obj, sel, lay in p:objects() do
      if sel then
	 pin[obj:get("pinned")] = true
	 selection[#selection + 1] = i
      end
   end
   if #selection == 0 then model.ui:explain("nothing to align") return end

   if (pin.fixed or
	  pin.horizontal and methods[num].need_h or
       pin.vertical and methods[num].need_v) then
      model:warning("Cannot align objects", "Some object is pinned and cannot be moved")
      return
   end

   local layout = model.doc:sheets():find("layout")
   local pref = -layout.origin
   local pbox = ipe.Rect()
   pbox:add(pref)
   pbox:add(pref + layout.papersize)

   local t = { label = "align " .. methods[num].label,
	       pno = model.pno,
	       vno = model.vno,
	       selection = selection,
	       original = p:clone(),
	       undo = revertOriginal,
	       pbox = pbox,
	       pref = pref,
	       fn = num,
   }

   t.redo = function (t, doc)
      local p = doc[t.pno]
      for _,i in ipairs(t.selection) do
        local box = p:bbox(i)
        local ref = box:bottomLeft()
        local deco_adj = 0
        if p[i]:type() == "group" then
          if p[i]:get("decoration") ~= "normal" then
            deco_adj = deco_size
          end
        end
        if (p[i]:type() == "text") then
            ref = p[i]:matrix() * p[i]:position()
        end
        local vx, vy = 0, 0
        if (t.fn == 5) then        -- center
            vx = 0.5 * ((t.pbox:left() + t.pbox:right()) -
            (box:left() + box:right()))
            vy = 0.5 * ((t.pbox:bottom() + t.pbox:top()) -
            (box:bottom() + box:top()))
        elseif (t.fn == 6) then    -- h center
            vx = 0.5 * ((t.pbox:left() + t.pbox:right()) -
            (box:left() + box:right()))
        elseif (t.fn ==  7) then   -- v center
            vy = 0.5 * ((t.pbox:bottom() + t.pbox:top()) -
            (box:bottom() + box:top()))
        elseif (t.fn == 1) then    --top
          local frame = doc:sheets():find("layout").framesize
          vy = frame.y -box:top() - deco_adj
        elseif (t.fn == 2) then    --bottom
          vy = -box:bottom() + deco_adj
        elseif (t.fn == 3) then    --left
            vx = -box:left() + deco_adj
        elseif (t.fn == 4) then    --right
          local frame = doc:sheets():find("layout").framesize
          vx = frame.x -box:right() - deco_adj
        end
        p:transform(i, ipe.Translation(V(vx, vy)))
            end
    end
   model:register(t)
end

----------------------------------------------------------------------

function sequence_align_setup(model, num, movement)
  local p = model:page()
  if not p:hasSelection() then model.ui:explain("no selection") return end

  local pin = {}
  for i, obj, sel, lay in p:objects() do
    if sel then pin[obj:get("pinned")] = true end
  end

  if pin.fixed or pin[movement] then
    model:warning("Cannot align objects",
		  "Some object is pinned and cannot be moved")
    return false
  end

  return true
end

----------------------------------------------------------------------

function ltr_skip(p, selection)
  local dx = { 0 }
  local xtarget = p:bbox(selection[1]):right() + skip
  for i = 2,#selection do
    local j = selection[i]
    local k = selection[i-1]
    if p[k]:type() == "group" then
      if p[k]:get("decoration") ~= "normal" then
        xtarget = xtarget + deco_size
      end
    end
    if p[j]:type() == "group" then
      if p[j]:get("decoration") ~= "normal" then
        xtarget = xtarget + deco_size
      end
    end
    dx[i] = xtarget - p:bbox(j):left()
    xtarget = xtarget + p:bbox(j):width() + skip
  end
  return dx
end

function ltr_equal_gaps(p, selection)
  local dx = { 0 }
  local total = 0.0
  for _,i in ipairs(selection) do 
    total = total + p:bbox(i):width() 
    if p[i]:type() == "group" then
      if p[i]:get("decoration") ~= "normal" then
        total = total + 2 * deco_size
      end
    end
  end
  if p[selection[1]]:type() == "group" then
    if p[selection[1]]:get("decoration") ~= "normal" then
      total = total - deco_size
    end
  end

  if p[selection[#selection]]:type() == "group" then
    if p[selection[#selection]]:get("decoration") ~= "normal" then
      total = total - deco_size
    end
  end
  local skip = (p:bbox(selection[#selection]):right()
	    - p:bbox(selection[1]):left() - total) / (#selection - 1)

  local xtarget = p:bbox(selection[1]):right() + skip
  for i = 2,#selection-1 do
    local j = selection[i]
    local k = selection[i-1]
    if p[k]:type() == "group" then
      if p[k]:get("decoration") ~= "normal" then
        xtarget = xtarget + deco_size
      end
    end
    if p[j]:type() == "group" then
      if p[j]:get("decoration") ~= "normal" then
        xtarget = xtarget + deco_size
      end
    end
    dx[i] = xtarget - p:bbox(j):left()
    xtarget = xtarget + p:bbox(j):width() + skip
  end
  dx[#selection] = 0
  return dx
end

function ltr_grid(p, selection, doc)
  local dx = { 0 }
  local total = 0.0
  for _,i in ipairs(selection) do 
    total = total + p:bbox(i):width() 
    if p[i]:type() == "group" then
      if p[i]:get("decoration") ~= "normal" then
        total = total + 2 * deco_size
      end
    end
  end
  local frame = doc:sheets():find("layout").framesize

  local skip = (frame.x - total) / (#selection + 1)

  local xtarget = skip
  for i = 1,#selection do
    local j = selection[i]
    local deco_adj = 0
    if p[j]:type() == "group" then
      if p[j]:get("decoration") ~= "normal" then
        xtarget = xtarget + deco_size
        deco_adj = deco_size
      end
    end
    dx[i] = xtarget - p:bbox(j):left()
    xtarget = xtarget + p:bbox(j):width() + skip + deco_adj
  end
  return dx
end

function ltr_centers(p, selection)
  local dx = { 0 }
  local front = p:bbox(selection[1])
  local rear = p:bbox(selection[#selection])
  local fcenter = (front:left() + front:right()) / 2
  local rcenter = (rear:left() + rear:right()) / 2
  local step = (rcenter - fcenter) / (#selection - 1)
  for i = 2,#selection-1 do
    local box = p:bbox(selection[i])
    local center = (box:left() + box:right()) / 2
    dx[i] = (fcenter + (i-1) * step) - center
  end
  dx[#selection] = 0
  return dx
end

function ltr_left(p, selection)
  local dx = { 0 }
  local front_id = selection[1]
  local rear_id = selection[#selection]
  local front = p:bbox(front_id)
  local rear = p:bbox(rear_id)
  local fleft = front:left()
  local rleft = rear:left()
  if p[front_id]:type() == "group" then
    if p[front_id]:get("decoration") ~= "normal" then
      fleft = fleft - deco_size
    end
  end
  if p[rear_id]:type() == "group" then
    if p[rear_id]:get("decoration") ~= "normal" then
      rleft = rleft - deco_size
    end
  end
  local step = (rleft - fleft) / (#selection - 1)
  for i = 2,#selection-1 do
    local j = selection[i]
    local box = p:bbox(j)
    local left_adj = 0
    if p[j]:type() == "group" then
      if p[j]:get("decoration") ~= "normal" then
        left_adj = deco_size
      end
    end
    dx[i] = (fleft + (i-1) * step) - box:left() + left_adj
  end
  dx[#selection] = 0
  return dx
end

function ltr_right(p, selection)
  local dx = { 0 }
  local front_id = selection[1]
  local rear_id = selection[#selection]
  local front = p:bbox(front_id)
  local rear = p:bbox(rear_id)
  local fright = front:right()
  local rright = rear:right()
  if p[front_id]:type() == "group" then
    if p[front_id]:get("decoration") ~= "normal" then
      fright = fright + deco_size
    end
  end
  if p[rear_id]:type() == "group" then
    if p[rear_id]:get("decoration") ~= "normal" then
      rright = rright + deco_size
    end
  end
  local step = (rright - fright) / (#selection - 1)
  for i = 2,#selection-1 do
    local j = selection[i]
    local box = p:bbox(j)
    local right_adj = 0
    if p[j]:type() == "group" then
      if p[j]:get("decoration") ~= "normal" then
        right_adj = deco_size
      end
    end
    dx[i] = (fright + (i-1) * step) - box:right() - right_adj
  end
  dx[#selection] = 0
  return dx
end

function ltr(model, num)
  if not sequence_align_setup(model, num, "horizontal") then return end

  local p = model:page()
  local selection = model:selection()
  table.sort(selection, function (a,b)
			  return (p:bbox(a):left() < p:bbox(b):left())
			end)

  if #selection == 1 or
    #selection == 2 and methods[num].compute ~= ltr_skip and methods[num].compute ~= ltr_grid then
    model.ui:explain("nothing to distribute")
    return
  end
  local dx = { }
  if methods[num].compute ~= ltr_grid then
    dx = methods[num].compute(p, selection)
  end

  

  local t = { label = methods[num].label,
	      pno = model.pno,
	      vno = model.vno,
	      selection = selection,
	      original = p:clone(),
	      undo = revertOriginal,
	      dx = dx,
	    }

  t.redo = function (t, doc)
	     local p = doc[t.pno]
       if methods[num].compute == ltr_grid then
        local dx = methods[num].compute(p, selection, doc)
        for i = 1,#t.selection do
          local j = t.selection[i]
          if dx[i] ~= 0 then p:transform(j, ipe.Translation(V(dx[i], 0.0))) end
        end
      else 
        for i = 1,#t.selection do
          local j = t.selection[i]
          local dx = t.dx[i]
          if dx ~= 0 then p:transform(j, ipe.Translation(V(dx, 0.0))) end
        end
      end
	     
	   end
  model:register(t)
end

----------------------------------------------------------------------

function ttb_skip(p, selection)
  local dy = { 0 }
  local ytarget = p:bbox(selection[1]):bottom() - skip
  for i = 2,#selection do
    local j = selection[i]
    local k = selection[i-1]
    if p[k]:type() == "group" then
      if p[k]:get("decoration") ~= "normal" then
        ytarget = ytarget - deco_size
      end
    end
    if p[j]:type() == "group" then
      if p[j]:get("decoration") ~= "normal" then
        ytarget = ytarget - deco_size
      end
    end
    dy[i] = ytarget - p:bbox(j):top()
    ytarget = ytarget - p:bbox(j):height() - skip
  end
  return dy
end

function ttb_equal_gaps(p, selection)
  local dy = { 0 }
  local total = 0.0
  for _,i in ipairs(selection) do 
    total = total + p:bbox(i):height() 
    if p[i]:type() == "group" then
      if p[i]:get("decoration") ~= "normal" then
        total = total + 2 * deco_size
      end
    end
  end
  if p[selection[1]]:type() == "group" then
    if p[selection[1]]:get("decoration") ~= "normal" then
      total = total - deco_size
    end
  end

  if p[selection[#selection]]:type() == "group" then
    if p[selection[#selection]]:get("decoration") ~= "normal" then
      total = total - deco_size
    end
  end
  local skip = (p:bbox(selection[1]):top()
	    - p:bbox(selection[#selection]):bottom()
	- total) / (#selection - 1)

  local ytarget = p:bbox(selection[1]):bottom() - skip
  for i = 2,#selection-1 do
    local j = selection[i]
    local k = selection[i-1]
    if p[k]:type() == "group" then
      if p[k]:get("decoration") ~= "normal" then
        ytarget = ytarget - deco_size
      end
    end
    if p[j]:type() == "group" then
      if p[j]:get("decoration") ~= "normal" then
        ytarget = ytarget - deco_size
      end
    end
    dy[i] = ytarget - p:bbox(j):top()
    ytarget = ytarget - p:bbox(j):height() - skip
  end
  dy[#selection] = 0
  return dy
end

function ttb_centers(p, selection)
  local dy = { 0 }
  local front = p:bbox(selection[1])
  local rear = p:bbox(selection[#selection])
  local fcenter = (front:top() + front:bottom()) / 2
  local rcenter = (rear:top() + rear:bottom()) / 2
  local step = (fcenter - rcenter) / (#selection - 1)
  for i = 2,#selection-1 do
    local box = p:bbox(selection[i])
    local center = (box:top() + box:bottom()) / 2
    dy[i] = (fcenter - (i-1) * step) - center
  end
  dy[#selection] = 0
  return dy
end

function ttb_top(p, selection)
  local dy = { 0 }
  local front_id = selection[1]
  local rear_id = selection[#selection]
  local front = p:bbox(front_id)
  local rear = p:bbox(rear_id)

  local ftop = front:top()
  local rtop = rear:top()
  if p[front_id]:type() == "group" then
    if p[front_id]:get("decoration") ~= "normal" then
      ftop = ftop + deco_size
    end
  end
  if p[rear_id]:type() == "group" then
    if p[rear_id]:get("decoration") ~= "normal" then
      rtop = rtop + deco_size
    end
  end
  local step = (ftop - rtop) / (#selection - 1)
  
  for i = 2,#selection-1 do
    local j = selection[i]
    local box = p:bbox(j)
    local top_adj = 0
    if p[j]:type() == "group" then
      if p[j]:get("decoration") ~= "normal" then
        top_adj = deco_size
      end
    end
    dy[i] = (ftop - (i-1) * step) - box:top() - top_adj
  end
  dy[#selection] = 0
  return dy
end

function ttb_bottom(p, selection)
  local dy = { 0 }
  local front_id = selection[1]
  local rear_id = selection[#selection]
  local front = p:bbox(front_id)
  local rear = p:bbox(rear_id)
  local fbottom = front:bottom()
  local rbottom = rear:bottom()

  if p[front_id]:type() == "group" then
    if p[front_id]:get("decoration") ~= "normal" then
      fbottom = fbottom - deco_size
    end
  end
  if p[rear_id]:type() == "group" then
    if p[rear_id]:get("decoration") ~= "normal" then
      rbottom = rbottom - deco_size
    end
  end

  local step = (fbottom - rear:bottom()) / (#selection - 1)
  for i = 2,#selection-1 do
    local j = selection[i]
    local box = p:bbox(j)
    local bottom_adj = 0
    if p[j]:type() == "group" then
      if p[j]:get("decoration") ~= "normal" then
        bottom_adj = deco_size
      end
    end
    dy[i] = (fbottom - (i-1) * step) - box:bottom() + bottom_adj
  end
  dy[#selection] = 0
  return dy
end

function ttb(model, num)
  if not sequence_align_setup(model, num, "vertical") then return end

  local p = model:page()
  local selection = model:selection()
  table.sort(selection, function (a,b)
			  return (p:bbox(a):top() > p:bbox(b):top())
			end)

  if #selection == 1 or
    #selection == 2 and methods[num].compute ~= ttb_skip then
    model.ui:explain("nothing to distribute")
    return
  end

  local dy = methods[num].compute(p, selection)

  local t = { label = methods[num].label,
	      pno = model.pno,
	      vno = model.vno,
	      selection = selection,
	      original = p:clone(),
	      undo = revertOriginal,
	      dy = dy,
	    }

  t.redo = function (t, doc)
	     local p = doc[t.pno]
	     for i = 1,#t.selection do
	       local j = t.selection[i]
	       local dy = t.dy[i]
	       if dy ~= 0 then p:transform(j, ipe.Translation(V(0.0, dy))) end
	     end
	   end
  model:register(t)
end

----------------------------------------------------------------------

methods = {
  { label = "align top", run = simple_align, need_v = true },
  { label = "align bottom", run = simple_align, need_v = true },
  { label = "align left", run = simple_align, need_h = true },
  { label = "align right", run = simple_align, need_h = true },
  { label = "align center", run = simple_align, need_v = true, need_h = true },
  { label = "align H center", run = simple_align, need_h = true },
  { label = "align V center", run = simple_align, need_v = true },
  { label = "align baseline", run = simple_align, need_v = true },
  { label = "distribute left to right", run=ltr, compute = ltr_skip },
  { label = "distribute horizontally", run=ltr, compute = ltr_equal_gaps },
  { label = "distribute H centers evenly", run=ltr, compute = ltr_centers },
  { label = "distribute left sides evenly", run=ltr, compute = ltr_left },
  { label = "distribute right sides evenly", run=ltr, compute = ltr_right },
  { label = "distribute top to bottom", run=ttb, compute = ttb_skip },
  { label = "distribute vertically", run=ttb, compute = ttb_equal_gaps },
  { label = "distribute V centers evenly", run=ttb, compute = ttb_centers },
  { label = "distribute top sides evenly", run=ttb, compute = ttb_top }, 
  { label = "distribute bottom sides evenly", run=ttb, compute = ttb_bottom }, 
  { label = "set skip...", run = set_skip },
  { label = "set decoration size...", run = set_decoration_size },
  { label = "distribute horizonally in grid", run=ltr, compute = ltr_grid },
}

----------------------------------------------------------------------
