local ScriptedInputSource = {}
ScriptedInputSource.__index = ScriptedInputSource

setmetatable(ScriptedInputSource, {
  __index = InputSource, -- base class
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

-- string filename, PlayerSide side, number difficulty
function ScriptedInputSource:__construct(filename, side, difficulty)
  InputSource:__construct()

  LUA_REGISTRYINDEX = {
    __ScriptComponent__ = self
  }

  self.dummyWorld = PhysicWorld()
  self.startTime = love.timer.getTime()
	self.difficulty = difficulty
	self.side = side

	self.lastJump = false
	self.jumpDelay = 0

  __DIFFICULTY = difficulty / 25.0
  __DEBUG = GameConfig.getBoolean("bot_debug")
  __SIDE = side

  self.openScript("api/api.lua")
	self.openScript("api/bot_api.lua")
	self.openScript("api/bots/" .. filename)

	if nil == __OnStep then
		ScriptedInputSource.handleScriptError("Missing bot function __OnStep, check bot_api.lua!")
	end
end

function ScriptedInputSource.handleScriptError(errormsg)
  error("Lua Bot Error: " .. errormsg)
end

-- string filename
function ScriptedInputSource.openScript(filename)
  local ending = ".lua"
  if filename:sub(-#ending) ~= ending then
    filename = filename .. ending
  end

  chunk, errormsg = love.filesystem.load(filename)
  if errormsg then
    ScriptedInputSource.handleScriptError(errormsg)
  end

  chunk()
end

function ScriptedInputSource:getNextInput()
  local serving = false
	-- reset input
  __WANT_LEFT = false
  __WANT_RIGHT = false
  __WANT_JUMP = false

	if ScriptedInputSource:getMatch() == 0 then
		return PlayerInput()
  else
    self.match = ScriptedInputSource:getMatch()
	end

  __OnStep()

  -- if no player is serving player, assume the left one is
  local servingPlayer = ScriptedInputSource:getMatch():getServingPlayer()
  if servingPlayer == NO_PLAYER then
    servingPlayer = LEFT_PLAYER
  end

	if ScriptedInputSource:getMatch():isGameRunning() and self.side == servingPlayer then
		serving = true
	end

	wantleft = __WANT_LEFT
	wantright = __WANT_RIGHT
	wantjump = __WANT_JUMP

	if serving and self.startTime + WAITING_TIME > love.timer.getTime() then
		return PlayerInput()
  end

	-- random jump delay depending on difficulty
	if wantjump and not self.lastJump then
		self.jumpDelay = self.jumpDelay - 1
		if self.jumpDelay > 0 then
			wantjump = false
		else
			self.jumpDelay = math.max(0.0, math.min(love.math.randomNormal(self.difficulty / 3, self.difficulty / 2), self.difficulty))
		end
	end

	self.lastJump = wantjump

  return PlayerInput(wantleft, wantright, wantjump)
end

function ScriptedInputSource:getComponent()
  return LUA_REGISTRYINDEX.__ScriptComponent__
end

function ScriptedInputSource:getMatch()
  return ScriptedInputSource:getComponent().match
end

function ScriptedInputSource:getWorld()
  return ScriptedInputSource:getComponent().dummyWorld
end

--
-- standard lua functions
--

function get_ball_pos()
  local vector = ScriptedInputSource:getMatch():getBallPosition()
	return vector.x, 600 - vector.y
end

function get_ball_vel()
  local vector = ScriptedInputSource:getMatch():getBallVelocity()
	return vector.x, -vector.y
end

function get_blob_pos(side)
	assert(side == LEFT_PLAYER or side == RIGHT_PLAYER)
  local vector = ScriptedInputSource:getMatch():getBlobPosition(side)
  return vector.x, 600 - vector.y
end

function get_blob_vel(side)
  assert(side == LEFT_PLAYER or side == RIGHT_PLAYER)
  local vector = ScriptedInputSource:getMatch():getBlobVelocity(side)
  return vector.x, -vector.y
end

function get_score(side)
  assert(side == LEFT_PLAYER or side == RIGHT_PLAYER)
  return ScriptedInputSource:getMatch():getScore(side)
end

function get_touches(side)
  assert(side == LEFT_PLAYER or side == RIGHT_PLAYER)
  return ScriptedInputSource:getMatch():getTouches(side)
end

function is_ball_valid()
  return ScriptedInputSource:getMatch():isBallValid()
end

function is_game_running()
  return ScriptedInputSource:getMatch():isGameRunning()
end

function get_serving_player()
  return ScriptedInputSource:getMatch():getServingPlayer()
end

-- number steps, number x, number y, number vx, number vy
function simulate(steps, x, y, vx, vy)
	local world = ScriptedInputSource:getWorld()
  world.ballPosition = Vector2d(x, 600 - y)
  world.ballVelocity = Vector2d(vx, -vy)

	for i = 0, steps do
		-- set ball valid to false to ignore blobby bounces
		world:update({[LEFT_PLAYER] = PlayerInput(), [RIGHT_PLAYER] = PlayerInput()}, false, true)
	end

	return world.ballPosition.x, 600 - world.ballPosition.y, world.ballVelocity.x, -world.ballVelocity.y
end

-- number x, number y, number vx, number vy, string axis, number coordinate
function simulate_until(x, y, vx, vy, axis, coordinate)
	local ival = (axis == "x") and x or y
	if axis ~= "x" and axis ~= "y" then
		error("invalid condition specified: choose either 'x' or 'y'")
	end

  local world = ScriptedInputSource:getWorld()
	world.ballPosition = Vector2d(x, 600 - y)
	world.ballVelocity = Vector2d(vx, -vy)

	local steps = 0
  local init = ival < coordinate
	while coordinate ~= ival and steps < 75 * 5 do
		steps = steps + 1
		-- set ball valid to false to ignore blobby bounces
		world:update({[LEFT_PLAYER] = PlayerInput(), [RIGHT_PLAYER] = PlayerInput()}, false, true)
		-- check for the condition
		local pos = world.ballPosition
		local v = (axis == "x") and pos.x or 600 - pos.y
		if (v < coordinate) ~= init then
			break
    end
	end

	-- indicate failure
	if steps == 75 * 5 then
		steps = -1
  end

	return steps, world.ballPosition.x, 600 - world.ballPosition.y, world.ballVelocity.x, -world.ballVelocity.y
end

return ScriptedInputSource
