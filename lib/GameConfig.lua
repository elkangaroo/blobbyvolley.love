local GameConfig = {
  file = "config.xml", -- file relative to save directory (see https://love2d.org/wiki/love.filesystem)
  values = {}, -- for available values see conf/config.xml
}

function GameConfig.load()
  local contents, errormsg = love.filesystem.read("conf/" .. GameConfig.file)
  if nil == contents then
    error("Game Config Load Error: " .. errormsg)
  end

  local handler = XmlTreeHandler:new()
  local parser = xml2lua.parser(handler)
  parser:parse(contents)
  -- xml2lua.printable(handler.root) -- debug

  for i, p in pairs(handler.root.userconfig.var) do
    GameConfig.values[p._attr.name] = p._attr.value
  end

  print("loaded config " .. GameConfig.file)
end

function GameConfig.save()
  local root = {
    userconfig = {
      var = {}
    }
  }

  for i, p in pairs(GameConfig.values) do
    table.insert(root.userconfig.var, { _attr = { name = i, value = p } })
  end

  local contents = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" .. xml2lua.toXml(root)
  local success, errormsg = love.filesystem.write("conf/" .. GameConfig.file, contents)
  if not success then
    error("Game Config Save Error: " .. errormsg)
  end

  print("saved config " .. GameConfig.file)
  -- print(contents) -- debug
end

-- string name
function GameConfig.get(name)
  return GameConfig.values[name]
end

-- string name
function GameConfig.set(name, value)
  if "boolean" == type(value) then
    GameConfig.values[name] = value and "true" or "false"
  else
    GameConfig.values[name] = value
  end
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
