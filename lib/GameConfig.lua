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
  -- rules = "default.lua",
  rules = "__FALLBACK__",

  left_player_human = "true",
  left_player_name = "Left Player",
  left_script_name = "hyp014",
  left_blobby_color_r = "0",
  left_blobby_color_g = "0",
  left_blobby_color_b = "255",
  left_blobby_oscillate = "false",

  right_player_human = "true",
  right_player_name = "Right Player",
  right_script_name = "reduced",
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

return GameConfig
