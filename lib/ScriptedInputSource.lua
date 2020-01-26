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
  ScriptableComponent:setComponentPointer(self)

  self.dummyWorld = PhysicWorld()
  self.startTime = love.timer.getTime()
	self.difficulty = difficulty
	self.side = side

	self.lastJump = false
	self.jumpDelay = 0

  __SCRIPTED_INPUT_SOURCE_POINTER = self
  __DIFFICULTY = difficulty / 25.0
  __DEBUG = GameConfig.getBoolean("bot_debug")
  __SIDE = side

  -- setGameConstants() -- currently set in main.lua
	-- setGameFunctions() -- currently defined in ScriptableComponent

  ScriptableComponent:openScript("api/api.lua")
	ScriptableComponent:openScript("api/bot_api.lua")
	ScriptableComponent:openScript("api/bots/" .. filename)

  if "function" ~= type(__OnStep) then
		ScriptableComponent:handleScriptError("Missing bot function __OnStep, check bot_api.lua!")
	end
end

function ScriptedInputSource:getNextInput()
  local serving = false
	-- reset input
  __WANT_LEFT = false
  __WANT_RIGHT = false
  __WANT_JUMP = false

	if nil == ScriptableComponent:getMatch() then
		return PlayerInput()
  end

  __OnStep()

  -- if no player is serving player, assume the left one is
  local servingPlayer = ScriptableComponent:getMatch():getServingPlayer()
  if servingPlayer == NO_PLAYER then
    servingPlayer = LEFT_PLAYER
  end

	if ScriptableComponent:getMatch():isGameRunning() and self.side == servingPlayer then
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

function ScriptedInputSource:getPointer()
	return __SCRIPTED_INPUT_SOURCE_POINTER
end


--
-- common functions for lua bots api
--


-- number steps, number x, number y, number vx, number vy
function simulate(steps, x, y, vx, vy)
	local world = ScriptedInputSource:getPointer().dummyWorld
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

  local world = ScriptedInputSource:getPointer().dummyWorld
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
