local MatchState = {}
MatchState.__index = MatchState

setmetatable(MatchState, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

-- Match match
function MatchState:__construct(match)
  self._ballPosition = match:getBallPosition():clone()
  self._ballVelocity = match:getBallVelocity():clone()
  self._ballRotation = match:getBallRotation()

  self._blobState = {
    [LEFT_PLAYER] = match:getBlobState(LEFT_PLAYER),
    [RIGHT_PLAYER] = match:getBlobState(RIGHT_PLAYER),
  }
  self._blobPosition = {
    [LEFT_PLAYER] = match:getBlobPosition(LEFT_PLAYER):clone(),
    [RIGHT_PLAYER] = match:getBlobPosition(RIGHT_PLAYER):clone(),
  }
  self._blobVelocity = {
    [LEFT_PLAYER] = match:getBlobVelocity(LEFT_PLAYER):clone(),
    [RIGHT_PLAYER] = match:getBlobVelocity(RIGHT_PLAYER):clone(),
  }

  self._servingPlayer = match:getServingPlayer()
  self._winningPlayer = match:getWinningPlayer()
  self._isBallValid = match:isBallValid()
  self._isGameRunning = match:isGameRunning()

  self._scores = {
    [LEFT_PLAYER] = match:getScore(LEFT_PLAYER),
    [RIGHT_PLAYER] = match:getScore(RIGHT_PLAYER),
  }
  self._touches = {
    [LEFT_PLAYER] = match:getTouches(LEFT_PLAYER),
    [RIGHT_PLAYER] = match:getTouches(RIGHT_PLAYER),
  }
end

function MatchState:swapSides()
  self._ballPosition.x = RIGHT_PLANE - self._ballPosition.x
  self._ballVelocity.x = -self._ballVelocity.x
  self._ballRotation = (2 * math.pi) - self._ballRotation

  self._blobState[LEFT_PLAYER], self._blobState[RIGHT_PLAYER] = self._blobState[RIGHT_PLAYER], self._blobState[LEFT_PLAYER]

  self._blobPosition[LEFT_PLAYER].x = RIGHT_PLANE - self._blobPosition[LEFT_PLAYER].x
  self._blobPosition[RIGHT_PLAYER].x = RIGHT_PLANE - self._blobPosition[RIGHT_PLAYER].x
  self._blobPosition[LEFT_PLAYER], self._blobPosition[RIGHT_PLAYER] = self._blobPosition[RIGHT_PLAYER], self._blobPosition[LEFT_PLAYER]

  self._blobVelocity[LEFT_PLAYER].x = -self._blobVelocity[LEFT_PLAYER].x
  self._blobVelocity[RIGHT_PLAYER].x = -self._blobVelocity[RIGHT_PLAYER].x
  self._blobVelocity[LEFT_PLAYER], self._blobVelocity[RIGHT_PLAYER] = self._blobVelocity[RIGHT_PLAYER], self._blobVelocity[LEFT_PLAYER]

  if self._servingPlayer == LEFT_PLAYER then
    self._servingPlayer = RIGHT_PLAYER
  elseif self._servingPlayer == RIGHT_PLAYER then
    self._servingPlayer = LEFT_PLAYER
  end

  self._scores[LEFT_PLAYER], self._scores[RIGHT_PLAYER] = self._scores[RIGHT_PLAYER], self._scores[LEFT_PLAYER]
  self._touches[LEFT_PLAYER], self._touches[RIGHT_PLAYER] = self._touches[RIGHT_PLAYER], self._touches[LEFT_PLAYER]
end

-- PlayerSide side
function MatchState:getBlobState(side)
  return self._blobState[side]
end

-- PlayerSide side
function MatchState:getBlobPosition(side)
  return self._blobPosition[side]
end

-- PlayerSide side
function MatchState:getBlobVelocity(side)
  return self._blobVelocity[side]
end

function MatchState:getBallPosition()
  return self._ballPosition
end

function MatchState:getBallVelocity()
  return self._ballVelocity
end

function MatchState:getBallRotation()
  return self._ballRotation
end

function MatchState:getServingPlayer()
  return self._servingPlayer
end

function MatchState:getWinningPlayer()
  return self._winningPlayer
end

function MatchState:isBallValid()
  return self._isBallValid
end

function MatchState:isGameRunning()
  return self._isGameRunning
end

-- PlayerSide side
function MatchState:getTouches(side)
  return self._touches[side]
end

-- PlayerSide side
function MatchState:getScore(side)
  return self._scores[side]
end

return MatchState
