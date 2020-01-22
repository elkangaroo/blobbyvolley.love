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
	self.touches[other_side(side)] = 0

	-- OnBallHitsGroundHandler(side)
end

function GameLogic:isGroundCollisionValid()
	return self.squishGround <= 0 and self.isBallValid
end

function GameLogic:getLastErrorSide()
  lastError = self.lastError
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

-- string file, DuelMatch match, number scoreToWin
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
