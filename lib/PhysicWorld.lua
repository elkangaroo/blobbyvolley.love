-- based on https://github.com/danielknobe/blobbyvolley2/blob/v1.1.1/src/PhysicWorld.cpp
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
  self.ballPosition = Vector2d(200, STANDARD_BALL_HEIGHT)
  self.ballVelocity = Vector2d()
  self.ballRotation = 0
  self.ballAngularVelocity = STANDARD_BALL_ANGULAR_VELOCITY

  self.eventCallback = function() end

  self.blobAnimationSpeed = {
    [LEFT_PLAYER] = 0.0,
    [RIGHT_PLAYER] = 0.0,
  }

  self.blobState = {
    [LEFT_PLAYER] = 0.0,
    [RIGHT_PLAYER] = 0.0,
  }

  self.blobPosition = {
    [LEFT_PLAYER] = Vector2d(200, GROUND_PLANE_HEIGHT),
    [RIGHT_PLAYER] = Vector2d(600, GROUND_PLANE_HEIGHT),
  }

  self.blobVelocity = {
    [LEFT_PLAYER] = Vector2d(),
    [RIGHT_PLAYER] = Vector2d(),
  }
end

-- table<PlayerInput> inputs, bool isBallValid, bool isGameRunning
-- Important: This assumes a fixed framerate of 60 FPS!
function PhysicWorld:update(inputs, isBallValid, isGameRunning)
  -- Compute independent actions
  self:handleBlob(LEFT_PLAYER, inputs[LEFT_PLAYER])
  self:handleBlob(RIGHT_PLAYER, inputs[RIGHT_PLAYER])

  -- Move ball when game is running
  if isGameRunning then
    -- move ball ds = a/2 * dt^2 + v * dt where dt = 1
    self.ballPosition = self.ballPosition + Vector2d(0, 0.5 * BALL_GRAVITATION) + self.ballVelocity
    -- dv = a * dt
    self.ballVelocity.y = self.ballVelocity.y + BALL_GRAVITATION
  end

  -- Collision detection
  if isBallValid then
    self:handleBlobbyBallCollision(LEFT_PLAYER)
    self:handleBlobbyBallCollision(RIGHT_PLAYER)
  end

  self:handleBallWorldCollision()
  self:handleBlobbyWorldCollision()

  -- Velocity Integration
  if not isGameRunning then
    self.ballRotation = self.ballRotation - self.ballAngularVelocity
  elseif self.ballVelocity.x > 0.0 then
    self.ballRotation = self.ballRotation + self.ballAngularVelocity * (self.ballVelocity:length() / 6)
  else
    self.ballRotation = self.ballRotation - self.ballAngularVelocity * (self.ballVelocity:length() / 6)
  end

  -- Overflow-Protection
  if self.ballRotation <= 0 then
    self.ballRotation = 6.25 + self.ballRotation
  elseif self.ballRotation >= 6.25 then
    self.ballRotation = self.ballRotation - 6.25
  end
end

-- PlayerSide player, table<PlayerInput> input
function PhysicWorld:handleBlob(player, input)
  local currentBlobbyGravity = GRAVITATION

  if input.up then
    if self:isBlobbyOnGround(player) then
      self.blobVelocity[player].y = BLOBBY_JUMP_ACCELERATION
      self:startBlobbyAnimation(player)
    end

    currentBlobbyGravity = currentBlobbyGravity - BLOBBY_JUMP_BUFFER
  end

  if (input.left or input.right) and self:isBlobbyOnGround(player) then
    self:startBlobbyAnimation(player)
  end

  self.blobVelocity[player].x = (input.right and BLOBBY_SPEED or 0) - (input.left and BLOBBY_SPEED or 0)

  -- compute blobby fall movement (dt = 1)
  -- ds = a/2 * dt^2 + v * dt
  self.blobPosition[player] = self.blobPosition[player] + Vector2d(0, 0.5 * currentBlobbyGravity) + self.blobVelocity[player]
  -- dv = a * dt
  self.blobVelocity[player].y = self.blobVelocity[player].y + currentBlobbyGravity

  -- Hitting the ground
  if self.blobPosition[player].y > GROUND_PLANE_HEIGHT then
    if self.blobVelocity[player].y > 3.5 then
      self:startBlobbyAnimation(player)
    end

    self.blobPosition[player].y = GROUND_PLANE_HEIGHT
    self.blobVelocity[player].y = 0.0
  end

  self:handleBlobbyAnimationStep(player)
end

-- PlayerSide player
function PhysicWorld:handleBlobbyBallCollision(player)
  local collisionCenter = self.blobPosition[player]

  -- check for impact
  if self:isBlobbyBallCollisionBottom(player) then
    collisionCenter.y = collisionCenter.y + BLOBBY_LOWER_SPHERE
  elseif self:isBlobbyBallCollisionTop(player) then
    collisionCenter.y = collisionCenter.y - BLOBBY_UPPER_SPHERE
  else
    return false -- no impact
  end

  -- print("ball collided with blobby #" .. player .. " at " .. tostring(self.ballPosition))

  -- calculate hit intensity
  local intensity = math.min(1.0, (self.blobVelocity[player] - self.ballVelocity):length() / 25.0)

  -- set ball velocity
  self.ballVelocity = -(collisionCenter - self.ballPosition)
  self.ballVelocity = self.ballVelocity:normalise() * BALL_COLLISION_VELOCITY
  self.ballPosition = self.ballPosition + self.ballVelocity

  self.eventCallback(MatchEvent.BALL_HIT_BLOB, player, intensity)

  return true
end

function PhysicWorld:handleBlobbyWorldCollision()
  -- Collision between left blobby and the net
  if self.blobPosition[LEFT_PLAYER].x + BLOBBY_LOWER_RADIUS > NET_POSITION_X - NET_RADIUS then
    self.blobPosition[LEFT_PLAYER].x = NET_POSITION_X - NET_RADIUS - BLOBBY_LOWER_RADIUS
  end

  -- Collision between right blobby and the net
  if self.blobPosition[RIGHT_PLAYER].x - BLOBBY_LOWER_RADIUS < NET_POSITION_X + NET_RADIUS then
    self.blobPosition[RIGHT_PLAYER].x = NET_POSITION_X + NET_RADIUS + BLOBBY_LOWER_RADIUS
  end

  -- Collision between left blobby and the border
  if self.blobPosition[LEFT_PLAYER].x < LEFT_PLANE then
    self.blobPosition[LEFT_PLAYER].x = LEFT_PLANE
  end

  -- Collision between right blobby and the border
  if self.blobPosition[RIGHT_PLAYER].x > RIGHT_PLANE then
    self.blobPosition[RIGHT_PLAYER].x = RIGHT_PLANE
  end
end

function PhysicWorld:handleBallWorldCollision()
  local playerSide = (self.ballPosition.x > NET_POSITION_X) and RIGHT_PLAYER or LEFT_PLAYER

  -- Collision between ball and the ground
  if self.ballPosition.y + BALL_RADIUS > GROUND_PLANE_HEIGHT_MAX then
    -- print("ball collided with ground at " .. tostring(self.ballPosition))

    self.ballVelocity = self.ballVelocity:reflectY()
    self.ballVelocity = self.ballVelocity * 0.95
    self.ballPosition.y = GROUND_PLANE_HEIGHT_MAX - BALL_RADIUS

    self.eventCallback(MatchEvent.BALL_HIT_GROUND, playerSide)
  end

  -- Collision between ball and the left border
  if (self.ballPosition.x - BALL_RADIUS <= LEFT_PLANE) and (self.ballVelocity.x < 0.0) then
    -- print("ball collided with left border at " .. tostring(self.ballPosition))

    self.ballVelocity = self.ballVelocity:reflectX()
    -- set the balls position
    self.ballPosition.x = LEFT_PLANE + BALL_RADIUS

    self.eventCallback(MatchEvent.BALL_HIT_WALL, LEFT_PLAYER)

  -- Collision between ball and the right border
  elseif (self.ballPosition.x + BALL_RADIUS >= RIGHT_PLANE) and (self.ballVelocity.x > 0.0) then
    -- print("ball collided with right border at " .. tostring(self.ballPosition))

    self.ballVelocity = self.ballVelocity:reflectX()
    -- set the balls position
    self.ballPosition.x = RIGHT_PLANE - BALL_RADIUS

    self.eventCallback(MatchEvent.BALL_HIT_WALL, RIGHT_PLAYER)

  -- Collision between ball and the net left or right
  elseif (self.ballPosition.y > NET_SPHERE_POSITION) and (math.abs(self.ballPosition.x - NET_POSITION_X) < BALL_RADIUS + NET_RADIUS) then
    -- print("ball collided with left/right net at " .. tostring(self.ballPosition))

    self.ballVelocity = self.ballVelocity:reflectX()
    -- set the balls position so that it touches the net
    if playerSide == LEFT_PLAYER then
      self.ballPosition.x = NET_POSITION_X - NET_RADIUS - BALL_RADIUS
    end

    if playerSide == RIGHT_PLAYER then
      self.ballPosition.x = NET_POSITION_X + NET_RADIUS + BALL_RADIUS
    end

    self.eventCallback(MatchEvent.BALL_HIT_NET, playerSide)

  -- Collision between ball and the net top
  elseif (Vector2d(NET_POSITION_X, NET_SPHERE_POSITION) - self.ballPosition):length() < NET_RADIUS + BALL_RADIUS then
    -- print("ball collided with top net at " .. tostring(self.ballPosition))

    -- calculate
    local normal = (Vector2d(NET_POSITION_X, NET_SPHERE_POSITION) - self.ballPosition):normalise()

    -- normal component of kinetic energy
    local perpEkin = normal:dot(self.ballVelocity) ^ 2
    -- parallel component of kinetic energy
    local paraEkin = self.ballVelocity:lengthSq() - perpEkin

    -- the normal component is damped stronger than the parallel component
    -- the values are ~ 0.85 and ca. 0.95, because speed is sqrt(ekin)
    perpEkin = perpEkin * 0.7
    paraEkin = paraEkin * 0.9

    local newSpeed = math.sqrt(perpEkin + paraEkin)

    self.ballVelocity = self.ballVelocity:reflect(normal):normalise() * newSpeed
    -- pushes the ball out of the net
    self.ballPosition = Vector2d(NET_POSITION_X, NET_SPHERE_POSITION) - normal * (NET_RADIUS + BALL_RADIUS)

    self.eventCallback(MatchEvent.BALL_HIT_NET_TOP, NO_PLAYER)
  end
end

-- PlayerSide player
function PhysicWorld:isBlobbyBallCollisionTop(player)
  local blobbyPosition = Vector2d(self.blobPosition[player].x, self.blobPosition[player].y - BLOBBY_UPPER_SPHERE)
  return self:isCircleCircleCollision(self.ballPosition, BALL_RADIUS, blobbyPosition, BLOBBY_UPPER_RADIUS)
end

-- PlayerSide player
function PhysicWorld:isBlobbyBallCollisionBottom(player)
  local blobbyPosition = Vector2d(self.blobPosition[player].x, self.blobPosition[player].y + BLOBBY_LOWER_SPHERE)
  return self:isCircleCircleCollision(self.ballPosition, BALL_RADIUS, blobbyPosition, BLOBBY_LOWER_RADIUS)
end

-- calculates whether two circles overlap
-- Vector2d pos1, number rad1, const Vector2d pos2, number rad2
function PhysicWorld:isCircleCircleCollision(pos1, rad1, pos2, rad2)
  return (pos1 - pos2):lengthSq() < (rad1 + rad2) ^ 2
end

-- PlayerSide player
function PhysicWorld:isBlobbyOnGround(player)
  if player == LEFT_PLAYER or player == RIGHT_PLAYER then
    return self.blobPosition[player].y >= GROUND_PLANE_HEIGHT
  end

  return false;
end

-- PlayerSide player
function PhysicWorld:handleBlobbyAnimationStep(player)
  if self.blobState[player] < 0.0 then
    self.blobAnimationSpeed[player] = 0.0
    self.blobState[player] = 0
  end

  if self.blobState[player] >= 4.0 then
    self.blobAnimationSpeed[player] = -BLOBBY_ANIMATION_SPEED
  end

  self.blobState[player] = self.blobState[player] + self.blobAnimationSpeed[player]
end

-- PlayerSide player
function PhysicWorld:startBlobbyAnimation(player)
  if self.blobAnimationSpeed[player] == 0.0 then
    self.blobAnimationSpeed[player] = BLOBBY_ANIMATION_SPEED
  end
end

-- PlayerSide player
function PhysicWorld:getBlobPosition(player)
  return self.blobPosition[player]
end

-- PlayerSide player
function PhysicWorld:getBlobVelocity(player)
  return self.blobVelocity[player]
end

-- PlayerSide player
function PhysicWorld:getBlobState(player)
  return self.blobState[player]
end

function PhysicWorld:setEventCallback(callback)
  self.eventCallback = callback
end

return PhysicWorld
