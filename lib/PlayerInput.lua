local PlayerInput = {}
PlayerInput.__index = PlayerInput

setmetatable(PlayerInput, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

-- boolean left, boolean right, boolean up
function PlayerInput:__construct(left, right, up)
  self.left = left or false
  self.right = right or false
  self.up = up or false
end

return PlayerInput
