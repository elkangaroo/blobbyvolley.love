local LuaApiSandbox = {}

-- string filename
local function read(filename)
  local ending = ".lua"
  if filename:sub(-#ending) ~= ending then
    filename = filename .. ending
  end

  local contents, errormsg = love.filesystem.read(filename)
  if nil == contents then
    error("Lua Api Error: " .. errormsg)
  end

  return contents
end

-- table filenames, table sandbox_env
function LuaApiSandbox.load(filenames, sandbox_env)
  local sandbox_constants = {
    CONST_FIELD_WIDTH = RIGHT_PLANE,
    CONST_GROUND_HEIGHT = 600 - GROUND_PLANE_HEIGHT_MAX,
    CONST_BALL_GRAVITY = -BALL_GRAVITATION,
    CONST_BALL_RADIUS = BALL_RADIUS,
    CONST_BLOBBY_JUMP = -BLOBBY_JUMP_ACCELERATION,
    CONST_BLOBBY_BODY_RADIUS = BLOBBY_LOWER_RADIUS,
    CONST_BLOBBY_HEAD_RADIUS = BLOBBY_UPPER_RADIUS,
    CONST_BLOBBY_HEAD_OFFSET = BLOBBY_UPPER_SPHERE,
    CONST_BLOBBY_BODY_OFFSET = -BLOBBY_LOWER_SPHERE,
    CONST_BALL_HITSPEED = BALL_COLLISION_VELOCITY,
    CONST_BLOBBY_HEIGHT = BLOBBY_HEIGHT,
    CONST_BLOBBY_GRAVITY = -GRAVITATION,
    CONST_BLOBBY_SPEED = BLOBBY_SPEED,
    CONST_NET_HEIGHT = 600 - NET_SPHERE_POSITION,
    CONST_NET_RADIUS = NET_RADIUS,
    NO_PLAYER = NO_PLAYER,
    LEFT_PLAYER = LEFT_PLAYER,
    RIGHT_PLAYER = RIGHT_PLAYER,
  }

  local sandbox_functions = {
    assert = assert,
    error = error,
    ipairs = ipairs,
    math = math, -- UNSAFE, better expose needed math.* functions only
    pairs = pairs,
    print = print,
  }

  for k, v in pairs(sandbox_constants) do sandbox_env[k] = v end
  for k, v in pairs(sandbox_functions) do sandbox_env[k] = v end

  local contents = ""
  for key, filename in ipairs(filenames) do
    contents = contents .. "\n" .. read(filename)
  end

  local chunk, errormsg = load(contents, "sandbox", "t", sandbox_env)
  if nil == chunk then
    error("Lua Api Error: " .. errormsg)
  end

  chunk()
end

return LuaApiSandbox
