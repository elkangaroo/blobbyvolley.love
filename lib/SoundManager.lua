local SoundManager = {
  isMuted = true,
  sources = {},
}

-- number volume
function SoundManager.setGlobalVolume(volume)
  love.audio.setVolume(volume)
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
