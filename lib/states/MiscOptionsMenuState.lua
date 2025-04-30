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

  self.backgrounds = { "strand1.bmp", "strand2.bmp" }
  self.rules = { "back_defence", "blitz", "classic", "default", "firewall", "headless", "jumping_jack", "one_hit_wonder", "sticky_mode", "tennis", "the_double" }

  self:load()
end

function MiscOptionsMenuState:update(dt)
  GuiManager:addImage(Vector2d(0, 0), "res/gfx/backgrounds/" .. self.backgrounds[self.mBackground])
  GuiManager:addOverlay(Vector2d(0, 0), Vector2d(800, 600))

  GuiManager:addText(Vector2d(34, 10), "background:")
  self.mBackground = GuiManager:addSelectbox(Vector2d(34, 40), Vector2d(400, 175), self.backgrounds, self.mBackground)

  GuiManager:addText(Vector2d(34, 190), "rules:")
  self.mRule = GuiManager:addSelectbox(Vector2d(34, 220), Vector2d(400, 354), self.rules, self.mRule)

  GuiManager:addText(Vector2d(484, 10), "volume:")
  self.mVolume = GuiManager:addScrollbar(Vector2d(484, 50), self.mVolume)
  -- @todo persist/undo on save/cancel
  --   SoundManager::getSingleton().setVolume(mVolume);
  --   SoundManager::getSingleton().playSound("sounds/bums.wav", 1.0);

  --
  if GuiManager:addButton(Vector2d(531, 80), "mute") then
    self.mMute = not self.mMute
    -- @todo persist/undo on save/cancel
    -- SoundManager.isMuted = self.mMute
    if not self.mMute then
      SoundManager:playSound("res/sfx/bums.wav", 1.0)
    end
  end

  if self.mMute then
    GuiManager:addImage(Vector2d(531 - 29, 80), "res/gfx/pfeil_rechts.bmp")
  end

  --
  if GuiManager:addButton(Vector2d(484, 120), "show fps") then
    self.mShowFPS = not self.mShowFPS
    -- @todo persist/undo on save/cancel
    -- RenderManager.uiElements.showfps = self.mShowFPS
  end

  if self.mShowFPS then
    GuiManager:addImage(Vector2d(484 - 29, 120), "res/gfx/pfeil_rechts.bmp")
  end

  --
  if GuiManager:addButton(Vector2d(484, 160), "show blood") then
    self.mShowBlood = not self.mShowBlood
    -- @todo persist/undo on save/cancel
    --   BloodManager::getSingleton().enable(mShowBlood);
    --   BloodManager::getSingleton().spillBlood(Vector2(484.0, 160.0), 1.5, 2);
  end

  if self.mShowBlood then
    GuiManager:addImage(Vector2d(484 - 29, 160), "res/gfx/pfeil_rechts.bmp")
  end

  --
  GuiManager:addText(Vector2d(434, 200), "network side:")
  if GuiManager:addButton(Vector2d(450, 240), "left") then
    self.mNetworkSide = 0
  end
  if GuiManager:addButton(Vector2d(630, 240), "right") then
    self.mNetworkSide = 1
  end

  if self.mNetworkSide == 0 then
    GuiManager:addImage(Vector2d(450 - 29, 240), "res/gfx/pfeil_rechts.bmp")
  end
  if self.mNetworkSide == 1 then
    GuiManager:addImage(Vector2d(630 - 29, 240), "res/gfx/pfeil_rechts.bmp")
  end

  --
  local f = (self.mGameFPS - 30) / 90
  GuiManager:addText(Vector2d(484, 290), "gamespeed:")
  f = GuiManager:addScrollbar(Vector2d(440, 330), f)
  self.mGameFPS = math.floor(f * 90 + 30)

  -- float gamefps = (mGameFPS - 30) / 90.0;
  -- if (gamefps < 0.0)
  --   gamefps = 0.0;
  -- imgui.doScrollbar(GEN_ID, Vector2(440.0, 330.0), gamefps);
  --   mGameFPS = (int)(gamefps*90.0+30);
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

  local gameFPSText = math.floor(self.mGameFPS / 75 * 100) .. "%"
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

  for i, name in ipairs(self.backgrounds) do
    if name == GameConfig.get("background") then
      self.mBackground = i
    end
  end

  for i, name in ipairs(self.rules) do
    if name .. ".lua" == GameConfig.get("rules") then
      self.mRule = i
    end
  end

  self.mShowFPS = GameConfig.getBoolean("showfps")
  self.mShowBlood = GameConfig.getBoolean("blood")
  self.mVolume = GameConfig.getNumber("global_volume")
  self.mMute = GameConfig.getBoolean("mute")
  self.mGameFPS = GameConfig.getNumber("gamefps")
  self.mNetworkSide = GameConfig.getNumber("network_side")
  self.mLanguage = GameConfig.get("language")

  --
  app.initConfig()
end

function MiscOptionsMenuState:save()
  GameConfig.set("background", self.backgrounds[self.mBackground])
  GameConfig.set("rules", self.rules[self.mRule] .. ".lua")

  GameConfig.set("showfps", self.mShowFPS)
  GameConfig.set("blood", self.mShowBlood)
  GameConfig.set("global_volume", self.mVolume)
  GameConfig.set("mute", self.mMute)
  GameConfig.set("gamefps", self.mGameFPS)
  GameConfig.set("network_side", self.mNetworkSide)
  GameConfig.set("language", self.mLanguage)

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
