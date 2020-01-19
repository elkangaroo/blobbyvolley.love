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
  -- rmanager = RenderManager.getSingleton()
  -- smanager = SoundManager.getSingleton()
  --
  -- rmanager.drawGame(true)
  -- rmanager.setBlob(LEFT_PLAYER, self.match:getBlobPosition(LEFT_PLAYER), self.match:getWorld().getBlobState(LEFT_PLAYER))
  -- rmanager.setBlob(RIGHT_PLAYER, self.match:getBlobPosition(RIGHT_PLAYER),  self.match:getWorld().getBlobState(RIGHT_PLAYER))
  --
  -- if self.match:getPlayer(LEFT_PLAYER).getOscillating() then
  --   rmanager.setBlobColor(LEFT_PLAYER, rmanager.getOscillationColor())
  -- else
  --   rmanager.setBlobColor(LEFT_PLAYER, self.match:getPlayer(LEFT_PLAYER).getStaticColor())
  -- end
  --
  -- if self.match:getPlayer(RIGHT_PLAYER).getOscillating() then
  --   rmanager.setBlobColor(RIGHT_PLAYER, rmanager.getOscillationColor())
  -- else
  --   rmanager.setBlobColor(RIGHT_PLAYER, self.match:getPlayer(RIGHT_PLAYER).getStaticColor())
  -- end
  --
  -- rmanager.setBall(self.match:getBallPosition(), self.match:getWorld().getBallRotation())
  --
  -- events = self.match:getEvents()
  -- for i, e in ipairs(events) do
  --   if e.event == MatchEvent.BALL_HIT_BLOB then
  --     smanager.playSound("sounds/bums.wav", e.intensity + BALL_HIT_PLAYER_SOUND_VOLUME)
  --     hitPos = self.match:getBallPosition() + (self.match:getBlobPosition(e.side) - self.match:getBallPosition()).normalise().scale(31.5)
  --   end
  --
  --   if e.event == MatchEvent.PLAYER_ERROR then
  --     smanager.playSound("sounds/pfiff.wav", ROUND_START_SOUND_VOLUME)
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
