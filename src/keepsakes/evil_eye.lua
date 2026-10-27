---@meta _


local EVIL_EYE = 'DeathVengeanceKeepsake'

local NO_MATCH = 'BoonEditEvilEyeNoTarget'


once('EvilEye', function()
	modutil.mod.Path.Wrap('DamageHero', function(base, victim, triggerArgs)
		evil_eye_mark(triggerArgs)
		return base(victim, triggerArgs)
	end)

	modutil.mod.Path.Wrap('CalculateDamageMultipliers', function(base, attacker, victim, weaponData, triggerArgs)
		if not evil_eye_active() or attacker ~= game.CurrentRun.Hero or not victim then
			return base(attacker, victim, weaponData, triggerArgs)
		end

		local cause = game.GameState.CauseOfDeath
		game.GameState.CauseOfDeath = evil_eye_matches(victim) and game.GetGenusName(victim) or NO_MATCH
		local ok, result = pcall(base, attacker, victim, weaponData, triggerArgs)
		game.GameState.CauseOfDeath = cause
		if not ok then error(result, 0) end

		return result
	end)
end)


function evil_eye_active()
	return boon_edit_on('EvilEye') and game.CurrentRun and game.CurrentRun.Hero and game.HeroHasTrait(EVIL_EYE)
end


function evil_eye_mark(triggerArgs)
	if not evil_eye_active() then return end

	local attacker = triggerArgs and triggerArgs.AttackerTable
	if not attacker or attacker == game.CurrentRun.Hero or not attacker.ObjectId then return end
	if not game.ActiveEnemies[attacker.ObjectId] then return end
	if is_allied_summon(attacker) then return end

	game.SessionMapState.BoonEditEvilEyeId = attacker.ObjectId
	game.CurrentRun.BoonEditEvilEyeGenus = game.GetGenusName(attacker)
end


function evil_eye_matches(victim)
	if mod.tuning.EvilEye.MatchWholeType then
		local genus = game.CurrentRun.BoonEditEvilEyeGenus
		return genus ~= nil and game.GetGenusName(victim) == genus
	end

	local id = game.SessionMapState.BoonEditEvilEyeId
	return id ~= nil and victim.ObjectId == id
end
