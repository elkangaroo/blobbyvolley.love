local SoundManager = {
  isMuted = true,
  sources = {},
}

function SoundManager:init()
  SoundManager:loadSound("res/sfx/bums.wav")
  SoundManager:loadSound("res/sfx/pfiff.wav")
end

-- number volume
function SoundManager:setGlobalVolume(volume)
  love.audio.setVolume(volume)
end

-- string filename
function SoundManager:loadSound(filename)
  if not self.sources[filename] then
    self.sources[filename] = love.audio.newSource(filename, "static")
  end
end

-- string filename, number volume
function SoundManager:playSound(filename, volume)
  if self.isMuted then
    return
  end

  if not self.sources[filename] then
    self:loadSound(filename)
  end

  self.sources[filename]:setVolume(volume)
  love.audio.play(self.sources[filename])
end

return SoundManager
