local GameState = {}
GameState.__index = GameState

setmetatable(GameState, {
  __index = State, -- base class
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

-- table<DuelMatch> match
function GameState:__construct(match)
  State.__construct(self)
  self.match = match
end

-- helper function that draws the game
function GameState:presentGame()
  RenderManager:setBlob(LEFT_PLAYER, self.match:getBlobPosition(LEFT_PLAYER), self.match:getBlobState(LEFT_PLAYER))
  RenderManager:setBlob(RIGHT_PLAYER, self.match:getBlobPosition(RIGHT_PLAYER), self.match:getBlobState(RIGHT_PLAYER))

  if self.match:getPlayer(LEFT_PLAYER).isOscillating then
    RenderManager:setBlobColor(LEFT_PLAYER, RenderManager:getOscillationColor())
  else
    RenderManager:setBlobColor(LEFT_PLAYER, self.match:getPlayer(LEFT_PLAYER).staticColor)
  end

  if self.match:getPlayer(RIGHT_PLAYER).isOscillating then
    RenderManager:setBlobColor(RIGHT_PLAYER, RenderManager:getOscillationColor())
  else
    RenderManager:setBlobColor(RIGHT_PLAYER, self.match:getPlayer(RIGHT_PLAYER).staticColor)
  end

  RenderManager:setBall(self.match:getBallPosition(), self.match:getBallRotation())

  -- events = self.match:getEvents()
  -- for i, e in ipairs(events) do
  --   if e.event == MatchEvent.BALL_HIT_BLOB then
  --     SoundManager.playSound("sounds/bums.wav", e.intensity + BALL_HIT_PLAYER_SOUND_VOLUME)
  --   end
  --
  --   if e.event == MatchEvent.PLAYER_ERROR then
  --     SoundManager.playSound("sounds/pfiff.wav", ROUND_START_SOUND_VOLUME)
  --   end
  -- end
end

-- helper function that draws the ui in the game, i.e. clock, score and player names
function GameState:presentGameUI()
  -- @todo
end

function GameState:step_impl()
  -- @todo
end

function GameState:getStateName()
  return "GameState"
end

return GameState
