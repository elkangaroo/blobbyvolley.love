__AUTHOR__ = "elkangaroo"
__TITLE__  = "BV2 Headless Rules"
SCORE_TO_WIN = 2

function IsWinning(lscore, rscore) 
	if lscore >= SCORE_TO_WIN then
		return true
	end
	if rscore >= SCORE_TO_WIN then
		return true
	end
	return false
end
