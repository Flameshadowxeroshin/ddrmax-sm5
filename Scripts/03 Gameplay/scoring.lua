--This is a kinda weird implementation of MAX scoring, based ultimately on,
--once again, something at Aaron in Japan
--it might be more accurate to say, maybe, that this is a close relative 
--http://aaronin.jp/ddrssystem.html#ss5
MAXScoring = {}

local max_score= 50000000

local function FindPoints(numObjects)
	return numObjects*(1+numObjects)
end

local value_lut = 
{
	TapNoteScore_W1 = 2,
	TapNoteScore_W2 = 2,
	TapNoteScore_W3 = 1	
}

function MAXScoring.MakeScoring(steps, pn)
	local state = {}
	local raw_maxpoints = FindPoints(steps:GetRadarValues(pn)
		:GetValue('RadarCategory_TapsAndHolds'))

	local tns_history = {
		TapNoteScore_W1 = 0,
		TapNoteScore_W2 = 0,
		TapNoteScore_W3 = 0,
		TapNoteScore_W4 = 0,
		TapNoteScore_W5 = 0,
		TapNoteScore_Miss = 0
	}

	local obj_counter = 0
	local raw_curscore = 0

	local function update()
		local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
		for tns, value in pairs(tns_history) do
			local new_value = pss:GetTapNoteScores(tns)
			if new_value > value then
				local difference = new_value - value
				for i=1, difference do
					obj_counter = obj_counter + 1
					raw_curscore = raw_curscore + (value_lut[tns] or 0)*obj_counter
				end
			end
		end
	end

	state.GetCurrentScoreAndMaxScore =
	function(exact)
		update()
		local out_score = (raw_curscore / raw_maxpoints ) * max_score
		local out_maxscore = ( FindPoints(obj_counter) / raw_maxpoints ) * max_score
		if not exact then
			return math.floor(out_score), math.floor(out_maxscore)
		end
		return out_score, out_maxscore
	end

	state.GetBonus

end