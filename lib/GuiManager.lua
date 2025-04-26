local bit = require("bit")

-- based on https://github.com/danielknobe/blobbyvolley2/blob/v1.0/src/IMGUI.cpp
local GuiManager = {
  queue = nil,
  lastMouseDown = false,
}

local ObjectType = {
  IMAGE = 1,
  OVERLAY = 2,
  TEXT = 3,
  BUTTON = 4,
  SCROLLBAR = 5,
  ACTIVESCROLLBAR = 6,
  EDITBOX = 7,
  ACTIVEEDITBOX = 8,
  SELECTBOX = 9,
  ACTIVESELECTBOX = 10,
  BLOB = 11,
  CHAT = 12,
}

function GuiManager:init()
  self.queue = Queue.new()
end

function GuiManager:draw()
  -- based on "A way to write switch-case statements in lua." https://gist.github.com/FreeBirdLjj/6303864
  local switch = {
    [ObjectType.IMAGE] = function(obj)
      RenderManager:drawImage(obj.text, obj.pos1)
    end,
    [ObjectType.OVERLAY] = function(obj)
      RenderManager:drawOverlay(obj.pos1, obj.pos2, obj.color)
    end,
    [ObjectType.TEXT] = function(obj)
      RenderManager:drawText(obj.text, obj.pos1, obj.flags)
    end,
    [ObjectType.BUTTON] = function(obj)
      RenderManager:drawText(obj.text, obj.pos1, obj.flags)
    end,
    [ObjectType.SCROLLBAR] = function(obj)
      RenderManager:drawOverlay(obj.pos1, obj.pos1 + Vector2d(210, 25), { 0, 0, 0, 0.5 })
      RenderManager:drawImage("res/gfx/scrollbar.bmp", obj.pos1 + Vector2d(obj.pos2.x * 200, 0))
    end,
    [ObjectType.EDITBOX] = function(obj)
      local fontSize = self:__getFontSize(obj.flags)

      RenderManager:drawOverlay(obj.pos1, obj.pos1 + Vector2d(10 + obj.length * fontSize, 10 + fontSize), { 0, 0, 0, 0.5 })
      RenderManager:drawText(obj.text, obj.pos1 + Vector2d(5, 5), obj.flags)
    end,
    [ObjectType.SELECTBOX] = function(obj)
      local fontSize = self:__getFontSize(obj.flags) + self:__getLineSpacerSize(obj.flags)

      RenderManager:drawOverlay(obj.pos1, obj.pos2, { 0, 0, 0, 0.5 })

      for i, entry in ipairs(obj.entries) do
        if i == obj.selected then
          RenderManager:drawText(entry, Vector2d(5 + obj.pos1.x, 5 + obj.pos1.y + ((i - 1) * fontSize)), bit.bor(obj.flags, TF_HIGHLIGHT))
        else
          RenderManager:drawText(entry, Vector2d(5 + obj.pos1.x, 5 + obj.pos1.y + ((i - 1) * fontSize)), obj.flags)
        end
      end

      RenderManager:drawImage("res/gfx/pfeil_oben.bmp", Vector2d(obj.pos2.x - 27, obj.pos1.y + 3))
      RenderManager:drawImage("res/gfx/pfeil_unten.bmp", Vector2d(obj.pos2.x - 27, obj.pos2.y - 27))
    end,
  }

  while not Queue.isEmpty(self.queue) do
    local obj = Queue.pop(self.queue)
    local case = switch[obj.type]
    if case then
      case(obj)
    else -- default case
      print("Warning: Unknown GuiManager.queue ObjectType " .. obj.type)
    end
  end
end

-- Vector2d position, string filename
function GuiManager:addImage(position, filename)
  Queue.push(self.queue, { type = ObjectType.IMAGE, pos1 = position, text = filename })
end

-- Vector2d pos1, Vector2d pos2, table<Color> color
function GuiManager:addOverlay(pos1, pos2, color)
  color = color or { 0, 0, 0, 0.65 }

  Queue.push(self.queue, { type = ObjectType.OVERLAY, pos1 = pos1, pos2 = pos2, color = color })
end

-- Vector2d position, string text, number flags
function GuiManager:addText(position, text, flags)
  flags = flags or TF_NORMAL
  position = self:__getTextPosition(position, text, flags)

  Queue.push(self.queue, { type = ObjectType.TEXT, pos1 = position, text = text, flags = flags })
end

-- Vector2d position, string text, number flags
function GuiManager:addButton(position, text, flags)
  flags = flags or TF_NORMAL
  position = self:__getTextPosition(position, text, flags)

  local clicked = false

  local fontSize = self:__getFontSize(flags)

  -- React to mouse input.
  local mousepos = Vector2d(love.mouse.getPosition())
  if (
    mousepos.x >= position.x and
    mousepos.y >= position.y and
    mousepos.x <= position.x + text:len() * fontSize and
    mousepos.y <= position.y + fontSize
  ) then
    flags = bit.bor(flags, TF_HIGHLIGHT)

    if love.mouse.isDown(1) and not self.lastMouseDown then
      clicked = true
    end
    self.lastMouseDown = love.mouse.isDown(1)
  end

  Queue.push(self.queue, { type = ObjectType.BUTTON, pos1 = position, text = text, flags = flags })

  return clicked
end

-- Vector2d position, number value
function GuiManager:addScrollbar(position, value)
  -- React to mouse input.
  local mousepos = Vector2d(love.mouse.getPosition())
  if (
    mousepos.x + 5 > position.x and
    mousepos.y > position.y and
    mousepos.x < position.x + 205 and
    mousepos.y < position.y + 24
  ) then
    if love.mouse.isDown(1) then
      value = (mousepos.x - position.x) / 200
    end
  end

  Queue.push(self.queue, { type = ObjectType.SCROLLBAR, pos1 = position, pos2 = Vector2d(value, 0) })

  return value
end

-- Vector2d position, number length, string text, number cursorPosition, number flags
function GuiManager:addEditbox(position, length, text, cursorPosition, flags)
  flags = flags or TF_NORMAL

  Queue.push(self.queue, { type = ObjectType.EDITBOX, pos1 = position, pos2 = cursorPosition, length = length, text = text, flags = flags })
end

-- Vector2d pos1, Vector2d pos2, table<string> entries, number selected, number flags
function GuiManager:addSelectbox(pos1, pos2, entries, selected, flags)
  flags = flags or TF_NORMAL

  local fontSize = self:__getFontSize(flags) + self:__getLineSpacerSize(flags)
  local itemsPerPage = math.floor(pos2.y - pos1.y - 10) / fontSize

  -- React to mouse input.
  local mousepos = Vector2d(love.mouse.getPosition())
  if (
    mousepos.x > pos1.x and
    mousepos.y > pos1.y + 5 and
    mousepos.x < pos2.x - 35 and
    mousepos.y < pos2.y - 5
  ) then
    if love.mouse.isDown(1) and not self.lastMouseDown then
      local tmp = math.floor((mousepos.y - pos1.y - 5) / fontSize)
      if (tmp >= 0 and tmp < #entries) then
        selected = 1 + tmp
      end
    end
    self.lastMouseDown = love.mouse.isDown(1)
  end

  Queue.push(self.queue, { type = ObjectType.SELECTBOX, pos1 = pos1, pos2 = pos2, entries = entries, selected = selected, flags = flags })

  return selected
end

-- number flags
function GuiManager:__getFontSize(flags)
  if bit.band(flags, TF_SMALL_FONT) ~= 0 then
    return FONT_WIDTH_SMALL
  end

  return FONT_WIDTH_NORMAL
end

-- number flags
function GuiManager:__getLineSpacerSize(flags)
  if bit.band(flags, TF_SMALL_FONT) ~= 0 then
    return LINE_SPACER_SMALL
  end

  return LINE_SPACER_NORMAL
end

-- Vector2d position, string text, number flags
function GuiManager:__getTextPosition(position, text, flags)
  local fontSize = self:__getFontSize(flags)

  if bit.band(flags, TF_ALIGN_CENTER) ~= 0 then
    position.x = position.x - text:len() * fontSize / 2
  elseif bit.band(flags, TF_ALIGN_RIGHT) ~= 0 then
    position.x = position.x -text:len() * fontSize
  end

  return position
end

return GuiManager
