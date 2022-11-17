-- add external modules to require path
love.filesystem.setRequirePath(
  love.filesystem.getRequirePath()
  .. ";lib/ext/xml2lua/?.lua"
)

-- load external libraries
xml2lua = require("xml2lua")
XmlTreeHandler = require("xmlhandler.tree")

-- load internal libraries
Vector2d = require("lib.Vector2d")
Queue = require("lib.Queue")

GameConfig = require("lib.GameConfig")
GameClock = require("lib.GameClock")
GuiManager = require("lib.GuiManager")
RenderManager = require("lib.RenderManager")
SoundManager = require("lib.SoundManager")

LuaApiSandbox = require("lib.LuaApiSandbox")

State = require("lib.State")
GameState = require("lib.GameState")
LocalGameState = require("lib.LocalGameState")

Match = require("lib.Match")
MatchEvent = require("lib.MatchEvent")

PlayerIdentity = require("lib.PlayerIdentity")
PlayerInput = require("lib.PlayerInput")

PhysicWorld = require("lib.PhysicWorld")

GameLogic = require("lib.GameLogic")
FallbackGameLogic = require("lib.FallbackGameLogic")
ScriptedGameLogic = require("lib.ScriptedGameLogic")

InputSource = require("lib.InputSource")
LocalInputSource = require("lib.LocalInputSource")
ScriptedInputSource = require("lib.ScriptedInputSource")

-- Enum PlayerSide
NO_PLAYER = -1
LEFT_PLAYER = 0
RIGHT_PLAYER = 1

-- Globals.h
BLOBBY_PORT = 1234
BASE_RESOLUTION_X = 800
BASE_RESOLUTION_Y = 600
ROUND_START_SOUND_VOLUME = 0.2
BALL_HIT_PLAYER_SOUND_VOLUME = 0.4
DEFAULT_RULES_FILE = "default.lua"

-- GameConstants.h
LEFT_PLANE = 0
RIGHT_PLANE = 800
BLOBBY_WIDTH = 75
BLOBBY_HEIGHT = 89
BLOBBY_UPPER_SPHERE = 19
BLOBBY_UPPER_RADIUS = 25
BLOBBY_LOWER_SPHERE = 13
BLOBBY_LOWER_RADIUS = 33
GROUND_PLANE_HEIGHT_MAX = 500
GROUND_PLANE_HEIGHT = GROUND_PLANE_HEIGHT_MAX - BLOBBY_HEIGHT / 2
BLOBBY_MAX_JUMP_HEIGHT = GROUND_PLANE_HEIGHT - 206.375	-- GROUND_Y - MAX_Y
BLOBBY_JUMP_ACCELERATION = -15.1
GRAVITATION = BLOBBY_JUMP_ACCELERATION * BLOBBY_JUMP_ACCELERATION / BLOBBY_MAX_JUMP_HEIGHT
BLOBBY_JUMP_BUFFER = GRAVITATION / 2
BALL_WIDTH = 64
BALL_HEIGHT = 64
BALL_RADIUS = 31.5
BALL_GRAVITATION = 0.287
BALL_COLLISION_VELOCITY = math.sqrt(0.75 * RIGHT_PLANE * BALL_GRAVITATION)
NET_POSITION_X = RIGHT_PLANE / 2
NET_POSITION_Y = 438
NET_RADIUS = 7
-- NET_SPHERE = 154		-- what is the meaning of this value ???????
NET_SPHERE_POSITION = 284
STANDARD_BALL_HEIGHT = 269 + BALL_RADIUS
BLOBBY_SPEED = 4.5 -- BLOBBY_SPEED is necessary to determine the size of the input buffer
STANDARD_BALL_ANGULAR_VELOCITY = 0.1

-- PhysicWorld.cpp
BLOBBY_ANIMATION_SPEED = 0.5

-- GameLogic.cpp
SQUISH_TOLERANCE = 11
FALLBACK_RULES_NAME = "__FALLBACK__"
TEMP_RULES_NAME = "server_rules.lua"

-- RenderManager.h
FONT_WIDTH_NORMAL =	24
FONT_WIDTH_SMALL = 12

-- RenderManager.h Text Flags (usable for the RenderManager:drawText() flag parameter)
TF_NORMAL       = 0x00 -- 0 == false (backward compatibility for state modules)
TF_HIGHLIGHT    = 0x01 -- 1 == true (backward compatibility for state modules)
TF_SMALL_FONT   = 0x02 -- Draw a smaller font.
TF_OBFUSCATE    = 0x04 -- Obfuscate the text with asterisks. (for password Editboxes)
TF_ALIGN_LEFT   = 0x00 -- Text aligned left (default)
TF_ALIGN_CENTER = 0x08 -- Text centered
TF_ALIGN_RIGHT  = 0x10 -- Text aligned right

-- ScriptedInputSource.h
WAITING_TIME = 1500 -- The time the bot waits after game start

app = {}
app._VERSION = "0.1.0"
app._MIN_GAME_FPS = 5
app.state = nil
app.accumulator = 0.0
app.tickPeriod = 1 / 75 -- seconds per tick
app.options = {}

function app.timer(dt, func)
  dt = math.min(app.tickPeriod, dt)

  app.accumulator = app.accumulator + dt
  while app.accumulator >= app.tickPeriod do
    app.accumulator = app.accumulator - app.tickPeriod
    
    func()
  end
end

function love.load(arg, unfilteredArg)
  for _, a in pairs(arg) do
    if a == "--headless" then
      app.options.headless = true

      love.errorhandler = function(msg)
        print("--- (T_T) ---")
        print((debug.traceback("Error: " .. tostring(msg), 1):gsub("\n[^\n]+$", "")))

        -- exit with error_code, otherwise program runs endlessly
        love.event.quit(1)
      end
    end
  end

  GameConfig.load("conf/config.xml")

  GuiManager:init()

  if not app.options.headless then
    love.window.setTitle(love.window.getTitle() .. " v" .. app._VERSION)

    RenderManager:init()
    RenderManager.showShadow = GameConfig.getBoolean("show_shadow")
    RenderManager.uiElements.showfps = GameConfig.getBoolean("showfps")

    local bg = "res/gfx/backgrounds/" .. GameConfig.get("background")
    if love.filesystem.getInfo(bg) then
      RenderManager:setBackground(bg)
    end

    if love.mouse.isCursorSupported() then
      love.mouse.setCursor(RenderManager.uiCursor)
    end
  end

  SoundManager.isMuted = GameConfig.getBoolean("mute")
  SoundManager.setGlobalVolume(GameConfig.getNumber("global_volume"))
  SoundManager.loadSound("res/sfx/bums.wav")
  SoundManager.loadSound("res/sfx/pfiff.wav")

  app.tickPeriod = 1 / math.max(app._MIN_GAME_FPS, GameConfig.getNumber("gamefps"))

  app.state = State()
end

function love.update(dt)
  app.state:update(dt)

  if app.options.headless then
    love.event.quit()
  end
end

function love.draw()
  RenderManager:draw()
  RenderManager:drawUi()
end

function love.focus(focused)

end

function love.quit()

end

function love.keypressed(key, scancode, isrepeat)
  app.state:keypressed(key)
end

function love.keyreleased(key, scancode)
  app.state:keyreleased(key)
end
