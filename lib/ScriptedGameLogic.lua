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
  ScriptableComponent:setComponentPointer(self)

  __SCRIPTED_GAME_LOGIC_POINTER = self
  SCORE_TO_WIN = self.scoreToWin

  -- setGameConstants() -- currently set in main.lua
	-- setGameFunctions() -- currently defined in ScriptableComponent

  ScriptableComponent:openScript("api/api.lua")
	ScriptableComponent:openScript("api/rules_api.lua")
	ScriptableComponent:openScript("api/rules/" .. filename)

  self.scoreToWin = SCORE_TO_WIN
  self.author = __AUTHOR__ and __AUTHOR__ or "unknown author"
  self.title = __TITLE__ and __TITLE__ or "untitled script"
  self.sourceFile = filename

  print("loaded rules " .. self:getTitle() .. " by " .. self:getAuthor() .. " from " .. self:getSourceFile())
end

-- PlayerSide side
function ScriptedGameLogic:OnBallHitsPlayerHandler(side)
  if "function" ~= type(OnBallHitsPlayer) then
		FallbackGameLogic:OnBallHitsPlayerHandler(side)
		return
	end

  OnBallHitsPlayer(side)
end

-- PlayerSide side
function ScriptedGameLogic:OnBallHitsWallHandler(side)
  if "function" ~= type(OnBallHitsWall) then
		FallbackGameLogic:OnBallHitsWallHandler(side)
		return
	end

  OnBallHitsWall(side)
end

-- PlayerSide side
function ScriptedGameLogic:OnBallHitsNetHandler(side)
  if "function" ~= type(OnBallHitsNet) then
		FallbackGameLogic:OnBallHitsNetHandler(side)
		return
	end

  OnBallHitsNet(side)
end

-- PlayerSide side
function ScriptedGameLogic:OnBallHitsGroundHandler(side)
  if "function" ~= type(OnBallHitsGround) then
		FallbackGameLogic:OnBallHitsGroundHandler(side)
		return
	end

  OnBallHitsGround(side)
end

function ScriptedGameLogic:getAuthor()
  return self.author
end

function ScriptedGameLogic:getTitle()
  return self.title
end

function ScriptedGameLogic:getSourceFile()
  return self.sourceFile
end

function ScriptedGameLogic:getPointer()
	return __SCRIPTED_GAME_LOGIC_POINTER
end


--
-- common functions for lua rules api
--


-- PlayerSide side, number amount
function score(side, amount)
	ScriptedGameLogic:getPointer():score(side, amount)
end

-- PlayerSide errorSide, PlayerSide servingSide, number amount
function mistake(errorSide, servingSide, amount)
  local logic = ScriptedGameLogic:getPointer()
  logic:score(logic:getOtherSide(errorSide), amount)
	logic:onError(errorSide, servingSide)
end

function servingplayer()
	return ScriptedGameLogic:getPointer().servingPlayer
end

function time()
	return ScriptedGameLogic:getPointer():getGameTime()
end

function isgamerunning()
	return ScriptedGameLogic:getPointer().isGameRunning
end

return ScriptedGameLogic
