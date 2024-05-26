local OptionsMenuState = {}
OptionsMenuState.__index = OptionsMenuState

setmetatable(OptionsMenuState, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

function OptionsMenuState:__construct()
  love.mouse.setVisible(true)

  GameConfig.load("conf/" .. app.options.config)

  local scriptNameLeft = GameConfig.get("left_script_name")
  local scriptNameRight = GameConfig.get("right_script_name")

  self.scriptNames = { "human", "axji-0-2", "com_11", "gintonicV9", "hyp014", "reduced", "Union" }

  self.playerOptions = {
    [LEFT_PLAYER] = 1,
    [RIGHT_PLAYER] = 1,
  }

  for i, name in ipairs(self.scriptNames) do
    if name == scriptNameLeft then
      self.playerOptions[LEFT_PLAYER] = i
    end
    if name == scriptNameRight then
      self.playerOptions[RIGHT_PLAYER] = i
    end
  end

  if GameConfig.getBoolean("left_player_human") then
    self.playerOptions[LEFT_PLAYER] = 1
  end

  if GameConfig.getBoolean("right_player_human") then
    self.playerOptions[RIGHT_PLAYER] = 1
  end

  self.playerName = {
    [LEFT_PLAYER] = GameConfig.get("left_player_name"),
    [RIGHT_PLAYER] = GameConfig.get("right_player_name"),
  }

  self.playerPosition = {
    [LEFT_PLAYER] = 0,
    [RIGHT_PLAYER] = 0,
  }

  self.botStrength = {
    [LEFT_PLAYER] = GameConfig.getNumber("left_script_strength"),
    [RIGHT_PLAYER] = GameConfig.getNumber("right_script_strength"),
  }
end

function OptionsMenuState:update(dt)
  GuiManager:addImage(Vector2d(0, 0), "res/gfx/backgrounds/strand2.bmp")
  GuiManager:addOverlay(Vector2d(0, 0), Vector2d(800, 600))

  GuiManager:addEditbox(Vector2d(5, 10), 15, self.playerName[LEFT_PLAYER], self.playerPosition[LEFT_PLAYER])
  GuiManager:addEditbox(Vector2d(425, 10), 15, self.playerName[RIGHT_PLAYER], self.playerPosition[RIGHT_PLAYER])

  GuiManager:addSelectbox(Vector2d(5, 50), Vector2d(375, 300), self.scriptNames, self.playerOptions[LEFT_PLAYER])
  GuiManager:addSelectbox(Vector2d(425, 50), Vector2d(795, 300), self.scriptNames, self.playerOptions[RIGHT_PLAYER])

  GuiManager:addText(Vector2d(400, 310), "bot strength", TF_ALIGN_CENTER)

  local f = 1 - self.botStrength[LEFT_PLAYER] / MAX_BOT_DELAY
  GuiManager:addScrollbar(Vector2d(15, 350), f)
  -- mBotStrength[0] = static_cast<unsigned int> ((1.f-f) * MAX_BOT_DELAY + 0.5f);
  local botStrengthLeftText = self:__getBotStrengthText(f)
  GuiManager:addText(Vector2d(235, 350), botStrengthLeftText)

  local f = 1 - self.botStrength[RIGHT_PLAYER] / MAX_BOT_DELAY
  GuiManager:addScrollbar(Vector2d(440, 350), f)
  -- mBotStrength[1] = static_cast<unsigned int> ((1.f - f) * MAX_BOT_DELAY + 0.5f);
  local botStrengthRightText = self:__getBotStrengthText(f)
  GuiManager:addText(Vector2d(660, 350), botStrengthRightText)

  -- if GuiManager:addButton(Vector2d(40, 390), "input options") then
  --   self:save()
  --   app.state:switchState(InputOptionsState())
  -- end

  -- if GuiManager:addButton(Vector2d(40, 430), "graphic options") then
  --   self:save()
  --   app.state:switchState(GraphicOptionsState())
  -- end

  -- if GuiManager:addButton(Vector2d(40, 470), "misc options") then
  --   self:save()
  --   app.state:switchState(MiscOptionsState())
  -- end

  if GuiManager:addButton(Vector2d(224, 530), "ok") then
    self:save()
    app.state:switchState(MainMenuState())
  end

  if GuiManager:addButton(Vector2d(424, 530), "cancel") then
    app.state:switchState(MainMenuState())
  end
end

function OptionsMenuState:save()
  print("saving options")
end

function OptionsMenuState:draw()
  GuiManager:draw()
end

-- KeyConstant key
function OptionsMenuState:keypressed(key)
end

-- KeyConstant key
function OptionsMenuState:keyreleased(key)
end

function OptionsMenuState:getStateName()
  return "OptionsMenuState"
end

-- number f
function OptionsMenuState:__getBotStrengthText(f)
  if f > 0.66 then
    return "strong"
  elseif f > 0.33 then
    return "medium"
  else
    return "weak"
  end
end

return OptionsMenuState
