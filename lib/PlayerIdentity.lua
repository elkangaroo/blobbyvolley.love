local PlayerIdentity = {}
PlayerIdentity.__index = PlayerIdentity

setmetatable(PlayerIdentity, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

-- string name, table<Color> color, boolean isOscillating, PlayerSide side
function PlayerIdentity:__construct(name, color, isOscillating, side)
  self.name = name
  self.staticColor = color or { 0, 0, 0 }
  self.isOscillating = isOscillating or false
  self.preferredSide = side or RIGHT_PLAYER
end

-- PlayerSide side, boolean forceHuman
function PlayerIdentity.createFromConfig(side, forceHuman)
  local prefix = (side == LEFT_PLAYER) and "left" or "right"

  local name = ""
	if forceHuman or GameConfig.getBoolean(prefix .. "_player_human") then
		name = GameConfig.get(prefix .. "_player_name")
	else
		name = GameConfig.get(prefix .. "_script_name") .. ".lua"
	end

  local color = {
    GameConfig.getNumber(prefix .. "_blobby_color_r") / 255,
    GameConfig.getNumber(prefix .. "_blobby_color_g") / 255,
    GameConfig.getNumber(prefix .. "_blobby_color_b") / 255,
  }

	-- isOscillating = GameConfig.getBoolean(prefix .. "_blobby_oscillate")
	-- preferredSide = GameConfig.get("network_side")

	return PlayerIdentity(name, color)
end

return PlayerIdentity
