local FallbackGameLogic = {}
FallbackGameLogic.__index = FallbackGameLogic

setmetatable(FallbackGameLogic, {
  __index = GameLogic, -- base class
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

-- number scoreToWin
function FallbackGameLogic:__construct(scoreToWin)
  GameLogic:__construct(scoreToWin)

  print("loaded rules " .. self:getTitle() .. " by " .. self:getAuthor())
end

function FallbackGameLogic:checkWin()
  local left = self:getScore(LEFT_PLAYER)
  local right = self:getScore(RIGHT_PLAYER)
  if left >= self.scoreToWin and left >= right + 2 then
    return LEFT_PLAYER
  end

  if right >= self.scoreToWin and right >= left + 2 then
    return RIGHT_PLAYER
  end

  return NO_PLAYER
end

-- PlayerSide side
function FallbackGameLogic:OnBallHitsPlayerHandler(side)
  if self:getTouches(side) > 3 then
    self:score(self:getOtherSide(side), 1)
    self:onError(side, self:getOtherSide(side))
  end
end

-- PlayerSide side
function FallbackGameLogic:OnBallHitsGroundHandler(side)
  self:score(self:getOtherSide(side), 1)
  self:onError(side, self:getOtherSide(side))
end

function FallbackGameLogic:OnBallHitsWallHandler(side) end
function FallbackGameLogic:OnBallHitsNetHandler(side) end
function FallbackGameLogic:OnGameHandler(state) end

function FallbackGameLogic:getAuthor()
  return "Blobby Volley 2 Developers"
end

function FallbackGameLogic:getTitle()
  return FALLBACK_RULES_NAME
end

function FallbackGameLogic:getSourceFile()
  return ""
end

return FallbackGameLogic
