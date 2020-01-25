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

  for i, e in ipairs(self.match.events) do
    if e.type == MatchEvent.BALL_HIT_BLOB then
      SoundManager.playSound("res/sfx/bums.wav", e.intensity + BALL_HIT_PLAYER_SOUND_VOLUME)
    end

    if e.type == MatchEvent.PLAYER_ERROR or e.type == MatchEvent.ROUND_START then
      SoundManager.playSound("res/sfx/pfiff.wav", ROUND_START_SOUND_VOLUME)
    end
  end
end

-- helper function that draws the ui in the game, i.e. clock, score and player names
function GameState:presentGameUi()
  RenderManager:updateUi(function()
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(RenderManager.uiFont)

    -- Scores
    local text = string.format(self.match:getServingPlayer() == LEFT_PLAYER and "%02d!" or "%02d ", self.match:getScore(LEFT_PLAYER))
    love.graphics.printf(text, 24, 24, text:len() * FONT_WIDTH_NORMAL, "left")

    local text = string.format(self.match:getServingPlayer() == RIGHT_PLAYER and "%02d!" or "%02d ", self.match:getScore(RIGHT_PLAYER))
    love.graphics.printf(text, 800 - 24 - text:len() * FONT_WIDTH_NORMAL, 24, text:len() * FONT_WIDTH_NORMAL, "right")

    -- Blob names
    local text = self.match:getPlayer(LEFT_PLAYER).name
    love.graphics.printf(text:upper(), 12, 550, text:len() * FONT_WIDTH_NORMAL, "left")

    local text = self.match:getPlayer(RIGHT_PLAYER).name
    love.graphics.printf(text:upper(), 800 - 12 - text:len() * FONT_WIDTH_NORMAL, 550, text:len() * FONT_WIDTH_NORMAL, "right")

    -- Game clock
    local text = GameClock:getTimeString()
    love.graphics.printf(text, 400 - text:len() * FONT_WIDTH_NORMAL / 2, 24, text:len() * FONT_WIDTH_NORMAL, "center")
  end)
end

function GameState:step_impl()
end

function GameState:getStateName()
  return "GameState"
end

return GameState
