local RenderManager = {
  showShadow = true,
  backgroundImage = nil,
  leftBlobPosition = nil,
  leftBlobAnimationState = 0,
  rightBlobPosition = nil,
  rightBlobAnimationState = 0,
  leftBlobColor = nil,
  rightBlobColor = nil,
  ballPosition = nil,
  ballRotation = 0.0,
  ballImages = {},
  blobImages = {},
  uiCanvas = nil,
  uiFont = nil,
}

-- int xResolution, int yResolution, boolean isFullscreen
function RenderManager:init(xResolution, yResolution, isFullscreen)
  self.uiCanvas = love.graphics.newCanvas()
  self.uiFont = love.graphics.newImageFont("res/gfx/font.bmp", '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.!()ßÄÖÜ\':;?,/_ -%+Ì')

  self.leftBlobColor = { 1, 0, 0 }
  self.rightBlobColor = { 0, 1, 0 }

  for i = 1, 16 do
    filename = string.format("res/gfx/ball%02d.bmp", i)
    imageData = love.image.newImageData(filename)
    imageData:mapPixel(function(x, y, r, g, b, a)
      if r == 0 and g == 0 and b == 0 then
        a = 0
      end
      return r, g, b, a
    end)
    table.insert(self.ballImages, love.graphics.newImage(imageData))
  end

  for i = 1, 5 do
    filename = string.format("res/gfx/blobbym%d.bmp", i)
    imageData = love.image.newImageData(filename)
    imageData:mapPixel(function(x, y, r, g, b, a)
      if r == 0 and g == 0 and b == 0 then
        a = 0
      end
      return r, g, b, a
    end)
    table.insert(self.blobImages, love.graphics.newImage(imageData))

    -- filename = string.format("res/gfx/blobbym%d.bmp", i)
    -- image = love.graphics.newImage(filename)
    -- GLuint blobSpecular = loadTexture(loadSurface(filename), true)
    -- mBlobSpecular.push_back(blobSpecular)
    --
    -- filename = string.format("res/gfx/sch1%d.bmp", i)
    -- image = love.graphics.newImage(filename)
    -- GLuint blobShadow = loadTexture(loadSurface(filename), false)
    -- mBlobShadow.push_back(blobShadow)
  end
end

function RenderManager:draw()
  if self.backgroundImage then
    love.graphics.draw(self.backgroundImage, 0, 0)
  end

  -- draw ball
  ballAnimationState = math.floor(self.ballRotation / math.pi / 2 * 16)
  love.graphics.draw(self.ballImages[(ballAnimationState % 16) + 1], self.ballPosition.x, self.ballPosition.y)

  -- draw left blob
  -- glColor3ubv(self.leftBlobColor) -- @todo color
  love.graphics.draw(self.blobImages[(self.leftBlobAnimationState % 5) + 1], self.leftBlobPosition.x, self.leftBlobPosition.y)

  -- draw right blob
  -- glColor3ubv(self.rightBlobColor) -- @todo color
  love.graphics.draw(self.blobImages[(self.rightBlobAnimationState % 5) + 1], self.rightBlobPosition.x, self.rightBlobPosition.y)
end

function RenderManager:updateUi(callback)
  self.uiCanvas:renderTo(callback)
end

function RenderManager:drawUi()
  -- important: reset color before drawing to canvas to have colors properly displayed
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.uiCanvas)
end

function RenderManager:refresh()
  -- @todo
end

-- string filename
function RenderManager:setBackground(filename)
  self.backgroundImage = love.graphics.newImage(filename)
end

-- int player, table<Color> color
function RenderManager:setBlobColor(player, color)
  if player == LEFT_PLAYER then
    self.leftBlobColor = color
  end

  if player == RIGHT_PLAYER then
    self.rightBlobColor = color
  end
end

-- number player, Vector2d position, number animationState
function RenderManager:setBlob(player, position, animationState)
  if player == LEFT_PLAYER then
    self.leftBlobPosition = position
    self.leftBlobAnimationState = math.floor(animationState)
  end

  if player == RIGHT_PLAYER then
    self.rightBlobPosition = position
    self.rightBlobAnimationState = math.floor(animationState)
  end
end

-- Vector2d position, number rotation
function RenderManager:setBall(position, rotation)
  self.ballPosition = position
  self.ballRotation = rotation
end

function RenderManager:getOscillationColor()
  -- time = float(SDL_GetTicks()) / 1000.0
  time = 1

  return {
    (math.sin(time * 1.5) + 1.0) * 128,
    (math.sin(time * 2.5) + 1.0) * 128,
    (math.sin(time * 3.5) + 1.0) * 128,
  }
end

return RenderManager
