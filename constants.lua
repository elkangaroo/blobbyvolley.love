-- Enum PlayerSide
NO_PLAYER = -1
LEFT_PLAYER = 0
RIGHT_PLAYER = 1

-- Globals.h
BLOBBY_PORT = 1234
BASE_RESOLUTION_X = 800
BASE_RESOLUTION_Y = 600
ROUND_START_SOUND_VOLUME = 0.2
BALL_HIT_PLAYER_SOUND_VOLUME = 0.4
DEFAULT_RULES_FILE = "default.lua"

-- GameConstants.h
LEFT_PLANE = 0
RIGHT_PLANE = 800
BLOBBY_WIDTH = 75
BLOBBY_HEIGHT = 89
BLOBBY_UPPER_SPHERE = 19
BLOBBY_UPPER_RADIUS = 25
BLOBBY_LOWER_SPHERE = 13
BLOBBY_LOWER_RADIUS = 33
GROUND_PLANE_HEIGHT_MAX = 500
GROUND_PLANE_HEIGHT = GROUND_PLANE_HEIGHT_MAX - BLOBBY_HEIGHT / 2
BLOBBY_MAX_JUMP_HEIGHT = GROUND_PLANE_HEIGHT - 206.375	-- GROUND_Y - MAX_Y
BLOBBY_JUMP_ACCELERATION = -15.1
GRAVITATION = BLOBBY_JUMP_ACCELERATION * BLOBBY_JUMP_ACCELERATION / BLOBBY_MAX_JUMP_HEIGHT
BLOBBY_JUMP_BUFFER = GRAVITATION / 2
BALL_WIDTH = 64
BALL_HEIGHT = 64
BALL_RADIUS = 31.5
BALL_GRAVITATION = 0.287
BALL_COLLISION_VELOCITY = math.sqrt(0.75 * RIGHT_PLANE * BALL_GRAVITATION)
NET_POSITION_X = RIGHT_PLANE / 2
NET_POSITION_Y = 438
NET_RADIUS = 7
-- NET_SPHERE = 154		-- what is the meaning of this value ???????
NET_SPHERE_POSITION = 284
STANDARD_BALL_HEIGHT = 269 + BALL_RADIUS
BLOBBY_SPEED = 4.5 -- BLOBBY_SPEED is necessary to determine the size of the input buffer
STANDARD_BALL_ANGULAR_VELOCITY = 0.1

-- PhysicWorld.cpp
BLOBBY_ANIMATION_SPEED = 0.5

-- GameLogic.cpp
SQUISH_TOLERANCE = 11
FALLBACK_RULES_NAME = "__FALLBACK__"
TEMP_RULES_NAME = "server_rules.lua"

-- RenderManager.h
FONT_WIDTH_NORMAL =	24
FONT_WIDTH_SMALL = 12
LINE_SPACER_NORMAL = 6 -- Extra space between 2 lines in a normal SelectBox.
LINE_SPACER_SMALL = 3 -- Extra space between 2 lines in a small SelectBox.

-- RenderManager.h Text Flags (usable for the RenderManager:drawText() flag parameter)
TF_NORMAL       = 0x00 -- 0 == false (backward compatibility for state modules)
TF_HIGHLIGHT    = 0x01 -- 1 == true (backward compatibility for state modules)
TF_SMALL_FONT   = 0x02 -- Draw a smaller font.
TF_OBFUSCATE    = 0x04 -- Obfuscate the text with asterisks. (for password Editboxes)
TF_ALIGN_LEFT   = 0x00 -- Text aligned left (default)
TF_ALIGN_CENTER = 0x08 -- Text centered
TF_ALIGN_RIGHT  = 0x10 -- Text aligned right
TF_CONCEAL      = 0x20 -- Make the text appear disabled.

-- Binary    Hex
-- 00000000  0x00
-- 00000001  0x01
-- 00000010  0x02
-- 00000100  0x04
-- 00001000  0x08
-- 00010000  0x10
-- 00100000  0x20
-- 01000000  0x40
-- 10000000  0x80

-- ScriptedInputSource.h
WAITING_TIME = 1500 -- The time the bot waits after game start

-- OptionsState.cpp
MAX_BOT_DELAY = 25 -- 25 frames = 0.33s (gamespeed: normal)
