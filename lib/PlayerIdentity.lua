local PlayerIdentity = {}
PlayerIdentity.__index = PlayerIdentity

setmetatable(PlayerIdentity, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

-- string name
function PlayerIdentity:__construct(name)
  self.name = name
  self.staticColor = { 0, 0, 0 }
  self.isOscillating = false
  self.preferredSide = RIGHT_PLAYER
end

return PlayerIdentity
