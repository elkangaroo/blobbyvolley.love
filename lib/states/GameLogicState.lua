local GameLogicState = {}
GameLogicState.__index = GameLogicState

setmetatable(GameLogicState, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

-- PlayerSide servingPlayer, PlayerSide winningPlayer, boolean isBallValid, boolean isGameRunning, table<PlayerSide, number> scores, table<PlayerSide, number> touches
function GameLogicState:__construct(servingPlayer, winningPlayer, isBallValid, isGameRunning, scores, touches)
  self.servingPlayer = servingPlayer
  self.winningPlayer = winningPlayer
  self.isBallValid = isBallValid
  self.isGameRunning = isGameRunning

  self.scores = scores
  self.touches = touches
end

function GameLogicState:swapSides()
  if self.servingPlayer == LEFT_PLAYER then
    self.servingPlayer = RIGHT_PLAYER
  elseif self.servingPlayer == RIGHT_PLAYER then
    self.servingPlayer = LEFT_PLAYER
  end

  self.scores[LEFT_PLAYER], self.scores[RIGHT_PLAYER] = self.scores[RIGHT_PLAYER], self.scores[LEFT_PLAYER]
  self.touches[LEFT_PLAYER], self.touches[RIGHT_PLAYER] = self.touches[RIGHT_PLAYER], self.touches[LEFT_PLAYER]
end

return GameLogicState
