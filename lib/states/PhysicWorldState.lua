local PhysicWorldState = {}
PhysicWorldState.__index = PhysicWorldState

setmetatable(PhysicWorldState, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

-- Vector2d ballPosition, Vector2d ballVelocity, number ballRotation, table<PlayerSide, number> blobState, table<PlayerSide, Vector2d> blobPosition, table<PlayerSide, Vector2d> blobVelocity
function PhysicWorldState:__construct(ballPosition, ballVelocity, ballRotation, blobState, blobPosition, blobVelocity)
  self.ballPosition = ballPosition
  self.ballVelocity = ballVelocity
  self.ballRotation = ballRotation

  self.blobState = blobState
  self.blobPosition = blobPosition
  self.blobVelocity = blobVelocity
end

function PhysicWorldState:swapSides()
  self.ballPosition.x = RIGHT_PLANE - self.ballPosition.x
  self.ballVelocity.x = -self.ballVelocity.x
  self.ballRotation = (2 * math.pi) - self.ballRotation

  self.blobState[LEFT_PLAYER], self.blobState[RIGHT_PLAYER] = self.blobState[RIGHT_PLAYER], self.blobState[LEFT_PLAYER]

  self.blobPosition[LEFT_PLAYER].x = RIGHT_PLANE - self.blobPosition[LEFT_PLAYER].x
  self.blobPosition[RIGHT_PLAYER].x = RIGHT_PLANE - self.blobPosition[RIGHT_PLAYER].x
  self.blobPosition[LEFT_PLAYER], self.blobPosition[RIGHT_PLAYER] = self.blobPosition[RIGHT_PLAYER], self.blobPosition[LEFT_PLAYER]

  self.blobVelocity[LEFT_PLAYER].x = -self.blobVelocity[LEFT_PLAYER].x
  self.blobVelocity[RIGHT_PLAYER].x = -self.blobVelocity[RIGHT_PLAYER].x
  self.blobVelocity[LEFT_PLAYER], self.blobVelocity[RIGHT_PLAYER] = self.blobVelocity[RIGHT_PLAYER], self.blobVelocity[LEFT_PLAYER]
end

return PhysicWorldState
