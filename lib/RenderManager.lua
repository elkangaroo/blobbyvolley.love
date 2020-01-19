local RenderManager = {}

RenderManager.showShadow = true
RenderManager.backgroundImage = nil

-- int xResolution, int yResolution, boolean isFullscreen
function RenderManager.init(xResolution, yResolution, isFullscreen)
  -- @todo
end

function RenderManager.draw()
  if RenderManager.backgroundImage then
    love.graphics.draw(RenderManager.backgroundImage, 0, 0)
  end

  -- @todo
end

function RenderManager.refresh()
  -- @todo
end

-- string filename
function RenderManager.setBackground(filename)
  RenderManager.backgroundImage = love.graphics.newImage(filename)
end

-- int player, table<Color> color
function RenderManager.setBlobColor(player, color)
  -- @todo
end

-- boolean showShadow
function RenderManager.showShadow(showShadow)
  RenderManager.showShadow = showShadow
end

return RenderManager
