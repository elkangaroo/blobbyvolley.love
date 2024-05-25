local ScriptedGameLogic = {}
ScriptedGameLogic.__index = ScriptedGameLogic

setmetatable(ScriptedGameLogic, {
  __index = FallbackGameLogic, -- base class
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

-- string filename, Match match, number ScoreToWin
function ScriptedGameLogic:__construct(filename, match, scoreToWin)
  FallbackGameLogic:__construct(scoreToWin)

  self.sourceFile = filename
  self.match = match
  self.sandbox = {
    SCORE_TO_WIN = self.scoreToWin,

    get_touches = function(side)
      assert(side == LEFT_PLAYER or side == RIGHT_PLAYER)
      return self.match:getTouches(side)
    end,
    score = function(side, amount)
      self:score(side, amount)
    end,
    mistake = function(errorSide, servingSide, amount)
      self:score(self:getOtherSide(errorSide), amount)
      self:onError(errorSide, servingSide)
    end,
    servingplayer = function()
      return self.servingPlayer
    end,
    time = function()
      return self:getGameTime()
    end,
    isgamerunning = function()
      return self.isGameRunning
    end,
  }

  LuaApiSandbox.load({
    "api/api.lua",
    "api/rules_api.lua",
    "api/rules/" .. filename
  }, self.sandbox)

  self.scoreToWin = self.sandbox.SCORE_TO_WIN
  self.author = self.sandbox.__AUTHOR__ and self.sandbox.__AUTHOR__ or "unknown author"
  self.title = self.sandbox.__TITLE__ and self.sandbox.__TITLE__ or "untitled script"

  print("loaded rules " .. self.title .. " by " .. self.author .. " from " .. self.sourceFile)
end

function ScriptedGameLogic:checkWin()
  if "function" ~= type(self.sandbox.IsWinning) then
    return FallbackGameLogic.checkWin(self)
  end

  local lscore = self:getScore(LEFT_PLAYER)
  local rscore = self:getScore(RIGHT_PLAYER)
  local won = self.sandbox.IsWinning(lscore, rscore)

  if won and lscore > rscore then
    return LEFT_PLAYER
  end

  if won and lscore < rscore then
    return RIGHT_PLAYER
  end

  return NO_PLAYER
end

-- PlayerInput ip, PlayerSide player
function ScriptedGameLogic:handleInput(ip, player)
  if "function" ~= type(self.sandbox.HandleInput) then
    return FallbackGameLogic.handleInput(self, ip, player)
  end

  local ret = {}
  ret.left, ret.right, ret.up = self.sandbox.HandleInput(player, ip.left, ip.right, ip.up)

  return ret
end

-- PlayerSide side
function ScriptedGameLogic:OnBallHitsPlayerHandler(side)
  if "function" ~= type(self.sandbox.OnBallHitsPlayer) then
    FallbackGameLogic.OnBallHitsPlayerHandler(self, side)
    return
  end

  self.sandbox.OnBallHitsPlayer(side)
end

-- PlayerSide side
function ScriptedGameLogic:OnBallHitsGroundHandler(side)
  if "function" ~= type(self.sandbox.OnBallHitsGround) then
    FallbackGameLogic.OnBallHitsGroundHandler(self, side)
    return
  end

  self.sandbox.OnBallHitsGround(side)
end

-- PlayerSide side
function ScriptedGameLogic:OnBallHitsWallHandler(side)
  if "function" ~= type(self.sandbox.OnBallHitsWall) then
    FallbackGameLogic.OnBallHitsWallHandler(self, side)
    return
  end

  self.sandbox.OnBallHitsWall(side)
end

-- PlayerSide side
function ScriptedGameLogic:OnBallHitsNetHandler(side)
  if "function" ~= type(self.sandbox.OnBallHitsNet) then
    FallbackGameLogic.OnBallHitsNetHandler(self, side)
    return
  end

  self.sandbox.OnBallHitsNet(side)
end

-- MatchState state
function ScriptedGameLogic:OnGameHandler(state)
  if "function" ~= type(self.sandbox.OnGame) then
    FallbackGameLogic.OnGameHandler(self, state)
    return
  end

  self.sandbox.OnGame(state)
end

return ScriptedGameLogic
