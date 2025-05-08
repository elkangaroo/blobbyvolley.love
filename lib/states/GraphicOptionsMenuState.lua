local GraphicOptionsMenuState = {}
GraphicOptionsMenuState.__index = GraphicOptionsMenuState

setmetatable(GraphicOptionsMenuState, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

function GraphicOptionsMenuState:__construct()
  love.mouse.setVisible(true)

  self:load()
end

function GraphicOptionsMenuState:update(dt)
  GuiManager:addImage(Vector2d(0, 0), "res/gfx/backgrounds/" .. GameConfig.get("background"))
  GuiManager:addOverlay(Vector2d(0, 0), Vector2d(800, 600))

  --
  GuiManager:addText(Vector2d(34, 10), "video settings")
  GuiManager:addText(Vector2d(34, 40), "fullscreen mode", TF_CONCEAL)
  GuiManager:addText(Vector2d(34, 70), "window mode")
  GuiManager:addImage(Vector2d(34 - 29, 70), "res/gfx/pfeil_rechts.bmp")

  -- if GuiManager:addButton(Vector2d(34, 40), "fullscreen") then
  --   self.fullscreen = true
  -- end
  -- if GuiManager:addButton(Vector2d(34, 70), "window") then
  --   self.fullscreen = false
  -- end

  -- if self.fullscreen then
  --   GuiManager:addImage(Vector2d(34 - 29, 40), "res/gfx/pfeil_rechts.bmp")
  -- else
  --   GuiManager:addImage(Vector2d(34 - 29, 70), "res/gfx/pfeil_rechts.bmp")
  -- end

  --
  GuiManager:addText(Vector2d(444, 10), "render device")
  GuiManager:addText(Vector2d(444, 40), "OpenGL", TF_CONCEAL)
  GuiManager:addText(Vector2d(444, 70), "SDL", TF_CONCEAL)

  -- if GuiManager:addButton(Vector2d(444, 40), "OpenGL") then
  --   self.renderer = "OpenGL"
  -- end
  -- if GuiManager:addButton(Vector2d(444, 70), "SDL") then
  --   self.renderer = "SDL"
  -- end

  -- if self.renderer == "OpenGL" then
  --   GuiManager:addImage(Vector2d(444 - 29, 40), "res/gfx/pfeil_rechts.bmp")
  -- else
  --   GuiManager:addImage(Vector2d(444 - 29, 70), "res/gfx/pfeil_rechts.bmp")
  -- end

  --
  GuiManager:addText(Vector2d(34, 110), "show shadow")
  if GuiManager:addButton(Vector2d(72, 140), "yes") then
    self.showShadow = true
  end
  if GuiManager:addButton(Vector2d(220, 140), "no") then
    self.showShadow = false
  end

  if self.showShadow then
    GuiManager:addImage(Vector2d(72 - 29, 140), "res/gfx/pfeil_rechts.bmp")
  else
    GuiManager:addImage(Vector2d(220 - 29, 140), "res/gfx/pfeil_rechts.bmp")
  end

  --
  GuiManager:addText(Vector2d(280, 170), "blob colors")

  -- left blob
  GuiManager:addText(Vector2d(34, 210), "left player")
  GuiManager:addText(Vector2d(34, 240), "red")
  self.leftColorRed = GuiManager:addScrollbar(Vector2d(160, 240), self.leftColorRed)
  GuiManager:addText(Vector2d(34, 270), "green")
  self.leftColorGreen = GuiManager:addScrollbar(Vector2d(160, 270), self.leftColorGreen)
  GuiManager:addText(Vector2d(34, 300), "blue")
  self.leftColorBlue = GuiManager:addScrollbar(Vector2d(160, 300), self.leftColorBlue)

  GuiManager:addText(Vector2d(34, 360), "morphing blob?")
  if GuiManager:addButton(Vector2d(72, 390), "yes") then
    self.leftMorphing = true
  end
  if GuiManager:addButton(Vector2d(220, 390), "no") then
    self.leftMorphing = false
  end

  if self.leftMorphing then
    GuiManager:addImage(Vector2d(72 - 29, 390), "res/gfx/pfeil_rechts.bmp")
  else
    GuiManager:addImage(Vector2d(220 - 29, 390), "res/gfx/pfeil_rechts.bmp")
  end

  local leftColor = { self.leftColorRed, self.leftColorGreen, self.leftColorBlue }
  if self.leftMorphing then
    leftColor = RenderManager:getOscillationColor()
  end
  GuiManager:addBlob(Vector2d(110, 500), leftColor)

  -- right blob
  GuiManager:addText(Vector2d(434, 210), "right player")
  GuiManager:addText(Vector2d(434, 240), "red")
  self.rightColorRed = GuiManager:addScrollbar(Vector2d(560, 240), self.rightColorRed)
  GuiManager:addText(Vector2d(434, 270), "green")
  self.rightColorGreen = GuiManager:addScrollbar(Vector2d(560, 270), self.rightColorGreen)
  GuiManager:addText(Vector2d(434, 300), "blue")
  self.rightColorBlue = GuiManager:addScrollbar(Vector2d(560, 300), self.rightColorBlue)

  GuiManager:addText(Vector2d(434, 360), "morphing blob?")
  if GuiManager:addButton(Vector2d(472, 390), "yes") then
    self.rightMorphing = true
  end
  if GuiManager:addButton(Vector2d(620, 390), "no") then
    self.rightMorphing = false
  end

  if self.rightMorphing then
    GuiManager:addImage(Vector2d(472 - 29, 390), "res/gfx/pfeil_rechts.bmp")
  else
    GuiManager:addImage(Vector2d(620 - 29, 390), "res/gfx/pfeil_rechts.bmp")
  end

  local rightColor = { self.rightColorRed, self.rightColorGreen, self.rightColorBlue }
  if self.rightMorphing then
    rightColor = RenderManager:getOscillationColor()
  end
  GuiManager:addBlob(Vector2d(670, 500), rightColor)

  --
  if GuiManager:addButton(Vector2d(224, 530), "ok") then
    self:save()
    app.state:switchState(OptionsMenuState())
  end

  if GuiManager:addButton(Vector2d(424, 530), "cancel") then
    self:load()
    app.state:switchState(OptionsMenuState())
  end
end

function GraphicOptionsMenuState:load()
  GameConfig.load()

  self.fullscreen = GameConfig.getBoolean("fullscreen")
  self.renderer = GameConfig.get("device")
  self.showShadow  = GameConfig.getBoolean("show_shadow")
  self.leftColorRed = GameConfig.getNumber("left_blobby_color_r") / 255
  self.leftColorGreen = GameConfig.getNumber("left_blobby_color_g") / 255
  self.leftColorBlue = GameConfig.getNumber("left_blobby_color_b") / 255
  self.leftMorphing = GameConfig.getBoolean("left_blobby_oscillate")
  self.rightColorRed = GameConfig.getNumber("right_blobby_color_r") / 255
  self.rightColorGreen = GameConfig.getNumber("right_blobby_color_g") / 255
  self.rightColorBlue = GameConfig.getNumber("right_blobby_color_b") / 255
  self.rightMorphing = GameConfig.getBoolean("right_blobby_oscillate")

  --
  app.initConfig()
end

function GraphicOptionsMenuState:save()
  GameConfig.set("fullscreen", self.fullscreen)
  GameConfig.set("device", self.renderer)
  GameConfig.set("show_shadow", self.showShadow)
  GameConfig.set("left_blobby_color_r", self.leftColorRed * 255)
  GameConfig.set("left_blobby_color_g", self.leftColorGreen * 255)
  GameConfig.set("left_blobby_color_b", self.leftColorBlue * 255)
  GameConfig.set("left_blobby_oscillate", self.leftMorphing)
  GameConfig.set("right_blobby_color_r", self.rightColorRed * 255)
  GameConfig.set("right_blobby_color_g", self.rightColorGreen * 255)
  GameConfig.set("right_blobby_color_b", self.rightColorBlue * 255)
  GameConfig.set("right_blobby_oscillate", self.rightMorphing)

  GameConfig.save()

  --
  app.initConfig()
end

function GraphicOptionsMenuState:draw()
  GuiManager:draw()
end

-- KeyConstant key
function GraphicOptionsMenuState:keypressed(key)
end

-- KeyConstant key
function GraphicOptionsMenuState:keyreleased(key)
end

-- String text
function GraphicOptionsMenuState:textinput(text)
end

function GraphicOptionsMenuState:getStateName()
  return "GraphicOptionsMenuState"
end

return GraphicOptionsMenuState
