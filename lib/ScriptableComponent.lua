local ScriptableComponent = {}

-- string filename
function ScriptableComponent:openScript(filename)
  local ending = ".lua"
  if filename:sub(-#ending) ~= ending then
    filename = filename .. ending
  end

  local chunk, errormsg = love.filesystem.load(filename)
  if errormsg then
    self:handleScriptError(errormsg)
  end

  chunk()
end

-- string errormsg
function ScriptableComponent:handleScriptError(errormsg)
  error("Lua Bot Error: " .. errormsg)
end

-- table component
function ScriptableComponent:setComponentPointer(component)
  __SCRIPTABLE_COMPONENT_POINTER = component
end

-- used in ScriptedInputSource and ScriptedGameLogic
function ScriptableComponent:getMatch()
  return __SCRIPTABLE_COMPONENT_POINTER.match
end


--
-- common functions for lua api
--


function get_ball_pos()
  local vector = ScriptableComponent:getMatch():getBallPosition()
	return vector.x, 600 - vector.y
end

function get_ball_vel()
  local vector = ScriptableComponent:getMatch():getBallVelocity()
	return vector.x, -vector.y
end

function get_blob_pos(side)
	assert(side == LEFT_PLAYER or side == RIGHT_PLAYER)
  local vector = ScriptableComponent:getMatch():getBlobPosition(side)
  return vector.x, 600 - vector.y
end

function get_blob_vel(side)
  assert(side == LEFT_PLAYER or side == RIGHT_PLAYER)
  local vector = ScriptableComponent:getMatch():getBlobVelocity(side)
  return vector.x, -vector.y
end

function get_score(side)
  assert(side == LEFT_PLAYER or side == RIGHT_PLAYER)
  return ScriptableComponent:getMatch():getScore(side)
end

function get_touches(side)
  assert(side == LEFT_PLAYER or side == RIGHT_PLAYER)
  return ScriptableComponent:getMatch():getTouches(side)
end

function is_ball_valid()
  return ScriptableComponent:getMatch():isBallValid()
end

function is_game_running()
  return ScriptableComponent:getMatch():isGameRunning()
end

function get_serving_player()
  return ScriptableComponent:getMatch():getServingPlayer()
end

return ScriptableComponent
