local LocalGameState = {}
LocalGameState.__index = LocalGameState

setmetatable(LocalGameState, {
  __index = GameState, -- base class
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

function LocalGameState:__construct()
  -- reset match
  local match = Match(false, GameConfig.get("rules"))

  local leftPlayer = PlayerIdentity.createFromConfig(LEFT_PLAYER, false)
  local rightPlayer = PlayerIdentity.createFromConfig(RIGHT_PLAYER, false)
  local leftInput = self:createInputSource(LEFT_PLAYER, match)
  local rightInput = self:createInputSource(RIGHT_PLAYER, match)

  match:setPlayers(leftPlayer, rightPlayer)
  match:setInputSources(leftInput, rightInput)
  match:addEvent(MatchEvent.ROUND_START, NO_PLAYER)

  GameState.__construct(self, match)
  self.winner = false
end

-- PlayerSide side, Match match
function LocalGameState:createInputSource(side, match)
  local prefix = (side == LEFT_PLAYER) and "left" or "right"

  if GameConfig.getBoolean(prefix .. "_player_human") then
    return LocalInputSource()
  else
    local scriptName = GameConfig.get(prefix .. "_script_name")
    local scriptStrength = GameConfig.getNumber(prefix .. "_script_strength")
    return ScriptedInputSource(scriptName, side, scriptStrength, match)
  end
end

function LocalGameState:update(dt)
  if self.match.isPaused then
    love.mouse.setVisible(true)
    self:displayQueryPrompt(
      200,
      "really quit?",
      { "yes", function()
        -- app.state:switchState(MainMenuState())

        -- just exit game until we have MainMenuState :)
        love.event.quit()
      end },
      { "no", function()
        self.match:unpause()
      end }
    )
  elseif self.winner then
    love.mouse.setVisible(true)
    -- self:displayWinningPlayerScreen(match:getWinningPlayer())
    GuiManager:addOverlay(Vector2d(200, 150), Vector2d(700, 450))
    GuiManager:addImage(Vector2d(120, 70), "res/gfx/pokal.bmp")
    local winnerName = self.match:getPlayer(self.match:getWinningPlayer()).name
    GuiManager:addText(Vector2d(274, 240), winnerName)
    GuiManager:addText(Vector2d(274, 300), "has won the game!")
    if GuiManager:addButton(Vector2d(290, 350), "ok") then
      -- app.state:switchState(MainMenuState())

      -- just exit game until we have MainMenuState :)
      love.event.quit()
    end
    if GuiManager:addButton(Vector2d(400, 350), "try again") then
      app.state:switchState(LocalGameState())
    end
  else
    love.mouse.setVisible(false)
    self.match:update(dt)

    if self.match:getWinningPlayer() ~= NO_PLAYER then
      self.winner = true

      print("match winner: player " .. self.match:getWinningPlayer())
      print("match score: " .. self.match:getScore(LEFT_PLAYER) .. ":" .. self.match:getScore(RIGHT_PLAYER))

      if app.options.headless then
        love.event.quit()
      end
    end

    self:presentGame()
  end

  self:presentGameUi()
  self.match:resetEvents()
end

-- KeyConstant key
function LocalGameState:keypressed(key)
  if GameConfig.getBoolean("left_player_human") then
    if ("a" == key) then self.match.inputSources[LEFT_PLAYER]:set("left", true) end
    if ("d" == key) then self.match.inputSources[LEFT_PLAYER]:set("right", true) end
    if ("w" == key) then self.match.inputSources[LEFT_PLAYER]:set("up", true) end
  end

  if GameConfig.getBoolean("right_player_human") then
    if ("left" == key) then self.match.inputSources[RIGHT_PLAYER]:set("left", true) end
    if ("right" == key) then self.match.inputSources[RIGHT_PLAYER]:set("right", true) end
    if ("up" == key) then self.match.inputSources[RIGHT_PLAYER]:set("up", true) end
  end

  if "escape" == key then
    if self.match.isPaused then
      self.match:unpause()
    else
      self.match:pause()
    end
  end
end

-- KeyConstant key
function LocalGameState:keyreleased(key)
  if GameConfig.getBoolean("left_player_human") then
    if ("a" == key) then self.match.inputSources[LEFT_PLAYER]:set("left", false) end
    if ("d" == key) then self.match.inputSources[LEFT_PLAYER]:set("right", false) end
    if ("w" == key) then self.match.inputSources[LEFT_PLAYER]:set("up", false) end
  end

  if GameConfig.getBoolean("right_player_human") then
    if ("left" == key) then self.match.inputSources[RIGHT_PLAYER]:set("left", false) end
    if ("right" == key) then self.match.inputSources[RIGHT_PLAYER]:set("right", false) end
    if ("up" == key) then self.match.inputSources[RIGHT_PLAYER]:set("up", false) end
  end
end

function LocalGameState:getStateName()
  return "LocalGameState"
end

return LocalGameState
