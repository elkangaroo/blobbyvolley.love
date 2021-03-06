local InputSource = {}
InputSource.__index = InputSource

setmetatable(InputSource, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

function InputSource:__construct()
  self.match = nil
end

function InputSource:getNextInput()
  return PlayerInput()
end

function InputSource:updateInput()
	return self:getNextInput()
end

-- PlayerSide side
function InputSource.createInputSource(side)
  local prefix = (side == LEFT_PLAYER) and "left" or "right"

	if GameConfig.getBoolean(prefix .. "_player_human") then
		return LocalInputSource()
	else
		return ScriptedInputSource(GameConfig.get(prefix .. "_script_name"), side, GameConfig.getNumber(prefix .. "_script_strength"))
	end
end

return InputSource
