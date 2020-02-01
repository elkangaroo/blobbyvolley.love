local RenderManager = {
  showShadow = true,

  leftBlobPosition = nil,
  leftBlobAnimationState = 0,
  rightBlobPosition = nil,
  rightBlobAnimationState = 0,
  leftBlobColor = nil,
  rightBlobColor = nil,
  ballPosition = nil,
  ballRotation = 0.0,

  backgroundImage = nil,
  blobImages = {},
  blobShadowImages = {},
  ballImages = {},
  ballShadowImage = nil,

  uiCanvas = nil,
  uiFont = nil,
  uiElements = {
    playerScores = {},
    playerNames = {},
    gameTime = "",
  },
}

function RenderManager:init()
  -- string filename
  local function newImageDataWithBlackColorKey(filename)
    local imageData = love.image.newImageData(filename)
    imageData:mapPixel(function(x, y, r, g, b, a)
      if r == 0 and g == 0 and b == 0 then
        a = 0
      end
      return r, g, b, a
    end)

    return imageData
  end

  self.uiCanvas = love.graphics.newCanvas()
  self.uiFont = love.graphics.newImageFont(
    newImageDataWithBlackColorKey("res/gfx/font.bmp"),
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.!()ßÄÖÜ\':;?,/_ -%+Ì'
  )

  self.leftBlobColor = { 1, 0, 0 }
  self.rightBlobColor = { 0, 1, 0 }

  self.ballShadowImage = love.graphics.newImage(newImageDataWithBlackColorKey("res/gfx/schball.bmp"))

  for i = 1, 16 do
    local filename = string.format("res/gfx/ball%02d.bmp", i)
    table.insert(self.ballImages, love.graphics.newImage(newImageDataWithBlackColorKey(filename)))
  end

  for i = 1, 5 do
    local filename = string.format("res/gfx/blobbym%d.bmp", i)
    table.insert(self.blobImages, love.graphics.newImage(newImageDataWithBlackColorKey(filename)))

    local filename = string.format("res/gfx/sch1%d.bmp", i)
    table.insert(self.blobShadowImages, love.graphics.newImage(newImageDataWithBlackColorKey(filename)))
  end

  self.uiElements.playerScores[LEFT_PLAYER] = ""
  self.uiElements.playerScores[RIGHT_PLAYER] = ""
  self.uiElements.playerNames[LEFT_PLAYER] = ""
  self.uiElements.playerNames[RIGHT_PLAYER] = ""
end

function RenderManager:draw()
  love.graphics.setColor(1, 1, 1, 1)

  if self.backgroundImage then
    love.graphics.draw(self.backgroundImage, 0, 0)
  end

  if self.showShadow then
    love.graphics.push("all")

    love.graphics.setBlendMode("alpha", "alphamultiply")
		-- glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		-- draw ball shadow
    local position = self:getShadowPosition(self.ballPosition);
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.draw(self.ballShadowImage, position.x - 64, position.y - 16)

    -- draw left blob shadow
		local position = self:getShadowPosition(self.leftBlobPosition);
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.draw(self.blobShadowImages[(self.leftBlobAnimationState % 5) + 1], position.x - 64, position.y - 16)

    -- draw right blob shadow
    local position = self:getShadowPosition(self.rightBlobPosition);
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.draw(self.blobShadowImages[(self.rightBlobAnimationState % 5) + 1], position.x - 64, position.y - 16)

    love.graphics.pop()
	end

  love.graphics.push("all")

  -- draw ball
  local ballAnimationState = math.floor(self.ballRotation / math.pi / 2 * 16)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.ballImages[(ballAnimationState % 16) + 1], self.ballPosition.x - BALL_WIDTH / 2, self.ballPosition.y - BALL_HEIGHT / 2)

  -- draw left blob
  love.graphics.setColor(self.leftBlobColor)
  love.graphics.draw(self.blobImages[(self.leftBlobAnimationState % 5) + 1], self.leftBlobPosition.x - BLOBBY_WIDTH / 2, self.leftBlobPosition.y - BLOBBY_HEIGHT / 2)

  -- draw right blob
  love.graphics.setColor(self.rightBlobColor)
  love.graphics.draw(self.blobImages[(self.rightBlobAnimationState % 5) + 1], self.rightBlobPosition.x - BLOBBY_WIDTH / 2, self.rightBlobPosition.y - BLOBBY_HEIGHT / 2)

  -- draw ball marker
  local ballMarkerColor = love.timer.getTime() * 1000 % 1000 >= 500 and 1 or 0
  love.graphics.setColor(ballMarkerColor, ballMarkerColor, ballMarkerColor)
  love.graphics.rectangle("fill", self.ballPosition.x, 7.5, 5.0, 5.0)

  love.graphics.pop()
end

function RenderManager:drawUi()
  self.uiCanvas:renderTo(function()
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(RenderManager.uiFont)

    -- draw player scores
    local text = self.uiElements.playerScores[LEFT_PLAYER]
    love.graphics.printf(text, 24, 24, text:len() * FONT_WIDTH_NORMAL, "left")

    local text = self.uiElements.playerScores[RIGHT_PLAYER]
    love.graphics.printf(text, 800 - 24 - text:len() * FONT_WIDTH_NORMAL, 24, text:len() * FONT_WIDTH_NORMAL, "right")

    -- draw player names
    local text = self.uiElements.playerNames[LEFT_PLAYER]
    love.graphics.printf(text:upper(), 12, 550, text:len() * FONT_WIDTH_NORMAL, "left")

    local text = self.uiElements.playerNames[RIGHT_PLAYER]
    love.graphics.printf(text:upper(), 800 - 12 - text:len() * FONT_WIDTH_NORMAL, 550, text:len() * FONT_WIDTH_NORMAL, "right")

    -- draw game clock
    local text = self.uiElements.gameTime
    love.graphics.printf(text, 400 - text:len() * FONT_WIDTH_NORMAL / 2, 24, text:len() * FONT_WIDTH_NORMAL, "center")
  end)

  love.graphics.draw(self.uiCanvas)
end

function RenderManager:refresh()
  -- @todo
end

-- string filename
function RenderManager:setBackground(filename)
  self.backgroundImage = love.graphics.newImage(filename)
end

-- PlayerSide player, table<Color> color
function RenderManager:setBlobColor(player, color)
  if player == LEFT_PLAYER then
    self.leftBlobColor = color
  end

  if player == RIGHT_PLAYER then
    self.rightBlobColor = color
  end
end

-- PlayerSide player, Vector2d position, number animationState
function RenderManager:setBlob(player, position, animationState)
  animationState = math.floor(animationState + 0.5)

  if player == LEFT_PLAYER then
    self.leftBlobPosition = position
    self.leftBlobAnimationState = animationState
  end

  if player == RIGHT_PLAYER then
    self.rightBlobPosition = position
    self.rightBlobAnimationState = animationState
  end
end

-- Vector2d position, number rotation
function RenderManager:setBall(position, rotation)
  self.ballPosition = position
  self.ballRotation = rotation
end

-- PlayerSide player, string name, string score
function RenderManager:setPlayer(player, name, score)
  self.uiElements.playerNames[player] = name
  self.uiElements.playerScores[player] = score
end

-- string time
function RenderManager:setGameTime(time)
  self.uiElements.gameTime = time
end

-- Vector2d position
function RenderManager:getShadowPosition(position)
	return Vector2d(
		position.x + (500.0 - position.y) / 4 + 16.0,
		500.0 - (500.0 - position.y) / 16.0 - 10.0
	)
end

function RenderManager:getOscillationColor()
  local time = love.timer.getTime()

  return {
    (math.sin(time * 1.5) + 1.0) * 128,
    (math.sin(time * 2.5) + 1.0) * 128,
    (math.sin(time * 3.5) + 1.0) * 128,
  }
end

return RenderManager
