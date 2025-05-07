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
  --   self.mFullscreen = true
  -- end
  -- if GuiManager:addButton(Vector2d(34, 70), "window") then
  --   self.mFullscreen = false
  -- end

  -- if self.mFullscreen then
  --   GuiManager:addImage(Vector2d(34 - 29, 40), "res/gfx/pfeil_rechts.bmp")
  -- else
  --   GuiManager:addImage(Vector2d(34 - 29, 70), "res/gfx/pfeil_rechts.bmp")
  -- end

  --
  GuiManager:addText(Vector2d(444, 10), "render device")
  GuiManager:addText(Vector2d(444, 40), "OpenGL", TF_CONCEAL)
  GuiManager:addText(Vector2d(444, 70), "SDL", TF_CONCEAL)

  -- if GuiManager:addButton(Vector2d(444, 40), "OpenGL") then
  --   self.mRenderer = "OpenGL"
  -- end
  -- if GuiManager:addButton(Vector2d(444, 70), "SDL") then
  --   self.mRenderer = "SDL"
  -- end

  -- if self.mRenderer == "OpenGL" then
  --   GuiManager:addImage(Vector2d(444 - 29, 40), "res/gfx/pfeil_rechts.bmp")
  -- else
  --   GuiManager:addImage(Vector2d(444 - 29, 70), "res/gfx/pfeil_rechts.bmp")
  -- end

  --
  GuiManager:addText(Vector2d(34, 110), "show shadow")
  if GuiManager:addButton(Vector2d(72, 140), "yes") then
    self.mShowShadow = true
  end
  if GuiManager:addButton(Vector2d(220, 140), "no") then
    self.mShowShadow = false
  end

  if self.mShowShadow then
    GuiManager:addImage(Vector2d(72 - 29, 140), "res/gfx/pfeil_rechts.bmp")
  else
    GuiManager:addImage(Vector2d(220 - 29, 140), "res/gfx/pfeil_rechts.bmp")
  end

  --
  GuiManager:addText(Vector2d(280, 170), "blob colors")

    -- left blob
    GuiManager:addText(Vector2d(34, 210), "left player")
    GuiManager:addText(Vector2d(34, 240), "red")
    self.mR1 = GuiManager:addScrollbar(Vector2d(160, 240), self.mR1)
    GuiManager:addText(Vector2d(34, 270), "green")
    self.mG1 = GuiManager:addScrollbar(Vector2d(160, 270), self.mG1)
    GuiManager:addText(Vector2d(34, 300), "blue")
    self.mB1 = GuiManager:addScrollbar(Vector2d(160, 300), self.mB1)

    GuiManager:addText(Vector2d(34, 360), "morphing blob?")
    if GuiManager:addButton(Vector2d(72, 390), "yes") then
      self.mLeftMorphing = true
    end
    if GuiManager:addButton(Vector2d(220, 390), "no") then
      self.mLeftMorphing = false
    end

    if self.mLeftMorphing then
      GuiManager:addImage(Vector2d(72 - 29, 390), "res/gfx/pfeil_rechts.bmp")
    else
      GuiManager:addImage(Vector2d(220 - 29, 390), "res/gfx/pfeil_rechts.bmp")
    end

    local color1 = { self.mR1, self.mG1, self.mB1 }
    if self.mLeftMorphing then
      color1 = RenderManager:getOscillationColor()
    end
    GuiManager:addBlob(Vector2d(110, 500), color1)

    -- right blob
    GuiManager:addText(Vector2d(434, 210), "right player")
    GuiManager:addText(Vector2d(434, 240), "red")
    self.mR2 = GuiManager:addScrollbar(Vector2d(560, 240), self.mR2)
    GuiManager:addText(Vector2d(434, 270), "green")
    self.mG2 = GuiManager:addScrollbar(Vector2d(560, 270), self.mG2)
    GuiManager:addText(Vector2d(434, 300), "blue")
    self.mB2 = GuiManager:addScrollbar(Vector2d(560, 300), self.mB2)

    GuiManager:addText(Vector2d(434, 360), "morphing blob?")
    if GuiManager:addButton(Vector2d(472, 390), "yes") then
      self.mRightMorphing = true
    end
    if GuiManager:addButton(Vector2d(620, 390), "no") then
      self.mRightMorphing = false
    end

    if self.mRightMorphing then
      GuiManager:addImage(Vector2d(472 - 29, 390), "res/gfx/pfeil_rechts.bmp")
    else
      GuiManager:addImage(Vector2d(620 - 29, 390), "res/gfx/pfeil_rechts.bmp")
    end

    local color2 = { self.mR2, self.mG2, self.mB2 }
    if self.mRightMorphing then
      color2 = RenderManager:getOscillationColor()
    end
    GuiManager:addBlob(Vector2d(670, 500), color2)

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

  self.mFullscreen = GameConfig.getBoolean("fullscreen")
  self.mRenderer = GameConfig.get("device")
  self.mShowShadow  = GameConfig.getBoolean("show_shadow")
  self.mR1 = GameConfig.getNumber("left_blobby_color_r") / 255
  self.mG1 = GameConfig.getNumber("left_blobby_color_g") / 255
  self.mB1 = GameConfig.getNumber("left_blobby_color_b") / 255
  self.mLeftMorphing = GameConfig.getBoolean("left_blobby_oscillate")
  self.mR2 = GameConfig.getNumber("right_blobby_color_r") / 255
  self.mG2 = GameConfig.getNumber("right_blobby_color_g") / 255
  self.mB2 = GameConfig.getNumber("right_blobby_color_b") / 255
  self.mRightMorphing = GameConfig.getBoolean("right_blobby_oscillate")

  --
  app.initConfig()
end

function GraphicOptionsMenuState:save()
  GameConfig.set("fullscreen", self.mFullscreen)
  GameConfig.set("device", self.mRenderer)
  GameConfig.set("show_shadow", self.mShowShadow)
  GameConfig.set("left_blobby_color_r", self.mR1 * 255)
  GameConfig.set("left_blobby_color_g", self.mG1 * 255)
  GameConfig.set("left_blobby_color_b", self.mB1 * 255)
  GameConfig.set("left_blobby_oscillate", self.mLeftMorphing)
  GameConfig.set("right_blobby_color_r", self.mR2 * 255)
  GameConfig.set("right_blobby_color_g", self.mG2 * 255)
  GameConfig.set("right_blobby_color_b", self.mB2 * 255)
  GameConfig.set("right_blobby_oscillate", self.mRightMorphing)

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
