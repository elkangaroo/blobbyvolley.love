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

  print("loaded rules " .. FALLBACK_RULES_NAME .. " by Blobby Volley 2 Developers")
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

return FallbackGameLogic
