local MiscOptionsMenuState = {}
MiscOptionsMenuState.__index = MiscOptionsMenuState

setmetatable(MiscOptionsMenuState, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

function MiscOptionsMenuState:__construct()
  love.mouse.setVisible(true)

  self.BACKGROUND_NAMES = { "strand1.bmp", "strand2.bmp" }
  self.RULE_NAMES = { "back_defence", "blitz", "classic", "default", "firewall", "headless", "jumping_jack", "one_hit_wonder", "sticky_mode", "tennis", "the_double" }

  self:load()
end

function MiscOptionsMenuState:update(dt)
  GuiManager:addImage(Vector2d(0, 0), "res/gfx/backgrounds/" .. self.BACKGROUND_NAMES[self.background])
  GuiManager:addOverlay(Vector2d(0, 0), Vector2d(800, 600))

  GuiManager:addText(Vector2d(34, 10), "background:")
  self.background = GuiManager:addSelectbox(Vector2d(34, 40), Vector2d(400, 175), self.BACKGROUND_NAMES, self.background)

  GuiManager:addText(Vector2d(34, 190), "rules:")
  self.rule = GuiManager:addSelectbox(Vector2d(34, 220), Vector2d(400, 354), self.RULE_NAMES, self.rule)

  GuiManager:addText(Vector2d(484, 10), "volume:")
  self.volume = GuiManager:addScrollbar(Vector2d(484, 50), self.volume)

  --
  if GuiManager:addButton(Vector2d(531, 80), "mute") then
    self.isMuted = not self.isMuted
  end
  if self.isMuted then
    GuiManager:addImage(Vector2d(531 - 29, 80), "res/gfx/pfeil_rechts.bmp")
  end

  --
  if GuiManager:addButton(Vector2d(484, 120), "show fps") then
    self.showFPS = not self.showFPS
  end
  if self.showFPS then
    GuiManager:addImage(Vector2d(484 - 29, 120), "res/gfx/pfeil_rechts.bmp")
  end

  --
  if GuiManager:addButton(Vector2d(484, 160), "show blood") then
    self.showBlood = not self.showBlood
  end
  if self.showBlood then
    GuiManager:addImage(Vector2d(484 - 29, 160), "res/gfx/pfeil_rechts.bmp")
  end

  --
  GuiManager:addText(Vector2d(434, 200), "network side:")
  if GuiManager:addButton(Vector2d(450, 240), "left") then
    self.networkSide = 0
  end
  if GuiManager:addButton(Vector2d(630, 240), "right") then
    self.networkSide = 1
  end

  if self.networkSide == 0 then
    GuiManager:addImage(Vector2d(450 - 29, 240), "res/gfx/pfeil_rechts.bmp")
  else
    GuiManager:addImage(Vector2d(630 - 29, 240), "res/gfx/pfeil_rechts.bmp")
  end

  --
  local f = (self.gameFPS - 30) / 90
  GuiManager:addText(Vector2d(484, 290), "gamespeed:")
  f = GuiManager:addScrollbar(Vector2d(440, 330), f)
  self.gameFPS = math.floor(f * 90 + 30)

  -- if (imgui.doButton(GEN_ID, Vector2(155.0, 380.0), TextManager::OP_VSLOW))
  --   mGameFPS = 30;
  -- if (imgui.doButton(GEN_ID, Vector2(450.0, 380.0), TextManager::OP_SLOW))
  --   mGameFPS = 60;
  -- if (imgui.doButton(GEN_ID, Vector2(319.0, 415.0), TextManager::OP_DEFAULT))
  --   mGameFPS = 75;
  -- if (imgui.doButton(GEN_ID, Vector2(155.0, 450.0), TextManager::OP_FAST))
  --   mGameFPS = 90;
  -- if (imgui.doButton(GEN_ID, Vector2(410.0, 450.0), TextManager::OP_VFAST))
  --   mGameFPS = 120;

  local gameFPSText = math.floor(self.gameFPS / 75 * 100) .. "%"
  GuiManager:addText(Vector2d(660, 330), gameFPSText)

  -- //! \todo this must be reworked
  -- std::map<std::string, std::string>::iterator olang = TextManager::language_names.find(TextManager::getSingleton()->getLang());
  -- if(++olang == TextManager::language_names.end()){
  --   olang = TextManager::language_names.begin();
  -- }
  -- if (imgui.doButton(GEN_ID, Vector2(300.0, 490.0), (*olang).second)){
  --   //! \todo autogenerierte liste mit allen lang_ dateien, namen auslesen
  --   mLanguage = (*olang).first;
  --   TextManager::switchLanguage(mLanguage);
  -- }

  if GuiManager:addButton(Vector2d(224, 530), "ok") then
    self:save()
    app.state:switchState(OptionsMenuState())
  end

  if GuiManager:addButton(Vector2d(424, 530), "cancel") then
    self:load()
    app.state:switchState(OptionsMenuState())
  end
end

function MiscOptionsMenuState:load()
  GameConfig.load()

  for i, name in ipairs(self.BACKGROUND_NAMES) do
    if name == GameConfig.get("background") then
      self.background = i
    end
  end

  for i, name in ipairs(self.RULE_NAMES) do
    if name .. ".lua" == GameConfig.get("rules") then
      self.rule = i
    end
  end

  self.showFPS = GameConfig.getBoolean("showfps")
  self.showBlood = GameConfig.getBoolean("blood")
  self.volume = GameConfig.getNumber("global_volume")
  self.isMuted = GameConfig.getBoolean("mute")
  self.gameFPS = GameConfig.getNumber("gamefps")
  self.networkSide = GameConfig.getNumber("network_side")
  self.language = GameConfig.get("language")

  --
  app.initConfig()
end

function MiscOptionsMenuState:save()
  GameConfig.set("background", self.BACKGROUND_NAMES[self.background])
  GameConfig.set("rules", self.RULE_NAMES[self.rule] .. ".lua")

  GameConfig.set("showfps", self.showFPS)
  GameConfig.set("blood", self.showBlood)
  GameConfig.set("global_volume", self.volume)
  GameConfig.set("mute", self.isMuted)
  GameConfig.set("gamefps", self.gameFPS)
  GameConfig.set("network_side", self.networkSide)
  GameConfig.set("language", self.language)

  GameConfig.save()

  --
  app.initConfig()
end

function MiscOptionsMenuState:draw()
  GuiManager:draw()
end

-- KeyConstant key
function MiscOptionsMenuState:keypressed(key)
end

-- KeyConstant key
function MiscOptionsMenuState:keyreleased(key)
end

-- String text
function MiscOptionsMenuState:textinput(text)
end

function MiscOptionsMenuState:getStateName()
  return "MiscOptionsMenuState"
end

return MiscOptionsMenuState
