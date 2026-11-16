---@meta _
---@diagnostic disable: lowercase-global


FLAWLESS_EXECUTION_TRAIT = 'BoonEditFlawlessExecutionBoon'


once('FlawlessExecution', function()
	if not game.TraitData[FLAWLESS_EXECUTION_TRAIT] then
		local tuning = mod.tuning.FlawlessExecution
		local trait = game.DeepCopyTable(game.TraitData.TimeStopLastStandBoon)

		trait.Name = FLAWLESS_EXECUTION_TRAIT
		trait.Icon = tuning.Icon
		trait.MoneyShieldData = nil
		trait.Elements = { tuning.Element }
		trait.FlavorText = nil

		trait.BoonEditMaxBonus = tuning.MaxPercent
		trait.BoonEditFlawlessMultiplier = 1
		trait.BoonEditFlawlessDefense = 1

		trait.AddOutgoingDamageModifiers = {
			UseTraitValue = 'BoonEditFlawlessMultiplier',
			IsMultiplier = true,
		}
		trait.AddIncomingDamageModifiers = {
			UseTraitValue = 'BoonEditFlawlessDefense',
			IsMultiplier = true,
			IncludeObstacleDamage = tuning.IncludeTraps,
		}

		trait.ShowInHUD = true
		trait.CustomLabel = {
			DisplayType = 'RoomValue',
			Key = 'BoonEditFlawlessPercent',
			Text = 'UI_TimedKillBuff',
		}
		trait.SetupFunction = {
			Threaded = true,
			Name = _PLUGIN.guid .. '.FlawlessExecution',
			RepeatOnEncounterStart = true,
			Args = { Interval = tuning.StepInterval },
		}

		trait.StatLines = { 'BoonEditFlawlessExecutionMaxStatDisplay' }
		trait.ExtractValues = {
			{ Key = 'BoonEditMaxBonus', ExtractAs = 'TooltipMaxBonus', Format = 'Percent', IncludeSigns = true },
		}
		trait.TraitOrderingValueCache = game.GetTraitOrderingValue(trait)

		game.TraitData[FLAWLESS_EXECUTION_TRAIT] = trait
	end

	modutil.mod.Path.Wrap('CalculateDamageMultipliers', function(base, attacker, victim, weaponData, triggerArgs)
		flawless_execution_refresh(attacker, victim, triggerArgs)
		return base(attacker, victim, weaponData, triggerArgs)
	end)

	modutil.mod.Path.Wrap('DamageHero', function(base, victim, triggerArgs)
		local result = base(victim, triggerArgs)
		flawless_execution_struck(victim, triggerArgs)
		return result
	end)

	modutil.mod.Path.Wrap('ProcessHealthBuffer', function(base, enemy, damageEventArgs)
		local shields = enemy and enemy.HitShields
		local result = base(enemy, damageEventArgs)
		flawless_execution_note_shield(enemy, damageEventArgs, shields)
		return result
	end)
end)


local function flawless_execution_held()
	return boon_edit_on('FlawlessExecution') and game.HeroHasTrait(FLAWLESS_EXECUTION_TRAIT)
end


local function flawless_execution_bonus(run)
	local tuning = mod.tuning.FlawlessExecution
	return math.min((run.BoonEditFlawlessSteps or 0) * tuning.PercentPerStep, tuning.MaxPercent)
end


local function flawless_execution_defense(run)
	local tuning = mod.tuning.FlawlessExecution
	return math.min((run.BoonEditFlawlessSteps or 0) * tuning.DefensePerStep, tuning.MaxDefense)
end


local function flawless_execution_show(run)
	local trait = game.GetHeroTrait(FLAWLESS_EXECUTION_TRAIT)
	if trait then trait.BoonEditFlawlessDefense = 1 - flawless_execution_defense(run) end

	local room = run.CurrentRoom
	if not room then return end

	local percent = math.floor(flawless_execution_bonus(run) * 100 + 0.5)
	if room.BoonEditFlawlessPercent == percent then return end

	room.BoonEditFlawlessPercent = percent
	if trait then game.UpdateTraitNumber(trait) end
end


local function flawless_execution_foe(enemy)
	return enemy ~= nil and not enemy.IsDead and not boon_ignores(enemy)
end


local function flawless_execution_foes_present()
	for _, enemy in pairs(game.ActiveEnemies or {}) do
		if flawless_execution_foe(enemy) then return true end
	end
	return false
end


local function flawless_execution_running()
	return game.CurrentRun and game.CurrentRun.CurrentRoom and hero_live() and game.HeroHasTrait(FLAWLESS_EXECUTION_TRAIT)
end


function mod.FlawlessExecution(_hero, args)
	local interval = (args and args.Interval) or mod.tuning.FlawlessExecution.StepInterval

	local run = game.CurrentRun
	if not run then return end

	flawless_execution_show(run)

	local loop = FLAWLESS_EXECUTION_TRAIT .. 'Loop'
	if game.HasThread(loop) then return end

	while flawless_execution_running() do
		game.wait(interval, loop)
		run = game.CurrentRun
		if not run then return end

		if boon_edit_on('FlawlessExecution') and flawless_execution_foes_present() then
			run.BoonEditFlawlessSteps = (run.BoonEditFlawlessSteps or 0) + 1
		end
		flawless_execution_show(run)
	end
end


function flawless_execution_note_shield(enemy, damageEventArgs, shields)
	if not damageEventArgs or not shields then return end
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or enemy ~= hero then return end
	if (enemy.HitShields or 0) < shields then damageEventArgs.BoonEditFlawlessShieldBlocked = true end
end


local function flawless_execution_attack(victim, triggerArgs)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or victim ~= hero or not triggerArgs then return false end
	if triggerArgs.ManuallyTriggered or triggerArgs.PureDamage or triggerArgs.EffectName then return false end

	local attacker = triggerArgs.AttackerTable
	if attacker == hero then return false end
	if attacker == nil and triggerArgs.AttackerName == nil then return false end
	if triggerArgs.BoonEditFlawlessShieldBlocked then return false end
	if triggerArgs.HealthProtected then return true end

	local raw = triggerArgs.BoonEditFlawlessRawDamage or triggerArgs.DamageAmount
	return type(raw) == 'number' and raw > 0
end


local function flawless_execution_expire_presentation()
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local sound = mod.tuning.FlawlessExecution.ExpireSound
	if sound then game.PlaySound({ Name = sound, Id = hero.ObjectId }) end
	game.thread(game.InCombatTextArgs, {
		TargetId = hero.ObjectId,
		Text = 'BoonEditFlawlessExecutionExpired',
		Duration = 1.45,
		PreDelay = 0.1,
	})
end


function flawless_execution_struck(victim, triggerArgs)
	if not flawless_execution_held() then return end
	if not flawless_execution_attack(victim, triggerArgs) then return end

	local state = game.SessionMapState
	local now = game._worldTime or 0
	if state.BoonEditFlawlessGraceUntil and now < state.BoonEditFlawlessGraceUntil then return end
	state.BoonEditFlawlessGraceUntil = now + mod.tuning.FlawlessExecution.ResetGrace

	local run = game.CurrentRun
	local had = (run.BoonEditFlawlessSteps or 0) > 0
	run.BoonEditFlawlessSteps = 0
	flawless_execution_show(run)

	if had then flawless_execution_expire_presentation() end
end


local function flawless_execution_multiplier(attacker, triggerArgs)
	if not boon_edit_on('FlawlessExecution') then return 1 end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if attacker ~= hero then return 1 end

	return 1 + flawless_execution_bonus(game.CurrentRun)
end


function flawless_execution_refresh(attacker, victim, triggerArgs)
	if not game.CurrentRun then return end
	local trait = game.GetHeroTrait(FLAWLESS_EXECUTION_TRAIT)
	if not trait then return end

	trait.BoonEditFlawlessMultiplier = flawless_execution_multiplier(attacker, triggerArgs)

	local hero = game.CurrentRun.Hero
	if hero and victim == hero then
		local multiplier = boon_edit_on('FlawlessExecution') and 1 - flawless_execution_defense(game.CurrentRun) or 1
		local raw = triggerArgs and triggerArgs.DamageAmount
		if triggerArgs then triggerArgs.BoonEditFlawlessRawDamage = raw end
		if type(raw) == 'number' and raw > 0 then
			multiplier = math.max(multiplier, math.min(1, 1 / raw))
		end
		trait.BoonEditFlawlessDefense = multiplier
	end
end
