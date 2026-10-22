---@meta _


local BLITZ = { 'ZeusEchoStrike' }

once('ThermalDynamicsBlitz', function()
	if not boon_edit_on('ThermalDynamics') then return end

	local thermal = game.TraitData.EchoBurnBoon

	thermal.OnEffectApplyFunction = nil

	thermal.OnDamageEnemyFunction = {
		FunctionName = _PLUGIN.guid .. '.ThermalDynamics',
		FunctionArgs = {
			ValidProjectilesLookup = game.ToLookup(BLITZ),
		},
	}

	thermal.BoonEditScorchFraction = mod.tuning.ThermalDynamics.ScorchFraction
	thermal.StatLines = { 'BoonEditThermalScorchStatDisplay' }
	thermal.ExtractValues = with_keyword_extracts({
		{
			Key = 'BoonEditScorchFraction',
			ExtractAs = 'TooltipScorchFraction',
			Format = 'Percent',
			HideSigns = true,
		},
	}, 'Burn')
end)


function mod.ThermalDynamics(args, attacker, victim, triggerArgs)
	if not boon_edit_on('ThermalDynamics') then return end
	if not victim or not victim.ObjectId or victim.IsDead or not victim.ActiveEffects then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or attacker ~= hero then return end

	if not triggerArgs or triggerArgs.EffectName then return end

	local blitz = args and args.ValidProjectilesLookup
	if not blitz or not blitz[triggerArgs.SourceProjectile] then return end

	local damage = triggerArgs.DamageAmount
	if type(damage) ~= 'number' or damage <= 0 then return end

	local stacks = math.floor(damage * mod.tuning.ThermalDynamics.ScorchFraction + 0.5)
	if stacks <= 0 then return end

	game.ApplyBurn(victim, { EffectName = 'BurnEffect', NumStacks = stacks }, triggerArgs)
end
