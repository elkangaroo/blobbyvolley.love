local GameConfig = {}

-- @todo read values from config.xml
GameConfig.values = {
  fullscreen = "false",
  show_shadow = "true",
  global_volume = "1.000000",
  mute = "false",
  scoretowin = "15",
  showfps = "true",
  background = "strand2.bmp",
  language = "en",
  -- rules = "default.lua",
  rules = "__FALLBACK__",

  left_player_human = "true",
  left_player_name = "Left Player",
  left_script_name = "hyp014",
  left_script_strength = "4",
  left_blobby_color_r = "0",
  left_blobby_color_g = "0",
  left_blobby_color_b = "255",
  left_blobby_oscillate = "false",

  right_player_human = "false",
  right_player_name = "Right Player",
  right_script_name = "reduced",
  right_script_strength = "13",
  right_blobby_color_r = "255",
  right_blobby_color_g = "0",
  right_blobby_color_b = "0",
  right_blobby_oscillate = "false",
}

-- string filename
function GameConfig.load(filename)
  -- @todo
end

-- string name
function GameConfig.get(name)
  return GameConfig.values[name]
end

-- string name
function GameConfig.getNumber(name)
  return tonumber(GameConfig.get(name))
end

-- string name
function GameConfig.getBoolean(name)
  return "true" == GameConfig.get(name)
end

return GameConfig
