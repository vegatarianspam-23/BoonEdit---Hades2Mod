---@meta _


once('WinterHarvestBosses', function()
	if boon_edit_on('WinterHarvest') then
		local harvest = game.TraitData.InstantRootKill.OnDamageEnemyFunction.FunctionArgs
		harvest.ExecuteImmunities = nil
		harvest.ChillDeathThreshold = mod.tuning.WinterHarvest.ExecuteThreshold
	end

	modutil.mod.Path.Wrap("CheckChillKill", function(base, args, attacker, victim, triggerArgs)
		args = winter_harvest_pooled_args(args, victim)
		if winter_harvest_executes(args, attacker, victim, triggerArgs) then
			local skipping = winter_harvest_skips_phase(victim)
			if skipping then
				victim.CurrentPhase = victim.Phases
			end

			winter_harvest_stop_phases(victim)

			if skipping then
				winter_harvest_shout(victim)
			end
		end
		return base(args, attacker, victim, triggerArgs)
	end)
end)


local function boss_phase_healths(victim)
	local template = game.EnemyData[victim.Name]
	local stages = victim.AIStages or (template and template.AIStages)
	if not stages then return nil end

	local phases = victim.Phases or math.huge

	if (victim.CurrentPhase or 1) == 1 then
		victim.BoonEditFirstPhaseHealth = victim.MaxHealth
	end

	local healths = { victim.BoonEditFirstPhaseHealth or (template and template.MaxHealth) }
	if not healths[1] then return nil end

	local extremeMeasures = game.IsBossDifficultyShrineUpgradeActive()
	for _, stage in ipairs(stages) do
		if #healths < phases then
			local overrides = extremeMeasures and stage.EMStageDataOverrides
			local health = (overrides and overrides.NewMaxHealth) or stage.NewMaxHealth
			if health then
				healths[#healths + 1] = health
			end
		end
	end
	return healths
end

function winter_harvest_pooled_args(args, victim)
	if not boon_edit_on('WinterHarvest') then return args end
	if not victim or not victim.MaxHealth or victim.MaxHealth <= 0 then return args end

	local healths = boss_phase_healths(victim)
	if not healths or #healths < 2 then return args end

	local total, later = 0, 0
	for phase, health in ipairs(healths) do
		total = total + health
		if phase > (victim.CurrentPhase or 1) then later = later + health end
	end

	local scaled = game.ShallowCopyTable(args)
	scaled.ChillDeathThreshold = (args.ChillDeathThreshold * total - later) / victim.MaxHealth
	return scaled
end

function winter_harvest_executes(args, attacker, victim, triggerArgs)
	if not boon_edit_on('WinterHarvest') then return false end
	if not victim or not victim.ObjectId then return false end
	if not victim.MaxHealth or victim.MaxHealth <= 0 then return false end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if attacker ~= hero then return false end
	if victim.IsDead or victim.CannotDieFromDamage then return false end
	if game.SessionMapState.FiredChillKill[victim.ObjectId] then return false end
	if not triggerArgs or triggerArgs.SourceProjectile == args.ProjectileName then return false end
	if not game.HasEffectWithEffectGroup(victim, 'Root') or not victim.RootActive then return false end

	return victim.Health / victim.MaxHealth <= args.ChillDeathThreshold
end

function winter_harvest_skips_phase(victim)
	return victim.Phases ~= nil and (victim.CurrentPhase or 1) < victim.Phases
end

function winter_harvest_stop_phases(victim)
	victim.AIEndHealthThreshold = nil
	victim.ReachedAIStageEnd = nil
	if victim.AIThreadName then
		game.killTaggedThreads(victim.AIThreadName)
	end
end


local ZAGREUS_HARVEST_LINE = {
	{
		Queue = 'Interrupt',
		Source = { LineHistoryName = 'NPC_Zagreus_01', SubtitleColor = game.Color.ZagreusVoice },
		{ Cue = '/VO/Zagreus_0358', Text = 'Grandmother...?' },
	},
}

function winter_harvest_shout(victim)
	if not victim or victim.Name ~= 'Zagreus' then return end
	game.thread(game.PlayVoiceLines, ZAGREUS_HARVEST_LINE, true, victim)
end
