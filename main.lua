GameConfig = require("lib.GameConfig")
RenderManager = require("lib.RenderManager")
SoundManager = require("lib.SoundManager")

State = require("lib.State")
GameState = require("lib.GameState")
LocalGameState = require("lib.LocalGameState")
DuelMatch = require("lib.DuelMatch")

BASE_RESOLUTION_X = 800
BASE_RESOLUTION_Y = 600

ROUND_START_SOUND_VOLUME = 0.2
BALL_HIT_PLAYER_SOUND_VOLUME = 0.4

NO_PLAYER = -1
LEFT_PLAYER = 0
RIGHT_PLAYER = 1

local app = {}
app.version = 0.1

function love.load(...)
  print("starting load")

  GameConfig.load("conf/config.xml")

  RenderManager.init(BASE_RESOLUTION_X, BASE_RESOLUTION_Y, "true" == GameConfig.get("fullscreen"))
  RenderManager.showShadow("true" == GameConfig.get("show_shadow"))

  SoundManager.setGlobalVolume(GameConfig.get("global_volume"))
  SoundManager.setIsMuted("true" == GameConfig.get("mute"))
  SoundManager.loadSound("res/sfx/bums.wav")
  SoundManager.loadSound("res/sfx/pfiff.wav")

  local bg = "res/gfx/backgrounds/" .. GameConfig.get("background")
  if love.filesystem.getInfo(bg) then
    print("setting background " .. bg)
   	RenderManager.setBackground(bg)
  end

  app.state = State()

  print("starting mainloop")
end

function love.update(dt)
  app.state:step()
end

function love.draw()
  love.graphics.setColor(1, 1, 1)

  RenderManager.draw()
  RenderManager.refresh()

  if "true" == GameConfig.get("showfps") then
    love.graphics.setColor(0.3, 0.9, 1)
    love.graphics.print(string.format('v%s FPS: %s', app.version, love.timer.getFPS()), 2, 2)
  end
end

function love.focus(focused)

end

function love.quit()

end

function love.keypressed(key, scancode, isrepeat)

end

function love.keyreleased(key, scancode)

end
