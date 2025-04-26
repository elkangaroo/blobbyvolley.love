local utf8 = require("lib.utf8")

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

  self.scriptNames = { "human", "axji-0-2", "com_11", "gintonicV9", "hyp014", "reduced", "Union" }

  self.playerSelection = {
    [LEFT_PLAYER] = 1,
    [RIGHT_PLAYER] = 1,
  }

  self.playerName = {
    [LEFT_PLAYER] = "",
    [RIGHT_PLAYER] = "",
  }

  self.playerNameActive = {
    [LEFT_PLAYER] = false,
    [RIGHT_PLAYER] = false,
  }

  self.botStrength = {
    [LEFT_PLAYER] = 1,
    [RIGHT_PLAYER] = 1,
  }

  self:load()
end

function OptionsMenuState:update(dt)
  GuiManager:addImage(Vector2d(0, 0), "res/gfx/backgrounds/strand2.bmp")
  GuiManager:addOverlay(Vector2d(0, 0), Vector2d(800, 600))

  self.playerNameActive[LEFT_PLAYER] = GuiManager:addEditbox(Vector2d(5, 10), 15, self.playerName[LEFT_PLAYER])
  self.playerNameActive[RIGHT_PLAYER] = GuiManager:addEditbox(Vector2d(425, 10), 15, self.playerName[RIGHT_PLAYER])

  self.playerSelection[LEFT_PLAYER] = GuiManager:addSelectbox(Vector2d(5, 50), Vector2d(375, 300), self.scriptNames, self.playerSelection[LEFT_PLAYER])
  self.playerSelection[RIGHT_PLAYER] = GuiManager:addSelectbox(Vector2d(425, 50), Vector2d(795, 300), self.scriptNames, self.playerSelection[RIGHT_PLAYER])

  GuiManager:addText(Vector2d(400, 310), "bot strength", TF_ALIGN_CENTER)

  local f = 1 - self.botStrength[LEFT_PLAYER] / MAX_BOT_DELAY
  local botStrengthLeftText = self:__getBotStrengthText(f)
  f = GuiManager:addScrollbar(Vector2d(15, 350), f)
  self.botStrength[LEFT_PLAYER] = math.floor((1 - f) * MAX_BOT_DELAY + 0.5)
  GuiManager:addText(Vector2d(235, 350), botStrengthLeftText)

  local f = 1 - self.botStrength[RIGHT_PLAYER] / MAX_BOT_DELAY
  local botStrengthRightText = self:__getBotStrengthText(f)
  f = GuiManager:addScrollbar(Vector2d(440, 350), f)
  self.botStrength[RIGHT_PLAYER] = math.floor((1 - f) * MAX_BOT_DELAY + 0.5)
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
    self:load()
    app.state:switchState(MainMenuState())
  end
end

function OptionsMenuState:load()
  GameConfig.load()

  if GameConfig.getBoolean("left_player_human") then
    self.playerSelection[LEFT_PLAYER] = 1
  else
    for i, name in ipairs(self.scriptNames) do
      if name == GameConfig.get("left_script_name") then
        self.playerSelection[LEFT_PLAYER] = i
      end
    end
  end

  if GameConfig.getBoolean("right_player_human") then
    self.playerSelection[RIGHT_PLAYER] = 1
  else
    for i, name in ipairs(self.scriptNames) do
      if name == GameConfig.get("right_script_name") then
        self.playerSelection[RIGHT_PLAYER] = i
      end
    end
  end

  self.playerName[LEFT_PLAYER] = GameConfig.get("left_player_name")
  self.playerName[RIGHT_PLAYER] = GameConfig.get("right_player_name")

  self.botStrength[LEFT_PLAYER] = GameConfig.getNumber("left_script_strength")
  self.botStrength[RIGHT_PLAYER] = GameConfig.getNumber("right_script_strength")
end

function OptionsMenuState:save()
  if self.playerSelection[LEFT_PLAYER] == 1 then
    GameConfig.set("left_player_human", "true")
  else
    GameConfig.set("left_player_human", "false")
    GameConfig.set("left_script_name", self.scriptNames[self.playerSelection[LEFT_PLAYER]])
  end

  if self.playerSelection[RIGHT_PLAYER] == 1 then
    GameConfig.set("right_player_human", "true")
  else
    GameConfig.set("right_player_human", "false")
    GameConfig.set("right_script_name", self.scriptNames[self.playerSelection[RIGHT_PLAYER]])
  end

  GameConfig.set("left_player_name", self.playerName[LEFT_PLAYER])
  GameConfig.set("right_player_name", self.playerName[RIGHT_PLAYER])

  GameConfig.set("left_script_strength", self.botStrength[LEFT_PLAYER])
  GameConfig.set("right_script_strength", self.botStrength[RIGHT_PLAYER])

  GameConfig.save()
end

function OptionsMenuState:draw()
  GuiManager:draw()
end

-- KeyConstant key
function OptionsMenuState:keypressed(key)
  if self.playerNameActive[LEFT_PLAYER] and key == "backspace" then
    -- get the byte offset to the last UTF-8 character in the string
    local byteoffset = utf8.offset(self.playerName[LEFT_PLAYER], -1)

    if byteoffset then
      -- remove the last UTF-8 character
      self.playerName[LEFT_PLAYER] = string.sub(self.playerName[LEFT_PLAYER], 1, byteoffset - 1)
    end
  end

  if self.playerNameActive[RIGHT_PLAYER] and key == "backspace" then
    -- get the byte offset to the last UTF-8 character in the string
    local byteoffset = utf8.offset(self.playerName[RIGHT_PLAYER], -1)

    if byteoffset then
      -- remove the last UTF-8 character
      self.playerName[RIGHT_PLAYER] = string.sub(self.playerName[RIGHT_PLAYER], 1, byteoffset - 1)
    end
  end
end

-- KeyConstant key
function OptionsMenuState:keyreleased(key)
end

-- String text
function OptionsMenuState:textinput(text)
  if self.playerNameActive[LEFT_PLAYER] then
    self.playerName[LEFT_PLAYER] = self.playerName[LEFT_PLAYER] .. text
  end

  if self.playerNameActive[RIGHT_PLAYER] then
    self.playerName[RIGHT_PLAYER] = self.playerName[RIGHT_PLAYER] .. text
  end
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
