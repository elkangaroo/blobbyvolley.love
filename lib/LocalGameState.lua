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
  local leftPlayer = PlayerIdentity.createFromConfig(LEFT_PLAYER, false)
  local rightPlayer = PlayerIdentity.createFromConfig(RIGHT_PLAYER, false)

  local match = Match(false, GameConfig.get("rules"))
  match:setPlayers(leftPlayer, rightPlayer)
  match:addEvent(MatchEvent.ROUND_START, NO_PLAYER)

  GameState.__construct(self, match)
  self.winner = false
end

function LocalGameState:update_impl()
  if self.match.isPaused then
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
    --   if self.match.isPaused then
    --     self:switchState(MainMenuState())
    --   else
    --     RenderManager:redraw()
    --     self.match:pause()
    --  end
  else
    self.match:update()

    if self.match:getWinningPlayer() ~= NO_PLAYER then
      self.winner = true
    end

    self:presentGame()
  end

  self:presentGameUi()
  self.match:resetEvents()
end

-- KeyConstant key
function LocalGameState:keypressed(key)
  if ("a" == key) then self.match.playerInputs[LEFT_PLAYER].left = true end
  if ("d" == key) then self.match.playerInputs[LEFT_PLAYER].right = true end
  if ("w" == key) then self.match.playerInputs[LEFT_PLAYER].up = true end

  if ("left" == key) then self.match.playerInputs[RIGHT_PLAYER].left = true end
  if ("right" == key) then self.match.playerInputs[RIGHT_PLAYER].right = true end
  if ("up" == key) then self.match.playerInputs[RIGHT_PLAYER].up = true end

  if "p" == key or "pause" == key then
    if self.match.isPaused then
      self.match:unpause()
    else
      self.match:pause()
    end
  end
end

-- KeyConstant key
function LocalGameState:keyreleased(key)
  if ("a" == key) then self.match.playerInputs[LEFT_PLAYER].left = false end
  if ("d" == key) then self.match.playerInputs[LEFT_PLAYER].right = false end
  if ("w" == key) then self.match.playerInputs[LEFT_PLAYER].up = false end

  if ("left" == key) then self.match.playerInputs[RIGHT_PLAYER].left = false end
  if ("right" == key) then self.match.playerInputs[RIGHT_PLAYER].right = false end
  if ("up" == key) then self.match.playerInputs[RIGHT_PLAYER].up = false end
end

function LocalGameState:getStateName()
  return "LocalGameState"
end

return LocalGameState
