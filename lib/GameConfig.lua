local GameConfig = {
  values = {}, -- for available values see conf/config.xml
}

-- string filename
function GameConfig.load(filename)
  local contents, errormsg = love.filesystem.read(filename)
  if nil == contents then
    error("Game Config Error: " .. errormsg)
  end

  local handler = XmlTreeHandler:new()
  local parser = xml2lua.parser(handler)
  parser:parse(contents)
  -- xml2lua.printable(handler.root) -- debug

  for i, p in pairs(handler.root.userconfig.var) do
    GameConfig.values[p._attr.name] = p._attr.value
  end

  print("loaded config " .. filename)
end

-- string name
function GameConfig.get(name)
  return GameConfig.values[name]
end

-- string name
function GameConfig.getNumber(name)
  return tonumber(GameConfig.get(name))
end

-- string name
function GameConfig.getBoolean(name)
  return "true" == GameConfig.get(name)
end

return GameConfig
