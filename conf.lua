function love.conf(t)
  t.version = "11.5"
  t.identity = "blobby_volley_love" -- name of the save directory
  t.console = false
  t.window.title = "Blobby Volley: LÖVE Edition"
  t.window.width = 800
  t.window.height = 600
  t.window.vsync = 0

  for _, a in pairs(arg) do
    -- headless mode for automated testing
    if a == "--headless" then
      t.modules.window, t.modules.graphics, t.modules.audio = false, false, false
    end
  end

  -- unbuffered console output
  io.stdout:setvbuf('no')
end
