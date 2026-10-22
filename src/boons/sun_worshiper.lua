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
	end

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

	modutil.mod.Path.Wrap("RaiseKilledEnemy", function(base, enemy, args)
		if sun_worshiper_should_repeat() then
			local previous = game.MapState.RaiseDeadCount
			game.MapState.RaiseDeadCount = nil
			base(enemy, args)
			if not game.MapState.RaiseDeadCount then
				game.MapState.RaiseDeadCount = previous
			end
			return
		end
		return base(enemy, args)
	end)
end)


function sun_worshiper_should_repeat()
	if not boon_edit_on('SunWorshiper') then return false end
	if not game.MapState.RaiseDeadCount then return false end

	local raised = game.MapState.BoonEditSunWorshiperRepeats or 0
	if raised >= mod.tuning.SunWorshiper.MaxRepeats then return false end

	if not rolls(mod.tuning.SunWorshiper.RepeatChance) then return false end

	game.MapState.BoonEditSunWorshiperRepeats = raised + 1
	return true
end


function sun_worshiper_curse(effectName)
	local effect = effectName and game.EffectData[effectName]
	local properties = effect and (effect.EffectData or effect.DataProperties)
	return properties ~= nil and properties.IsVulnerabilityEffect == true
end


function sun_worshiper_warded(unit, effectName)
	if not mod.tuning.SunWorshiper.WardSummons then return false end
	if not unit or not unit.ObjectId then return false end
	if not is_allied_summon(unit) then return false end

	return sun_worshiper_curse(effectName)
end
