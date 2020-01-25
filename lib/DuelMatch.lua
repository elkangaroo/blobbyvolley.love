local DuelMatch = {}
DuelMatch.__index = DuelMatch

setmetatable(DuelMatch, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

-- boolean isRemote, string rules, number scoreToWin
function DuelMatch:__construct(isRemote, rules, scoreToWin)
  self.logic = GameLogic.createGameLogic(rules, self, scoreToWin or GameConfig.get("scoretowin"))
  self.isPaused = false
  self.isRemote = isRemote
  self.players = {
    [LEFT_PLAYER] = nil,
    [RIGHT_PLAYER] = nil,
  }
  self.playerInputs = {
    [LEFT_PLAYER] = {
      left = false,
      right = false,
      up = false,
    },
    [RIGHT_PLAYER] = {
      left = false,
      right = false,
      up = false,
    },
  }
  self.events = {}

  self.physicWorld = PhysicWorld()
  if not self.isRemote then
    self.physicWorld:setEventCallback(function(type, side, intensity)
      self:addEvent(type, side, intensity)
    end)
  end
end

function DuelMatch:setPlayers(lplayer, rplayer)
  self.players[LEFT_PLAYER] = lplayer
  self.players[RIGHT_PLAYER] = rplayer
end

-- string rules, number scoreToWin
function DuelMatch:setRules(rules, scoreToWin)
  self.logic = GameLogic.createGameLogic(rules, self, scoreToWin or GameConfig.get("scoretowin"))
end

function DuelMatch:step()
  if self.isPaused then
    return
  end

  if not self.isRemote then
    -- self.playerInputs[LEFT_PLAYER] = self.logic:transformInput(self.playerInputs[LEFT_PLAYER], LEFT_PLAYER)
    -- self.playerInputs[RIGHT_PLAYER] = self.logic:transformInput(self.playerInputs[RIGHT_PLAYER], RIGHT_PLAYER)
  end

  self.logic:step()
  -- self.logic:step(self:getState())
  self.physicWorld:step(self.playerInputs, self.logic.isBallValid, self.logic.isGameRunning)

  for i, e in ipairs(self.events) do
    if e.type == MatchEvent.BALL_HIT_BLOB then
      self.logic:onBallHitsPlayer(e.side)
    elseif e.type == MatchEvent.BALL_HIT_GROUND then
      self.logic:onBallHitsGround(e.side)
      if not self.logic.isBallValid then
        self.physicWorld.ballVelocity = self.physicWorld.ballVelocity * 0.6
      end
    elseif e.type == MatchEvent.BALL_HIT_NET then
      self.logic:onBallHitsNet(e.side)
    elseif e.type == MatchEvent.BALL_HIT_NET_TOP then
      self.logic:onBallHitsNet(e.side)
    elseif e.type == MatchEvent.BALL_HIT_WALL then
      self.logic:onBallHitsWall(e.side)
    end
  end

  errorside = self.logic:getLastErrorSide()
  if errorside ~= NO_PLAYER then
    print("error by player " .. errorside)
    self:addEvent(MatchEvent.PLAYER_ERROR, errorside)
    self.physicWorld.ballVelocity = self.physicWorld.ballVelocity * 0.6
  end

  self.logic.servingPlayer = LEFT_PLAYER
  if self.logic.isBallValid and self:canStartRound(self.logic.servingPlayer) then
    self:resetBall(self.logic.servingPlayer)
    self.logic:onServe()
    self:addEvent(MatchEvent.RESET_BALL, NO_PLAYER)
  end
end

-- PlayerSide side
function DuelMatch:canStartRound(side)
	return self.physicWorld:isBlobbyOnGround(side)
    and self.physicWorld.ballVelocity.y < 1.5
    and self.physicWorld.ballVelocity.y > -1.5
    and self.physicWorld.ballPosition.y > 430
end

-- PlayerSide side
function DuelMatch:resetBall(side)
	if side == LEFT_PLAYER then
		self.physicWorld.ballPosition = Vector2d(200, STANDARD_BALL_HEIGHT)
	elseif side == RIGHT_PLAYER then
		self.physicWorld.ballPosition = Vector2d(600, STANDARD_BALL_HEIGHT)
	else
		self.physicWorld.ballPosition = Vector2d(400, 450)
  end

  print("reset ball at " .. tostring(self.physicWorld.ballPosition))

	self.physicWorld.ballVelocity = Vector2d()
	self.physicWorld.ballAngularVelocity = (side == RIGHT_PLAYER and -1 or 1) * STANDARD_BALL_ANGULAR_VELOCITY
end

-- PlayerSide side
function DuelMatch:setServingPlayer(side)
	self.logic.servingPlayer = side
	self:resetBall(side)
	self.logic:onServe()
end

-- number left, number right
function DuelMatch:setScore(left, right)
  self.logic:setScore(LEFT_PLAYER, left)
  self.logic:setScore(RIGHT_PLAYER, right)
end

function DuelMatch:pause()
  self.logic:onPause()
  self.isPaused = true
end

function DuelMatch:unpause()
  self.logic:onUnPause()
  self.isPaused = false
end

function DuelMatch:getWinningPlayer()
  return self.logic.winningPlayer
end

-- PlayerSide player
function DuelMatch:getBlobPosition(player)
  if player == LEFT_PLAYER or player == RIGHT_PLAYER then
    return self.physicWorld:getBlobPosition(player)
  else
    return Vector2d(0.0, 0.0)
  end
end

-- PlayerSide player
function DuelMatch:getBlobState(player)
  if player == LEFT_PLAYER or player == RIGHT_PLAYER then
    return self.physicWorld:getBlobState(player)
  else
    return 0.0
  end
end

function DuelMatch:getBallPosition()
  return self.physicWorld.ballPosition
end

function DuelMatch:getBallVelocity()
  return self.physicWorld.ballVelocity
end

function DuelMatch:getBallRotation()
  return self.physicWorld.ballRotation
end

function DuelMatch:getServingPlayer()
  return self.logic.servingPlayer
end

-- PlayerSide player
function DuelMatch:getScore(player)
  return self.logic:getScore(player)
end

function DuelMatch:getClock()
  return self.logic:getClock()
end

-- PlayerSide player
function DuelMatch:getPlayer(player)
  return self.players[player]
end

function DuelMatch:addEvent(type, side, intensity)
  table.insert(self.events, { type = type, side = side or NO_PLAYER, intensity = intensity or 0 })
end

function DuelMatch:resetEvents()
  self.events = {}
end

return DuelMatch
