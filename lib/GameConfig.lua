local GameConfig = {}

-- @todo read values from config.xml
GameConfig.values = {
  fullscreen = "false",
  show_shadow = "false",
  global_volume = "1.000000",
  mute = "false",
  scoretowin = "15",
  showfps = "true",
  background = "strand2.bmp",
  language = "en",
  rules = "default.lua",
}

-- string filename
function GameConfig.load(filename)
  -- @todo
end

-- string name
function GameConfig.get(name)
  return GameConfig.values[name]
end

return GameConfig
