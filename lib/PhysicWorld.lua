local PhysicWorld = {}
PhysicWorld.__index = PhysicWorld

setmetatable(PhysicWorld, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

function PhysicWorld:__construct()
  self.ballPosition = { x = 200, y = STANDARD_BALL_HEIGHT }
  self.ballVelocity = { x = 0, y = 0 }
  self.ballRotation = 0
  self.ballAngularVelocity = STANDARD_BALL_ANGULAR_VELOCITY
  self.lastHitIntensity = 0
  self.mCallback = {}

  self.currentBlobbyAnimationSpeed = {
    [LEFT_PLAYER] = 0.0,
    [RIGHT_PLAYER] = 0.0,
  }

  self.blobState = {
    [LEFT_PLAYER] = 0.0,
    [RIGHT_PLAYER] = 0.0,
  }

  self.blobPosition = {
    [LEFT_PLAYER] = { x = 200, y = GROUND_PLANE_HEIGHT },
    [RIGHT_PLAYER] = { x = 600, y = GROUND_PLANE_HEIGHT },
  }
end

-- PlayerSide player
function PhysicWorld:getBlobPosition(player)
  return self.blobPosition[player]
end

-- PlayerSide player
function PhysicWorld:getBlobState(player)
  return self.blobState[player]
end

return PhysicWorld
