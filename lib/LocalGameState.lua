local LocalGameState = {}
LocalGameState.__index = LocalGameState

setmetatable(LocalGameState, {
  __index = GameState, -- base class
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

function LocalGameState:__construct()
  leftPlayer = PlayerIdentity.createFromConfig(LEFT_PLAYER, false)
  rightPlayer = PlayerIdentity.createFromConfig(RIGHT_PLAYER, false)

  SoundManager.playSound("res/sfx/pfiff.wav", ROUND_START_SOUND_VOLUME)

  match = DuelMatch(false, GameConfig.get("rules"))
  match:setPlayers(leftPlayer, rightPlayer)

  GameState.__construct(self, match)
  self.winner = false
end

function LocalGameState:step_impl()
  if self.match.isPaused then
    print("match is paused")
    -- displayQueryPrompt(200,
    --   TextManager::LBL_CONF_QUIT,
    --   std::make_tuple(TextManager::LBL_YES, [&]() switchState(new MainMenuState) ),
    --   std::make_tuple(TextManager::LBL_NO,  [&]() mMatch->unpause() )
    -- )
  elseif self.winner then
    print("match has a winner")
    -- displayWinningPlayerScreen(match:getWinningPlayer())
    -- if imgui.doButton(GEN_ID, Vector2(310, 340), TextManager::LBL_OK) then
    --   self:switchState(MainMenuState())
    -- end
    --
    -- if imgui.doButton(GEN_ID, Vector2(420, 340), TextManager::GAME_TRY_AGAIN) then
    --   self:switchState(LocalGameState())
    -- end
    -- elseif InputManager.exit() then
    --   if match:isPaused() then
    --     switchState(MainMenuState)
    --   else
    --     RenderManager:redraw()
    --     match:pause()
    --  end
  else
    match:step()

    if match:getWinningPlayer() ~= NO_PLAYER then
      winner = true
    end

    self:presentGame()
  end

  self:presentGameUi()
end

function LocalGameState:getStateName()
  return "LocalGameState"
end

return LocalGameState
