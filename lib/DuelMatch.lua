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

  -- self.logic = createGameLogic(rules, self, scoreToWin))
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
  -- self.logic = createGameLogic(rules, self, scoreToWin)
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

  -- self.logic:step(getState())
  -- self.physicWorld:step(
  --   mTransformedInput[LEFT_PLAYER],
  --   mTransformedInput[RIGHT_PLAYER],
  --   mLogic->isBallValid(),
  --   mLogic->isGameRunning()
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

  -- errorside = self.logic:getLastErrorSide()
  errorside = NO_PLAYER
  if errorside ~= NO_PLAYER then
    -- mEvents.emplace_back( MatchEvent::PLAYER_ERROR, errorside, 0 )
    -- self.physicWorld:setBallVelocity( self.physicWorld:getBallVelocity().scale(0.6) )
  end

  -- if self.logic:isBallValid() and canStartRound(self.logic:getServingPlayer()) then
  --   resetBall( mLogic->getServingPlayer() )
  --   self.logic:onServe()
  --   mEvents.emplace_back( MatchEvent::RESET_BALL, NO_PLAYER, 0 )
  -- end
end

-- number left, number right
function DuelMatch:setScore(left, right)
  -- self.logic:setScore(LEFT_PLAYER, left)
  -- self.logic:setScore(RIGHT_PLAYER, right)
end

function DuelMatch:pause()
  -- self.logic:onPause()
  self.isPaused = true
end

function DuelMatch:unpause()
  -- self.logic:onUnPause()
  self.isPaused = false
end

function DuelMatch:winningPlayer()
  -- return self.logic:getWinningPlayer()
  return NO_PLAYER
end

-- PlayerSide player
function DuelMatch:getBlobPosition(player)
  if player == LEFT_PLAYER or player == RIGHT_PLAYER then
    return self.physicWorld:getBlobPosition(player)
  else
    return { x = 0.0, y = 0.0 }
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

-- PlayerSide player
function DuelMatch:getPlayer(player)
  return self.players[player]
end

return DuelMatch
