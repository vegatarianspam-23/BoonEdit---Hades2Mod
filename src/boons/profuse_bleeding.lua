---@meta _


once('ProfuseBleedingBloodSpill', function()
	if not boon_edit_on('ProfuseBleeding') then return end

	local rend = game.TraitData.RendBloodDropBoon

	rend.RarityLevels = {
		Common = { Multiplier = 1.0 },
		Rare = { Multiplier = 1.5 },
		Epic = { Multiplier = 2.0 },
		Heroic = { Multiplier = 2.5 },
	}

	rend.AcquireFunctionName = 'SetupBloodDropDisplay'

	rend.BloodDropOrRendFallingBladeArgs = nil
	rend.OnEnemyDamagedAction = {
		FunctionName = 'CheckAresBloodDrop',
		Args = {
			Chance = { BaseValue = mod.tuning.ProfuseBleeding.SpillChance },
			RequiredEffect = 'AresStatus',
			Name = 'BloodDrop',
			ReportValues = { ReportedDropChance = 'Chance' },
		},
	}
	rend.OnEffectApplyFunction = { FunctionName = _PLUGIN.guid .. '.ProfuseBleedingFreshRend' }

	rend.StatLines = { 'BoonEditBloodSpillChanceStatDisplay' }
	rend.ExtractValues = with_keyword_extracts({
		{
			Key = 'ReportedDropChance',
			ExtractAs = 'TooltipDropChance',
			Format = 'LuckModifiedPercent',
			HideSigns = true,
		},
	}, 'Rend')
end)


---@diagnostic disable-next-line: unused-local
function mod.ProfuseBleedingFreshRend(victim, _args, triggerArgs)
	if not boon_edit_on('ProfuseBleeding') or not game.CurrentRun then return end
	if not triggerArgs or triggerArgs.EffectName ~= 'AresStatus' or triggerArgs.Reapplied then return end
	if not victim or victim.IsDead or victim == game.CurrentRun.Hero then return end

	local trait = game.GetHeroTrait('RendBloodDropBoon')
	local args = trait and trait.OnEnemyDamagedAction and trait.OnEnemyDamagedAction.Args
	if not args or not args.Chance then return end

	if rolls(args.Chance * mod.tuning.ProfuseBleeding.FreshRendMultiplier) then
		game.thread(game.CreateBloodDrop, victim, args)
	end
end
