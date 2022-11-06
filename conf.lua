function love.conf(t)
  t.version = "11.3"
  t.identity = "blobby_volley_love" -- name of the save directory
  t.console = false
  t.window.title = "Blobby Volley: LÖVE Edition"
  t.window.width = 800
  t.window.height = 600

  for _, a in pairs(arg) do
    -- headless mode for automated testing
    if a == "--headless" then
      t.modules.window, t.modules.graphics = false, false
    end
  end
end
