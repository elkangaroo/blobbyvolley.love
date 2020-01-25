local GameClock = {
  isRunning = false,
  gameTime = 0,
  lastTime = 0,
}

function GameClock:reset()
	GameClock.isRunning = false
	GameClock.gameTime = 0
	GameClock.lastTime = love.timer.getTime()
end

function GameClock:start()
	GameClock.lastTime = love.timer.getTime()
	GameClock.isRunning = true
end

function GameClock:stop()
	GameClock.isRunning = false
end

function GameClock:getTimeString()
	-- calculate seconds, minutes and hours
  local time = math.floor(GameClock.gameTime + 0.5)
	local seconds = time % 60
	local minutes = ((time - seconds) / 60) % 60
	local hours = ((time - 60 * minutes - seconds) / 3600) % 60

	if minutes < 10 then
		minutes = "0" .. minutes
  end

	if seconds < 10 then
		seconds = "0" .. seconds
  end

	return (hours > 0 and hours .. ":" or "") .. minutes .. ":" .. seconds
end

function GameClock:update()
	if GameClock.isRunning then
		local newTime = love.timer.getTime()
		if newTime > GameClock.lastTime then
			GameClock.gameTime = GameClock.gameTime + newTime - GameClock.lastTime
		end

		GameClock.lastTime = newTime
	end
end

return GameClock
