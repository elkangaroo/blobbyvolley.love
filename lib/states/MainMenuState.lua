local MainMenuState = {}
MainMenuState.__index = MainMenuState

setmetatable(MainMenuState, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

function MainMenuState:__construct()
  love.mouse.setVisible(true)
end

function MainMenuState:update(dt)
  GuiManager:addImage(Vector2d(0, 0), "res/gfx/backgrounds/strand2.bmp")
  GuiManager:addOverlay(Vector2d(0, 0), Vector2d(800, 600))
  GuiManager:addImage(Vector2d(187, 52), "res/gfx/titel2.bmp")

  -- if GuiManager:addButton(Vector2d(34, 300), "online game") then
  --   app.state:switchState(OnlineSearchState())
  -- end

  -- if GuiManager:addButton(Vector2d(34, 340), "lan game") then
  --   app.state:switchState(LANSearchState())
  -- end

  if GuiManager:addButton(Vector2d(34, 380), "start") then
    app.state:switchState(LocalGameState())
  end

  -- if GuiManager:addButton(Vector2d(34, 420), "options") then
  --   app.state:switchState(OptionState())
  -- end

  -- if GuiManager:addButton(Vector2d(34, 460), "watch replay") then
  --   app.state:switchState(ReplaySelectionState())
  -- end

  -- if GuiManager:addButton(Vector2d(34, 500), "credits") then
  --   app.state:switchState(CreditsState())
  -- end

  if GuiManager:addButton(Vector2d(34, 540), "exit") then
    love.event.quit()
  end
end

function MainMenuState:draw()
  GuiManager:draw()
end

-- KeyConstant key
function MainMenuState:keypressed(key)
end

-- KeyConstant key
function MainMenuState:keyreleased(key)
end

function MainMenuState:getStateName()
  return "MainMenuState"
end

return MainMenuState
