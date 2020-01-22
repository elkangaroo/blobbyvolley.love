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
  scoreToWin = scoreToWin or GameConfig.get("scoretowin")

  self.logic = GameLogic.createGameLogic(rules, self, scoreToWin)
  self.isPaused = false
  self.isRemote = isRemote
  self.players = {
    [LEFT_PLAYER] = nil,
    [RIGHT_PLAYER] = nil,
  }

  self.physicWorld = PhysicWorld()

  if not self.isRemote then
    -- self.physicWorld:setEventCallback( [this]( const MatchEvent& event ) { mEvents.push_back(event) } )
  end
end

function DuelMatch:setPlayers(lplayer, rplayer)
  self.players[LEFT_PLAYER] = lplayer
  self.players[RIGHT_PLAYER] = rplayer
end

-- string rules, number scoreToWin
function DuelMatch:setRules(rules, scoreToWin)
  scoreToWin = scoreToWin or GameConfig.get("scoretowin")
  self.logic = GameLogic.createGameLogic(rules, self, scoreToWin)
end

function DuelMatch:step()
  if self.isPaused then
    return
  end

  -- mTransformedInput[LEFT_PLAYER] = mInputSources[LEFT_PLAYER]->updateInput()
  -- mTransformedInput[RIGHT_PLAYER] = mInputSources[RIGHT_PLAYER]->updateInput()

  if not self.isRemote then
    -- mTransformedInput[LEFT_PLAYER] = mLogic->transformInput( mTransformedInput[LEFT_PLAYER], LEFT_PLAYER )
    -- mTransformedInput[RIGHT_PLAYER] = mLogic->transformInput( mTransformedInput[RIGHT_PLAYER], RIGHT_PLAYER )
  end

  -- self.logic:step(self:getState())
  self.physicWorld:step(self.logic.isBallValid, self.isGameRunning)
  -- self.physicWorld:step(
  --   mTransformedInput[LEFT_PLAYER],
  --   mTransformedInput[RIGHT_PLAYER],
  --   self.logic:isBallValid(),
  --   self.logic:isGameRunning()
  -- )

  -- for( const auto& event : mEvents )
  -- {
  -- switch( event.event )
  -- {
  -- case MatchEvent::BALL_HIT_BLOB:
  -- mLogic->onBallHitsPlayer( event.side )
  -- break
  -- case MatchEvent::BALL_HIT_GROUND:
  -- mLogic->onBallHitsGround( event.side )
  -- // if not valid, reduce velocity
  -- if(!mLogic->isBallValid())
  -- mPhysicWorld->setBallVelocity( mPhysicWorld->getBallVelocity().scale(0.6) )
  -- break
  -- case MatchEvent::BALL_HIT_NET:
  -- mLogic->onBallHitsNet( event.side )
  -- break
  -- case MatchEvent::BALL_HIT_NET_TOP:
  -- mLogic->onBallHitsNet( NO_PLAYER )
  -- break
  -- case MatchEvent::BALL_HIT_WALL:
  -- mLogic->onBallHitsWall( event.side )
  -- break
  -- default:
  -- break
  -- }
  -- }

  errorside = self.logic:getLastErrorSide()
  if errorside ~= NO_PLAYER then
    print("error by player " .. errorside)
    -- mEvents.emplace_back( MatchEvent::PLAYER_ERROR, errorside, 0 )
    -- self.physicWorld:setBallVelocity( self.physicWorld:getBallVelocity().scale(0.6) )
  end

  self.logic.servingPlayer = LEFT_PLAYER
  if self.logic.isBallValid and self:canStartRound(self.logic.servingPlayer) then
    self:resetBall(self.logic.servingPlayer)
    self.logic:onServe()
    -- mEvents.emplace_back( MatchEvent::RESET_BALL, NO_PLAYER, 0 )
  end
end

-- PlayerSide side
function DuelMatch:canStartRound(side)
  print("blob hit ground = " .. (self.physicWorld:blobHitGround(side) and "true" or "false"))

	return self.physicWorld:blobHitGround(side)
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

-- number left, number right
function DuelMatch:setScore(left, right)
  self.logic:setScore(LEFT_PLAYER, left)
  self.logic:setScore(RIGHT_PLAYER, right)
end

function DuelMatch:pause()
  -- self.logic:onPause()
  self.isPaused = true
end

function DuelMatch:unpause()
  -- self.logic:onUnPause()
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

return DuelMatch
