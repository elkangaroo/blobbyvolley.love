local SoundManager = {}

SoundManager.isMuted = false
SoundManager.sources = {}

-- number volume
function SoundManager.setGlobalVolume(volume)
  love.audio.setVolume(volume)
end

-- boolean isMuted
function SoundManager.setIsMuted(isMuted)
  SoundManager.isMuted = isMuted
end

-- string filename
function SoundManager.loadSound(filename)
  if not SoundManager.sources[filename] then
    SoundManager.sources[filename] = love.audio.newSource(filename, "static")
  end
end

-- string filename, number volume
function SoundManager.playSound(filename, volume)
  if SoundManager.isMuted then
    return
  end

  if not SoundManager.sources[filename] then
    SoundManager.loadSound(filename)
  end

  SoundManager.sources[filename]:setVolume(volume)
  love.audio.play(SoundManager.sources[filename])
end

return SoundManager
