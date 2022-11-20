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

  self.sourceFile = filename
  self.dummyWorld = PhysicWorld()
  self.startTime = love.timer.getTime()
  self.difficulty = difficulty
  self.side = side
  self.lastJump = false
  self.jumpDelay = 0

  self.sandbox = {
    __DIFFICULTY = difficulty / 25.0,
    __DEBUG = GameConfig.getBoolean("bot_debug"),
    __SIDE = side,

    get_ball_pos = function()
      local vector = self.match:getBallPosition()
      return vector.x, 600 - vector.y
    end,
    get_ball_vel = function()
      local vector = self.match:getBallVelocity()
      return vector.x, -vector.y
    end,
    get_blob_pos = function(side)
      assert(side == LEFT_PLAYER or side == RIGHT_PLAYER)
      local vector = self.match:getBlobPosition(side)
      return vector.x, 600 - vector.y
    end,
    get_blob_vel = function(side)
      assert(side == LEFT_PLAYER or side == RIGHT_PLAYER)
      local vector = self.match:getBlobVelocity(side)
      return vector.x, -vector.y
    end,
    get_score = function(side)
      assert(side == LEFT_PLAYER or side == RIGHT_PLAYER)
      return self.match:getScore(side)
    end,
    get_touches = function(side)
      assert(side == LEFT_PLAYER or side == RIGHT_PLAYER)
      return self.match:getTouches(side)
    end,
    is_ball_valid = function()
      return self.match:isBallValid()
    end,
    is_game_running = function()
      return self.match:isGameRunning()
    end,
    get_serving_player = function()
      return self.match:getServingPlayer()
    end,

    simulate = function(steps, x, y, vx, vy)
      local world = self.dummyWorld
      world.ballPosition = Vector2d(x, 600 - y)
      world.ballVelocity = Vector2d(vx, -vy)

      for i = 0, steps do
        -- set ball valid to false to ignore blobby bounces
        world:update({[LEFT_PLAYER] = PlayerInput(), [RIGHT_PLAYER] = PlayerInput()}, false, true)
      end

      return world.ballPosition.x, 600 - world.ballPosition.y, world.ballVelocity.x, -world.ballVelocity.y
    end,
    simulate_until = function(x, y, vx, vy, axis, coordinate)
      local ival = (axis == "x") and x or y
      if axis ~= "x" and axis ~= "y" then
        error("invalid condition specified: choose either 'x' or 'y'")
      end

      local world = self.dummyWorld
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
    end,
  }

  LuaApiSandbox.load({
    "api/api.lua",
    "api/bot_api.lua",
    "api/bots/" .. filename
  }, self.sandbox)

  print("loaded bot " .. self.sourceFile .. " on side " .. self.side)

  if "function" ~= type(self.sandbox.__OnStep) then
    error("Lua Api Error: Missing bot function __OnStep, check bot_api.lua!")
  end
end

function ScriptedInputSource:getNextInput()
  local serving = false
  -- reset input
  __WANT_LEFT = false
  __WANT_RIGHT = false
  __WANT_JUMP = false

  if nil == self.match then
    return PlayerInput()
  end

  self.sandbox.__OnStep()

  -- if no player is serving player, assume the left one is
  local servingPlayer = self.match:getServingPlayer()
  if servingPlayer == NO_PLAYER then
    servingPlayer = LEFT_PLAYER
  end

  if self.match:isGameRunning() and self.side == servingPlayer then
    serving = true
  end

  local wantleft = self.sandbox.__WANT_LEFT
  local wantright = self.sandbox.__WANT_RIGHT
  local wantjump = self.sandbox.__WANT_JUMP

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

return ScriptedInputSource
