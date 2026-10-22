---@meta _


once('BurningMeteor', function()
	local combustion = game.TraitData.BurnSprintBoon

	mod.FireAwayEffect = {
		OnBlockDamageFunction     = combustion.OnBlockDamageFunction,
		OnWeaponFiredFunctions    = combustion.OnWeaponFiredFunctions,
		OnProjectileDeathFunction = combustion.OnProjectileDeathFunction,
		StatLines                 = combustion.StatLines,
		ExtractValues             = combustion.ExtractValues,
	}

	if boon_edit_on('BurningMeteor') then
		mod.FireAwayEffect.OnBlockDamageFunction.Args.EffectArgs.NumStacks = 999
	end

	if not boon_edit_on('BurningMeteor') then return end

	local fireballs = fireball_projectiles()

	combustion.OnBlockDamageFunction = nil
	combustion.OnWeaponFiredFunctions = nil
	combustion.OnProjectileDeathFunction = nil

	combustion.AddOutgoingDamageModifiers = {
		ValidProjectiles = fireballs,
		ValidProjectilesLookup = game.ToLookup(fireballs),
		ValidWeaponMultiplier = mod.tuning.BurningMeteor.FireballMultiplier,
	}

	combustion.OnDamageEnemyFunction = {
		FunctionName = _PLUGIN.guid .. '.BurningMeteor',
		FunctionArgs = {
			ValidProjectilesLookup = game.ToLookup(fireballs),
		},
	}

	combustion.OnProjectileCreationFunction = {
		ValidProjectiles = fireballs,
		ValidProjectilesLookup = game.ToLookup(fireballs),
		Name = _PLUGIN.guid .. '.BurningMeteorSize',
		Args = {
			AreaMultiplier = mod.tuning.BurningMeteor.SizeMultiplier,
		},
	}

	combustion.BoonEditFireballMultiplier = mod.tuning.BurningMeteor.FireballMultiplier
	combustion.StatLines = { 'BoonEditMeteorDamageStatDisplay' }
	combustion.ExtractValues = with_keyword_extracts({
		{
			Key = 'BoonEditFireballMultiplier',
			ExtractAs = 'TooltipFireballDamage',
			Format = 'PercentDelta',
		},
	}, 'Burn')
end)


function burning_meteor_active()
	return boon_edit_on('BurningMeteor') and game.HeroHasTrait('BurnSprintBoon')
end

function mod.BurningMeteor(args, attacker, victim, triggerArgs)
	if not burning_meteor_active() then return end
	if not victim or not victim.ObjectId or victim.IsDead or not victim.ActiveEffects then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or attacker ~= hero then return end

	if not triggerArgs or triggerArgs.EffectName then return end

	local fireballs = args and args.ValidProjectilesLookup
	if not fireballs or not fireballs[triggerArgs.SourceProjectile] then return end

	local damage = triggerArgs.DamageAmount
	if type(damage) ~= 'number' or damage <= 0 then return end

	game.ApplyBurn(victim, {
		EffectName = 'BurnEffect',
		NumStacks = math.floor(damage + 0.5),
	}, triggerArgs)
end

function mod.BurningMeteorSize(triggerArgs, args)
	if not burning_meteor_active() then return end
	if not triggerArgs or not triggerArgs.ProjectileId then return end

	game.SetDamageRadiusMultiplier({
		Id = triggerArgs.ProjectileId,
		Fraction = args and args.AreaMultiplier or 1,
		Duration = 0,
	})
end
