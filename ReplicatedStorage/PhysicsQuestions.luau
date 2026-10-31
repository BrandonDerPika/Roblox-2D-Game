local PhysicsQuestions = {}

local problems = {
	{
		question = "A car accelerates uniformly from rest to 20 m/s in 5 seconds. What is its acceleration (m/s^2)?",
		answer = "4"
	},
	{
		question = "An object moves at 10 m/s for 3 seconds. How far does it travel (m)?",
		answer = "30"
	},
	{
		question = "A ball is dropped from rest and falls for 2 seconds (g=9.8 m/s^2). What is its velocity at that time (m/s)?",
		answer = "19.6"
	},
	{
		question = "A runner accelerates at 2 m/s^2 for 4 seconds starting from rest. What distance does the runner cover (m)?",
		answer = "16"
	},
	{
		question = "A car moving at 15 m/s comes to a stop in 3 seconds. What is its acceleration (m/s^2)?",
		answer = "-5"
	},
	{
		question = "A rock is thrown straight up with velocity 10 m/s. What is its maximum height (m)? (Use g = 9.8 m/s^2)",
		answer = "5.1"
	},
}

function PhysicsQuestions.GetRandom()
	return problems[math.random(1, #problems)]
end

-- Returns true if the user's answer is within tolerance for numeric values
function PhysicsQuestions.CheckAnswer(correctAnswer, userAnswer)
	if not correctAnswer or not userAnswer then return false end

	local numCorrect = tonumber(correctAnswer)
	local numUser = tonumber(userAnswer)
	if numCorrect and numUser then
		-- allow small rounding errors
		return math.abs(numCorrect - numUser) < 0.2
	else
		return tostring(correctAnswer):lower() == tostring(userAnswer):lower()
	end
end

return PhysicsQuestions
