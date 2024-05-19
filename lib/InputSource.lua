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
end

function InputSource:getNextInput()
  return PlayerInput()
end

function InputSource:updateInput()
	return self:getNextInput()
end

return InputSource
