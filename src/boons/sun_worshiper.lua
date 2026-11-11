---@meta _


once('SunWorshiper', function()
	local raiseDead = game.TraitData.RaiseDeadBoon

	if boon_edit_on('SunWorshiper') then
		raiseDead.BoonEditRepeatChance = mod.tuning.SunWorshiper.RepeatChance
		table.insert(raiseDead.StatLines, 'BoonEditRepeatRaiseStatDisplay')
		table.insert(raiseDead.ExtractValues, {
			Key = 'BoonEditRepeatChance',
			ExtractAs = 'Chance',
			Format = 'LuckModifiedPercent',
			HideSigns = true,
		})
		if mod.tuning.SunWorshiper.HitchSummons then
			raiseDead.ExtractValues = with_keyword_extracts(raiseDead.ExtractValues, 'Link')
		end
	end

	modutil.mod.Path.Wrap("RaiseKilledEnemy", function(base, enemy, args)
		local room = game.CurrentRun and game.CurrentRun.CurrentRoom
		local before = room and room.DestroyAssistUnitOnEncounterEndId

		if sun_worshiper_should_repeat() then
			local previous = game.MapState.RaiseDeadCount
			game.MapState.RaiseDeadCount = nil
			base(enemy, args)
			if not game.MapState.RaiseDeadCount then
				game.MapState.RaiseDeadCount = previous
			end
		else
			base(enemy, args)
		end

		local raised = room and room.DestroyAssistUnitOnEncounterEndId
		if raised and raised ~= before then
			game.thread(sun_worshiper_hitch, raised)
		end
	end)
end)


once('SunWorshiperWard', function()
	modutil.mod.Path.Wrap("ApplyEffect", function(base, args)
		local id = args and args.DestinationId
		local unit = id and game.ActiveEnemies and game.ActiveEnemies[id]
		if sun_worshiper_warded(unit, args and args.EffectName) then return end
		return base(args)
	end)

	modutil.mod.Path.Wrap("ApplyBurn", function(base, victim, functionArgs, triggerArgs)
		if sun_worshiper_warded(victim, functionArgs and functionArgs.EffectName) then return end
		return base(victim, functionArgs, triggerArgs)
	end)

	modutil.mod.Path.Wrap("ApplyRoot", function(base, victim, functionArgs, triggerArgs)
		if sun_worshiper_warded(victim, functionArgs and functionArgs.EffectName) then return end
		return base(victim, functionArgs, triggerArgs)
	end)
end)


once('SunWorshiperAllyKills', function()
	modutil.mod.Path.Wrap("KillEnemy", function(base, victim, triggerArgs)
		local result = base(victim, triggerArgs)
		sun_worshiper_credit_ally_kill(victim, triggerArgs)
		return result
	end)
end)


local SUN_WORSHIPER_RAISE_FUNCTIONS = {
	RaiseKilledEnemy = true,
	RecordSpellSummonEnemyDeath = true,
}


function sun_worshiper_credit_ally_kill(victim, triggerArgs)
	if not boon_edit_on('SunWorshiper') then return end
	if not mod.tuning.SunWorshiper.AllyKillsCount then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	local room = game.CurrentRun and game.CurrentRun.CurrentRoom
	local killer = triggerArgs and triggerArgs.AttackerTable
	if not hero or not room or not victim or not killer then return end
	if killer == hero or killer.TriggersOnDeathWithKillEffects then return end
	if not is_allied_summon(killer) then return end
	if victim.SkipModifiers or victim.AlwaysTraitor then return end
	if (victim.IsBoss or victim.BlockRaiseDead) and not victim.ForceAllowRaiseDead then return end

	room.SummonEnemyName = victim.Name
	sun_worshiper_debug('crediting ' .. tostring(victim.Name) .. ' kill by ' .. sun_worshiper_label(killer) .. ' to you')

	local cache = hero.HeroTraitValuesCache and hero.HeroTraitValuesCache.OnEnemyDeathFunction or {}
	for _, functionArgs in ipairs(cache) do
		if SUN_WORSHIPER_RAISE_FUNCTIONS[functionArgs.Name] then
			game.thread(game.CallFunctionName, functionArgs.Name, victim, functionArgs.FunctionArgs, triggerArgs)
		end
	end
end


once('SunWorshiperRaiseDebug', function()
	modutil.mod.Path.Wrap("KillEnemy", function(base, victim, triggerArgs)
		local result = base(victim, triggerArgs)
		if victim and victim.ForceAllowRaiseDead then
			sun_worshiper_debug('killed ' .. tostring(victim.Name)
				.. ' killer=' .. sun_worshiper_label(triggerArgs and triggerArgs.AttackerTable))
		end
		return result
	end)

	modutil.mod.Path.Wrap("SpellSummon", function(base, triggerArgs, weaponData)
		sun_worshiper_debug('Night Bloom cast')
		return base(triggerArgs, weaponData)
	end)

	modutil.mod.Path.Wrap("RaiseKilledEnemy", function(base, enemy, args)
		if enemy and enemy.ForceAllowRaiseDead then
			sun_worshiper_debug('Sun Worshiper raise attempt on ' .. tostring(enemy.Name))
		end
		return base(enemy, args)
	end)
end)


function sun_worshiper_label(unit)
	if not unit then return 'none' end
	if unit == (game.CurrentRun and game.CurrentRun.Hero) then return 'hero' end
	return tostring(unit.Name) .. '#' .. tostring(unit.ObjectId)
		.. (is_allied_summon(unit) and ' (ally/charmed)' or '')
end


function sun_worshiper_debug(message)
	if not mod.tuning.SunWorshiper.Debug then return end
	local room = game.CurrentRun and game.CurrentRun.CurrentRoom
	local summons = {}
	for _, unit in ipairs(game.MapState and game.MapState.SpellSummons or {}) do
		table.insert(summons, tostring(unit.Name))
	end
	print('[' .. _PLUGIN.guid .. '] SunWorshiper: ' .. message
		.. ' | RaiseDeadCount=' .. tostring(game.MapState and game.MapState.RaiseDeadCount)
		.. ' SummonEnemyName=' .. tostring(room and room.SummonEnemyName)
		.. ' AssistUnitName=' .. tostring(room and room.AssistUnitName)
		.. ' SpellSummons=[' .. table.concat(summons, ',') .. ']'
		.. ' SpellCharge=' .. tostring(game.CurrentRun and game.CurrentRun.SpellCharge))
end


function sun_worshiper_should_repeat()
	if not boon_edit_on('SunWorshiper') then return false end
	if not game.MapState.RaiseDeadCount then return false end

	local room = game.CurrentRun and game.CurrentRun.CurrentRoom
	if not room then return false end

	local raised = room.BoonEditSunWorshiperRepeats or 0
	if raised >= mod.tuning.SunWorshiper.MaxRepeats then return false end

	if not rolls(mod.tuning.SunWorshiper.RepeatChance) then return false end

	room.BoonEditSunWorshiperRepeats = raised + 1
	return true
end


function sun_worshiper_hitch(id)
	game.wait(0.1, game.RoomThreadName)

	if not boon_edit_on('SunWorshiper') then return end
	if not mod.tuning.SunWorshiper.HitchSummons then return end

	local unit = game.ActiveEnemies and game.ActiveEnemies[id]
	if not unit or unit.IsDead or not is_allied_summon(unit) then return end

	game.ApplyDamageShare(unit, {
		EffectName = 'DamageShareEffect',
		EffectArgs = { Duration = mod.tuning.SunWorshiper.SummonHitchDuration },
	})
end


function sun_worshiper_curse(effectName)
	local effect = effectName and game.EffectData[effectName]
	local properties = effect and (effect.EffectData or effect.DataProperties)
	return properties ~= nil and properties.IsVulnerabilityEffect == true
end


function sun_worshiper_warded(unit, effectName)
	if not boon_edit_on('SunWorshiper') then return false end
	if not mod.tuning.SunWorshiper.WardSummons then return false end
	if not unit or not unit.ObjectId then return false end
	if not is_allied_summon(unit) then return false end
	if effectName == 'DamageShareEffect' and mod.tuning.SunWorshiper.HitchSummons then return false end

	return sun_worshiper_curse(effectName)
end
