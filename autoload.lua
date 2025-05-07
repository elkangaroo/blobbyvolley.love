-- add external modules to require path
love.filesystem.setRequirePath(
  love.filesystem.getRequirePath()
  .. ";lib/ext/xml2lua/?.lua"
)

-- load external libraries
xml2lua = require("xml2lua")
XmlTreeHandler = require("xmlhandler.tree")

-- load internal libraries
Vector2d = require("lib.Vector2d")
Queue = require("lib.Queue")

GameConfig = require("lib.GameConfig")
GameClock = require("lib.GameClock")
GuiManager = require("lib.GuiManager")
RenderManager = require("lib.RenderManager")
SoundManager = require("lib.SoundManager")

LuaApiSandbox = require("lib.LuaApiSandbox")

State = require("lib.states.State")
MainMenuState = require("lib.states.MainMenuState")
OptionsMenuState = require("lib.states.OptionsMenuState")
MiscOptionsMenuState = require("lib.states.MiscOptionsMenuState")
GraphicOptionsMenuState = require("lib.states.GraphicOptionsMenuState")
GameState = require("lib.states.GameState")
LocalGameState = require("lib.states.LocalGameState")

Match = require("lib.Match")
MatchEvent = require("lib.MatchEvent")
MatchState = require("lib.MatchState")

PlayerIdentity = require("lib.PlayerIdentity")
PlayerInput = require("lib.PlayerInput")

PhysicWorld = require("lib.PhysicWorld")

GameLogic = require("lib.GameLogic")
FallbackGameLogic = require("lib.FallbackGameLogic")
ScriptedGameLogic = require("lib.ScriptedGameLogic")

InputSource = require("lib.InputSource")
LocalInputSource = require("lib.LocalInputSource")
ScriptedInputSource = require("lib.ScriptedInputSource")
