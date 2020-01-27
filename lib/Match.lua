local Match = {}
Match.__index = Match

setmetatable(Match, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

-- boolean isRemote, string rules, number scoreToWin
function Match:__construct(isRemote, rules, scoreToWin)
  self.logic = GameLogic.createGameLogic(rules, self, scoreToWin or GameConfig.getNumber("scoretowin"))
  self.isPaused = false
  self.isRemote = isRemote
  self.players = { [LEFT_PLAYER] = nil, [RIGHT_PLAYER] = nil }
  self.inputSources = { [LEFT_PLAYER] = nil, [RIGHT_PLAYER] = nil }
  self.events = {}

  self.physicWorld = PhysicWorld()
  self:setInputSources(InputSource(), InputSource())

  if not self.isRemote then
    self.physicWorld:setEventCallback(function(type, side, intensity)
      self:addEvent(type, side, intensity)
    end)
  end
end

-- PlayerIdentity lplayer, PlayerIdentity rplayer
function Match:setPlayers(lplayer, rplayer)
  self.players[LEFT_PLAYER] = lplayer
  self.players[RIGHT_PLAYER] = rplayer
end

-- InputSource linput, InputSource rinput
function Match:setInputSources(linput, rinput)
	self.inputSources[LEFT_PLAYER] = linput
  self.inputSources[LEFT_PLAYER].match = self
	self.inputSources[RIGHT_PLAYER] = rinput
	self.inputSources[RIGHT_PLAYER].match = self
end

-- string rules, number scoreToWin
function Match:setRules(rules, scoreToWin)
  self.logic = GameLogic.createGameLogic(rules, self, scoreToWin or GameConfig.getNumber("scoretowin"))
end

function Match:update()
  if self.isPaused then
    return
  end

  local transformedInputs = {
    [LEFT_PLAYER] = self.inputSources[LEFT_PLAYER]:updateInput(),
	  [RIGHT_PLAYER] = self.inputSources[RIGHT_PLAYER]:updateInput(),
  }

  if not self.isRemote then
    transformedInputs[LEFT_PLAYER] = self.logic:transformInput(transformedInputs[LEFT_PLAYER], LEFT_PLAYER)
		transformedInputs[RIGHT_PLAYER] = self.logic:transformInput(transformedInputs[RIGHT_PLAYER], RIGHT_PLAYER)
  end

  self.logic:update()
  -- self.logic:update(self:getState())
  self.physicWorld:update(transformedInputs, self.logic.isBallValid, self.logic.isGameRunning)

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

  local errorside = self.logic:getLastErrorSide()
  if errorside ~= NO_PLAYER then
    -- print("error by player " .. errorside)
    self:addEvent(MatchEvent.PLAYER_ERROR, errorside)
    self.physicWorld.ballVelocity = self.physicWorld.ballVelocity * 0.6
  end

  if not self.logic.isBallValid and self:canStartRound(self.logic.servingPlayer) then
    self:resetBall(self.logic.servingPlayer)
    self.logic:onServe()
    self:addEvent(MatchEvent.RESET_BALL, NO_PLAYER)
  end
end

-- PlayerSide side
function Match:canStartRound(side)
	return self.physicWorld:isBlobbyOnGround(side)
    and self.physicWorld.ballVelocity.y < 1.5
    and self.physicWorld.ballVelocity.y > -1.5
    and self.physicWorld.ballPosition.y > 430
end

-- PlayerSide side
function Match:resetBall(side)
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
function Match:setServingPlayer(side)
	self.logic.servingPlayer = side
	self:resetBall(side)
	self.logic:onServe()
end

-- number left, number right
function Match:setScore(left, right)
  self.logic:setScore(LEFT_PLAYER, left)
  self.logic:setScore(RIGHT_PLAYER, right)
end

function Match:pause()
  self.logic:onPause()
  self.isPaused = true
end

function Match:unpause()
  self.logic:onUnPause()
  self.isPaused = false
end

function Match:getWinningPlayer()
  return self.logic.winningPlayer
end

-- PlayerSide player
function Match:getBlobPosition(player)
  if player == LEFT_PLAYER or player == RIGHT_PLAYER then
    return self.physicWorld:getBlobPosition(player)
  else
    return Vector2d(0.0, 0.0)
  end
end

-- PlayerSide player
function Match:getBlobState(player)
  if player == LEFT_PLAYER or player == RIGHT_PLAYER then
    return self.physicWorld:getBlobState(player)
  else
    return 0.0
  end
end

function Match:getBallPosition()
  return self.physicWorld.ballPosition
end

function Match:getBallVelocity()
  return self.physicWorld.ballVelocity
end

function Match:getBallRotation()
  return self.physicWorld.ballRotation
end

function Match:getServingPlayer()
  return self.logic.servingPlayer
end

-- PlayerSide player
function Match:getScore(player)
  return self.logic:getScore(player)
end

-- PlayerSide side
function Match:getTouches(side)
  return self.logic:getTouches(side)
end

function Match:getClock()
  return self.logic:getClock()
end

-- PlayerSide player
function Match:getPlayer(player)
  return self.players[player]
end

function Match:isBallValid()
  return self.logic.isBallValid
end

function Match:isGameRunning()
  return self.logic.isGameRunning
end

function Match:addEvent(type, side, intensity)
  table.insert(self.events, { type = type, side = side or NO_PLAYER, intensity = intensity or 0 })
end

function Match:resetEvents()
  self.events = {}
end

return Match
