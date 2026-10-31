local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Moves = require(game:GetService("ReplicatedStorage"):WaitForChild("Moves"))
local CreatureModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Creature"))
local PhysicsQuestions = require(game:GetService("ReplicatedStorage"):WaitForChild("PhysicsQuestions"))

local Battle = {}
local busy = false

local savedPlayerEnergy = nil

-- Wait for player chat input that matches a predicate
local function waitForChatMatch(predicate, timeout)
	local result, resolved = nil, false
	local conn
	conn = player.Chatted:Connect(function(msg)
		if predicate(msg) then
			result, resolved = msg, true
			conn:Disconnect()
		end
	end)

	local elapsed, dt = 0, 0.1
	while not resolved and (not timeout or elapsed < timeout) do
		task.wait(dt)
		elapsed = elapsed + dt
	end

	if conn and conn.Connected then
		conn:Disconnect()
	end
	return result
end

-- Damage calculation using basePower, Attack and Defense
local function calculateDamage(attacker, defender, move)
	move = move or { basePower = 5, accuracy = 1 }
	local base = (move.basePower or 5) * ( (attacker.Attack or 1) / math.max(1, (defender.Defense or 1)) )
	local rng = 1 + ((math.random() - 0.5) * 0.2)
	return math.max(1, math.floor(base * rng))
end

-- Print status
local function printStatus(playerMon, enemyMon)
	local pEnergy = playerMon.Energy or 0
	local pMaxEnergy = playerMon.MaxEnergy or 0
	print((" Status \n%s: %d/%d HP | Energy: %d/%d\n%s: %d/%d HP\n")
		:format(
			playerMon.Name or "Player", playerMon.HP or 0, playerMon.MaxHP or 0,
			pEnergy, pMaxEnergy,
			enemyMon.Name or "Enemy", enemyMon.HP or 0, enemyMon.MaxHP or 0
		)
	)
end

-- Create player creature
local function makePlayerCreature()
	local stats = {
		maxHP = 30,
		attack = 100,
		defense = 5,
		speed = 5,
		moves = {"Tackle", "Slam"},
		maxEnergy = 300
	}
	local pc = CreatureModule.new("HeroMon", Vector2.new(0,0), "rbxassetid://119281678070983", stats)
	pc:ResetHP()
	-- if we have saved energy use it otherwise set to max
	pc.MaxEnergy = pc.MaxEnergy or stats.maxEnergy or 30
	if savedPlayerEnergy then
		pc.Energy = math.clamp(savedPlayerEnergy, 0, pc.MaxEnergy)
	else
		pc.Energy = pc.MaxEnergy
	end
	return pc
end

-- List moves to player
local function listMoves(creature)
	print("Choose a move by typing its number, name, or 'energy' to rest and restore 10 energy:")
	for i, mname in ipairs(creature.Moves or {}) do
		local def = Moves:Get(mname)
		if def then
			print(("%d) %s — Power %d | Acc %.2f | Cost %d"):format(i, def.name or mname, def.basePower or 0, def.accuracy or 1, def.energyCost or 0))
		else
			print(("%d) %s — (unknown move)"):format(i, tostring(mname)))
		end
	end
end

-- Get players action this turn
local function getPlayerAction(playerMon, timeoutSeconds)
	listMoves(playerMon)
	local predicate = function(msg)
		if not msg then return false end
		local num = tonumber(msg)
		if msg:lower() == "energy" then return true end
		if num and playerMon.Moves and playerMon.Moves[num] then return true end
		for _, mn in ipairs(playerMon.Moves or {}) do
			if mn:lower() == msg:lower() then return true end
		end
		return false
	end

	local choice = waitForChatMatch(predicate, timeoutSeconds)
	if not choice then return nil end

	if choice:lower() == "energy" then
		return { type = "energy" }
	end

	local num = tonumber(choice)
	local moveName
	if num and playerMon.Moves and playerMon.Moves[num] then
		moveName = playerMon.Moves[num]
	else
		for _, mn in ipairs(playerMon.Moves or {}) do
			if mn:lower() == choice:lower() then
				moveName = mn
				break
			end
		end
	end

	local move = moveName and Moves:Get(moveName)
	if move then
		return { type = "move", move = move }
	end

	return nil
end

-- Execute an attack (attacker uses move against defender)
local function executeAttack(attacker, defender, move)
	if not move then
		move = { name = "Struggle", basePower = 4, accuracy = 1, energyCost = 0 }
	end

	if math.random() <= (move.accuracy or 1) then
		local dmg = calculateDamage(attacker, defender, move)
		defender.HP = math.max(0, (defender.HP or 0) - dmg)
		print(("%s used %s! It dealt %d damage."):format(attacker.Name or "Creature", move.name or "Move", dmg))
	else
		print(("%s used %s! It missed."):format(attacker.Name or "Creature", move.name or "Move"))
	end
end

-- Enemy AI
local function enemyChooseMove(enemyMon)
	local pool = enemyMon.Moves or {}
	if #pool == 0 then
		return { name = "Struggle", basePower = 4, accuracy = 1, energyCost = 0 }
	end
	local name = pool[ math.random(1, #pool) ]
	return Moves:Get(name) or { name = name or "Struggle", basePower = 5, accuracy = 1, energyCost = 0 }
end

-- Main battle function
function Battle.Start(enemy)
	if busy then
		warn("Battle already in progress.")
		return
	end
	busy = true

	local playerMon = makePlayerCreature()
	local enemyMon = enemy

	-- Reset HP for both
	playerMon:ResetHP()
	enemyMon:ResetHP()

	print(("=== A wild %s appeared! ==="):format(enemyMon.Name or "Enemy"))
	print(("You send out %s!"):format(playerMon.Name or "Hero"))
	print("Battle commands: move number, move name, or 'energy' to rest.")
	printStatus(playerMon, enemyMon)

	while playerMon.HP > 0 and enemyMon.HP > 0 do
		-- decide order each round
		local first, second = nil, nil
		if (playerMon.Speed or 0) >= (enemyMon.Speed or 0) then
			first, second = playerMon, enemyMon
		else
			first, second = enemyMon, playerMon
		end

		-- helper to run one actors turn (returns true if someone fainted)
		local function performTurn(actor, target)
			if actor == playerMon then
				local action = getPlayerAction(playerMon, nil)
				if not action then
					action = { type = "move", move = { name = "Struggle", basePower = 4, accuracy = 1, energyCost = 0 } }
					print("No input! you used 'Struggle'.")
				end

				if action.type == "energy" then
					print("You must answer a physics question to regain energy!")

					local q = PhysicsQuestions.GetRandom()
					print("Question: " .. q.question)
					print("Type your numerical answer (or as text if needed).")

					-- Wait indefinitely until player responds
					local answer = waitForChatMatch(function(msg)
						return msg and msg ~= ""
					end, nil)

					if answer and PhysicsQuestions.CheckAnswer(q.answer, answer) then
						playerMon.Energy = math.min(playerMon.MaxEnergy or 0, (playerMon.Energy or 0) + 10)
						print(("Correct! %s regains 10 energy (%d/%d).")
							:format(playerMon.Name, playerMon.Energy, playerMon.MaxEnergy))
					else
						print(("Incorrect answer! %s fails to recover energy"):format(playerMon.Name))
					end

				elseif action.type == "move" then
					local mv = action.move
					local cost = mv.energyCost or 0
					if (playerMon.Energy or 0) < cost then
						print(("Not enough energy to use %s! (%d/%d)")
							:format(mv.name or "Move", playerMon.Energy or 0, cost))
					else
						playerMon.Energy = (playerMon.Energy or 0) - cost
						executeAttack(playerMon, target, mv)
					end
				end

			else
				-- enemy actor
				local mv = enemyChooseMove(actor)
				executeAttack(actor, target, mv)
			end

			printStatus(playerMon, enemyMon)
			return (target.HP or 0) <= 0
		end


		-- First acts
		local someoneFainted = performTurn(first, second)
		if someoneFainted then break end

		-- Second acts if still alive
		someoneFainted = performTurn(second, first)
		if someoneFainted then break end
	end

	savedPlayerEnergy = (playerMon and playerMon.Energy) or savedPlayerEnergy

	if playerMon.HP and playerMon.HP <= 0 then
		print(("Your %s fainted! You lost the battle."):format(playerMon.Name))
	elseif enemyMon.HP and enemyMon.HP <= 0 then
		print(("Enemy %s fainted! You win!"):format(enemyMon.Name))
	end

	print("=== Battle ended ===")
	busy = false
end

return Battle
