local GameLogic = {}
GameLogic.__index = GameLogic

setmetatable(GameLogic, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

-- number scoreToWin
function GameLogic:__construct(scoreToWin)
  GameClock:reset()
  GameClock:start()

  self.scoreToWin = scoreToWin
  self.squishWall = 0
  self.squishGround = 0
  self.lastError = NO_PLAYER
  self.servingPlayer = NO_PLAYER
  self.winningPlayer = NO_PLAYER
  self.isBallValid = true
  self.isGameRunning = false

  self.scores = {
    [LEFT_PLAYER] = 0,
    [RIGHT_PLAYER] = 0,
  }
  self.touches = {
    [LEFT_PLAYER] = 0,
    [RIGHT_PLAYER] = 0,
  }
  self.squish = {
    [LEFT_PLAYER] = 0,
    [RIGHT_PLAYER] = 0,
  }
end

-- MatchState state
function GameLogic:step(state)
	GameClock:step()

	if GameClock.isRunning then
		self.squish[LEFT_PLAYER] = self.squish[LEFT_PLAYER] - 1
    self.squish[RIGHT_PLAYER] = self.squish[RIGHT_PLAYER] - 1
    self.squishWall = self.squishWall - 1
    self.squishGround = self.squishGround - 1

		-- OnGameHandler(state)
	end
end

function GameLogic:onPause()
	-- pausing for now only means stopping the clock
	GameClock:stop()
end

function GameLogic:onUnPause()
	GameClock:start()
end

function GameLogic:onServe()
	self.isBallValid = true
	self.isGameRunning = false
end

-- PlayerSide side
function GameLogic:onBallHitsGround(side)
	if not self:isGroundCollisionValid() then
		return
  end

	self.squishGround = SQUISH_TOLERANCE
	self.touches[self:getOtherSide(side)] = 0

  print("onBallHitsGround")
	-- OnBallHitsGroundHandler(side)
end

-- PlayerSide side
function GameLogic:onBallHitsPlayer(side)
	if not self:isCollisionValid(side) then
		return
  end

	-- otherwise, set the squish value
	self.squish[side] = SQUISH_TOLERANCE
	-- now, the other blobby has to accept the new hit!
	self.squish[self:getOtherSide(side)] = 0

	-- set the ball activity
	self.isGameRunning = true

	-- count the touches
	self.touches[side] = self.touches[side] + 1

  print("onBallHitsPlayer")
	-- OnBallHitsPlayerHandler(side)

	-- reset other players touches after OnBallHitsPlayerHandler is called, so
	-- we have still access to its old value inside the handler function
	self.touches[self:getOtherSide(side)] = 0
end

-- PlayerSide side
function GameLogic:onBallHitsWall(side)
  if not self:isWallCollisionValid() then
    return
  end

	-- otherwise, set the squish value
	self.squishWall = SQUISH_TOLERANCE

  print("onBallHitsWall")
	-- OnBallHitsWallHandler(side)
end

-- PlayerSide side
function GameLogic:onBallHitsNet(side)
	if not self:isWallCollisionValid() then
		return
  end

	-- otherwise, set the squish value
	self.squishWall = SQUISH_TOLERANCE

  print("onBallHitsNet")
	-- OnBallHitsNetHandler(side)
end

-- PlayerSide errorSide, PlayerSide servingSide
function GameLogic:onError(errorSide, servingSide)
	self.lastError = errorSide
	self.isBallValid = false

	self.touches[LEFT_PLAYER] = 0
	self.touches[RIGHT_PLAYER] = 0
	self.squish[LEFT_PLAYER] = 0
	self.squish[RIGHT_PLAYER] = 0
	self.squishWall = 0
	self.squishGround = 0

	self.servingPlayer = servingSide
end

function GameLogic:isGroundCollisionValid()
	return self.squishGround <= 0 and self.isBallValid
end

-- PlayerSide side
function GameLogic:isWallCollisionValid()
	return self.squishWall <= 0 and self.isBallValid
end

-- PlayerSide side
function GameLogic:isCollisionValid(side)
	return self.squish[side] <= 0
end

function GameLogic:getLastErrorSide()
  local lastError = self.lastError
  self.lastError = NO_PLAYER

  return lastError
end

-- PlayerSide side, number score
function GameLogic:setScore(side, score)
  self.scores[side] = score
end

-- PlayerSide side
function GameLogic:getScore(side)
  return self.scores[side]
end

-- PlayerSide side
function GameLogic:getTouches(side)
  return self.touches[side]
end

-- PlayerSide side
function GameLogic:getOtherSide(side)
  if side == LEFT_PLAYER then
      return RIGHT_PLAYER
  elseif side == RIGHT_PLAYER then
      return LEFT_PLAYER
  end
end

-- string file, Match match, number scoreToWin
function GameLogic.createGameLogic(file, match, scoreToWin)
  if file == FALLBACK_RULES_NAME then
    return GameLogic(scoreToWin)
  end

  if love.filesystem.getInfo("rules/" .. file) then
    return LuaGameLogic(file, match, scoreToWin)
  end

  return GameLogic(scoreToWin)
end

return GameLogic
