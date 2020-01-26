local LocalInputSource = {}
LocalInputSource.__index = LocalInputSource

setmetatable(LocalInputSource, {
  __index = InputSource, -- base class
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

function LocalInputSource:__construct()
  InputSource:__construct()
  self.rawInput = PlayerInput()
end

-- string key, boolean value
function LocalInputSource:set(key, value)
  self.rawInput[key] = value
end

function LocalInputSource:getNextInput()
  return self.rawInput
end

return LocalInputSource
