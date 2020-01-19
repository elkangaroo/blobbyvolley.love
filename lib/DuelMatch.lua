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

  -- self.logic = createGameLogic(rules, self, scoreToWin)),
  self.isPaused = false
  self.isRemote = isRemote
  self.players = {
    LEFT_PLAYER = nil,
    RIGHT_PLAYER = nil,
  }

  -- self.physicWorld = PhysicWorld()

  if not self.isRemote then
    -- self.physicWorld:setEventCallback( [this]( const MatchEvent& event ) { mEvents.push_back(event); } );
  end
end

function DuelMatch:setPlayers(lplayer, rplayer)
  self.players[LEFT_PLAYER] = lplayer
  self.players[RIGHT_PLAYER] = rplayer
end

return DuelMatch
