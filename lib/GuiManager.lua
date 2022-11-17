local bit = require("bit")

-- based on https://github.com/danielknobe/blobbyvolley2/blob/v1.0/src/IMGUI.cpp
local GuiManager = {
  queue = nil,
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
  }

  while not Queue.isEmpty(self.queue) do
    local obj = Queue.pop(self.queue)
    local case = switch[obj.type]
    if case then
      case(obj)
    else -- default case
      print("Unknown GuiManager.queue ObjectType " .. obj.type)
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

  local fontSize = FONT_WIDTH_NORMAL
  if bit.band(flags, TF_SMALL_FONT) ~= 0 then
    fontSize = FONT_WIDTH_SMALL
  end
  local tolerance = 0

  -- React to mouse input.
  local mousepos = Vector2d(love.mouse.getPosition())
  if (
    mousepos.x + tolerance >= position.x and
    mousepos.y + tolerance * 2 >= position.y and
    mousepos.x - tolerance <= position.x + text:len() * fontSize and
    mousepos.y - tolerance * 2 <= position.y + fontSize
  ) then
    flags = bit.bor(flags, TF_HIGHLIGHT)

    if love.mouse.isDown(1) then
      clicked = true
    end
  end

  Queue.push(self.queue, { type = ObjectType.BUTTON, pos1 = position, text = text, flags = flags })

  return clicked
end

-- Vector2d position, string text, number flags
function GuiManager:__getTextPosition(position, text, flags)
  local fontSize = FONT_WIDTH_NORMAL
  if bit.band(flags, TF_SMALL_FONT) ~= 0 then
    fontSize = FONT_WIDTH_SMALL
  end

  if bit.band(flags, TF_ALIGN_CENTER) ~= 0 then
    position.x = position.x - text:len() * fontSize / 2
  elseif bit.band(flags, TF_ALIGN_RIGHT) ~= 0 then
    position.x = position.x -text:len() * fontSize
  end

  return position
end

return GuiManager
