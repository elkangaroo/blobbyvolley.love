local MatchState = {}
MatchState.__index = MatchState

setmetatable(MatchState, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

-- PhysicWorldState worldState, GameLogicState logicState
function MatchState:__construct(worldState, logicState)
  self.worldState = worldState
  self.logicState = logicState
end

function MatchState:swapSides()
  self.worldState:swapSides()
  self.logicState:swapSides()
end

-- PlayerSide side
function MatchState:getBlobState(side)
  return self.worldState.blobState[side]
end

-- PlayerSide side
function MatchState:getBlobPosition(side)
  return self.worldState.blobPosition[side]
end

-- PlayerSide side
function MatchState:getBlobVelocity(side)
  return self.worldState.blobVelocity[side]
end

function MatchState:getBallPosition()
  return self.worldState.ballPosition
end

function MatchState:getBallVelocity()
  return self.worldState.ballVelocity
end

function MatchState:getBallRotation()
  return self.worldState.ballRotation
end

function MatchState:getServingPlayer()
  return self.logicState.servingPlayer
end

function MatchState:getWinningPlayer()
  return self.logicState.winningPlayer
end

function MatchState:isBallValid()
  return self.logicState.isBallValid
end

function MatchState:isGameRunning()
  return self.logicState.isGameRunning
end

-- PlayerSide side
function MatchState:getTouches(side)
  return self.logicState.touches[side]
end

-- PlayerSide side
function MatchState:getScore(side)
  return self.logicState.scores[side]
end

return MatchState
