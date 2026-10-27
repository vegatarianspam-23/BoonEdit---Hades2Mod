---@meta _


once('MeanStreak', function()
	if not boon_edit_on('MeanStreak') then return end

	local streak = game.TraitData.TimedKillBuffBoon
	local modifier = streak and streak.AddOutgoingDamageModifiers
	if not modifier then return end

	modifier.ValidWeapons = nil

	modutil.mod.Path.Wrap('ReduceKillBuff', function(base, args)
		if not boon_edit_on('MeanStreak') or not mod.tuning.MeanStreak.PauseInMenus then return base(args) end

		return mean_streak_reduce(args)
	end)
end)


function mean_streak_timer_blocked()
	return game.HasTimerBlock(game.CurrentRun) or game.IsBiomeTimerPaused() or game.SessionMapState.IsPaused
end


function mean_streak_full_duration(args)
	local trait = game.GetHeroTrait('TimedKillBuffBoon')
	local death = trait and trait.OnEnemyDeathFunction
	local full = death and death.FunctionArgs and death.FunctionArgs.Duration

	return full or args.Duration
end


function mean_streak_sync_start_times(full)
	local records = game.SessionMapState.BoonEditMeanStreak or {}
	local starts = {}
	for _, record in ipairs(records) do
		table.insert(starts, game._worldTime - (full - record.Remaining))
	end
	game.SessionMapState.TimedBuffStartTimes = starts
end


function mean_streak_tick(record, full)
	local step = math.min(mod.tuning.MeanStreak.Tick, record.Remaining)
	game.waitUnmodified(step, game.RoomThreadName)
	if not mean_streak_timer_blocked() then
		record.Remaining = record.Remaining - step
	end
	mean_streak_sync_start_times(full)
end


function mean_streak_reduce(args)
	local full = mean_streak_full_duration(args)
	local records = game.SessionMapState.BoonEditMeanStreak or {}
	game.SessionMapState.BoonEditMeanStreak = records

	local record = { Remaining = args.Duration }
	table.insert(records, record)

	while record.Remaining > 0 do
		mean_streak_tick(record, full)
	end

	for i, other in ipairs(records) do
		if other == record then
			table.remove(records, i)
			break
		end
	end

	game.SessionMapState.TimedBuff = game.SessionMapState.TimedBuff - 1
	mean_streak_sync_start_times(full)
	game.UIScriptsDeferred.KillBuffDirty = true
	if game.SessionMapState.TimedBuff <= 0 then
		game.StopAnimation({ Name = args.Fx, DestinationId = game.CurrentRun.Hero.ObjectId })
	end
end
