-- lua 5.1 compatibility
if not table.unpack then
    table.unpack = unpack
end

require("autoload")
require("constants")

app = {}
app._VERSION = "0.1.0"
app._MIN_GAME_FPS = 5
app.state = State()
app.accumulator = 0.0
app.tickPeriod = 1 / 75 -- seconds per tick
app.options = {
  headless = false,
}

function app.timer(dt, func)
  dt = math.min(app.tickPeriod, dt)

  app.accumulator = app.accumulator + dt
  while app.accumulator >= app.tickPeriod do
    app.accumulator = app.accumulator - app.tickPeriod

    func()
  end
end

function app.initConfig()
  RenderManager.showShadow = GameConfig.getBoolean("show_shadow")
  RenderManager.uiElements.showfps = GameConfig.getBoolean("showfps")

  local bg = "res/gfx/backgrounds/" .. GameConfig.get("background")
  if love.filesystem.getInfo(bg) then
    RenderManager:setBackground(bg)
  end

  SoundManager.isMuted = GameConfig.getBoolean("mute")
  SoundManager:setGlobalVolume(GameConfig.getNumber("global_volume"))

  app.tickPeriod = 1 / math.max(app._MIN_GAME_FPS, GameConfig.getNumber("gamefps"))
end

function love.load(arg, unfilteredArg)
  -- process cli options
  for _, a in pairs(arg) do
    print(a) -- debug

    if a == "--headless" then
      app.options.headless = true

      love.errorhandler = function(msg)
        print("--- (T_T) ---")
        print((debug.traceback("Error: " .. tostring(msg), 1):gsub("\n[^\n]+$", "")))

        -- exit with error_code, otherwise program runs endlessly
        love.event.quit(1)
      end
    end

    if a:match('^--config=(.+)$') then
      GameConfig.file = a:match('^--config=(.+)$')
    end
  end

  GameConfig.load()

  if app.options.headless then
    app.state:switchState(LocalGameState())

    return
  end

  love.window.setTitle(love.window.getTitle() .. " v" .. app._VERSION)
  love.keyboard.setKeyRepeat(true)

  GuiManager:init()
  RenderManager:init()
  SoundManager:init()

  if love.mouse.isCursorSupported() then
    love.mouse.setCursor(RenderManager.uiCursor)
  end

  app.initConfig()
end

function love.update(dt)
  app.state:update(dt)
end

function love.draw()
  app.state:draw()
end

function love.focus(focused)

end

function love.quit()
  print("good bye.")
end

function love.keypressed(key, scancode, isrepeat)
  app.state:keypressed(key)
end

function love.keyreleased(key, scancode)
  app.state:keyreleased(key)
end

function love.textinput(text)
  app.state:textinput(text)
end
