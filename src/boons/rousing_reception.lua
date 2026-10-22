---@meta _


once('RousingReceptionCastCurse', function()
	local summonProjectile = game.ProjectileData.HeraCastSummonProjectile
	summonProjectile.OnHitFunctionNames = summonProjectile.OnHitFunctionNames or {}
	table.insert(summonProjectile.OnHitFunctionNames, _PLUGIN.guid .. '.RousingReceptionCurse')
end)


cast_curses = {
	HeraCastBoon       = { EffectName = 'DamageShareEffect' };
	AphroditeCastBoon  = { EffectName = 'WeakEffect' };
	ApolloCastBoon     = { EffectName = 'BlindEffect' };
	DemeterCastBoon    = { EffectName = 'ChillEffect', Apply = 'ApplyRoot' };
	PoseidonCastBoon   = { EffectName = 'AmplifyKnockbackEffect' };
	HestiaCastBoon     = { EffectName = 'BurnEffect', Apply = 'ApplyBurn', StacksFromDamage = true };

	ZeusCastBoon       = { EffectName = 'DamageEchoEffect', Overrides = { Modifier = 1 } };
	HephaestusCastBoon = { EffectName = 'DelayedKnockbackEffect' };
	AresCastBoon       = {
		EffectName = 'AresStatus'; BonusDamageOnInflict = true;
		DamageTextStartColor = 'AresDamageLight';
		DamageTextColor = 'AresDamage';
		HitFx = 'AresMissingDamageFx';
		HitSfx = '/SFX/AresRendApply';
	};
}

cast_strikes = {
	ZeusCastBoon       = { ArgsField = 'OnWeaponFiredFunctions',    Style = 'bolt' };
	HephaestusCastBoon = { ArgsField = 'OnWeaponFiredFunctions',    Style = 'projectile' };
	AresCastBoon       = { ArgsField = 'OnEffectApplyFunction',     Style = 'projectile' };
	HestiaCastBoon     = { ArgsField = 'OnCastEffectApplyFunction', Style = 'burn' };
}

function fire_cast_strike(victim, traitName, strike, triggerArgs)
	local trait = game.GetHeroTrait(traitName)
	local entry = trait and trait[strike.ArgsField]
	local args = entry and entry.FunctionArgs
	if not args then return end

	if strike.Style == 'bolt' then
		game.thread(game.CreateZeusBolt, {
			SourceId = victim.ObjectId,
			TargetId = victim.ObjectId,
			Range = args.Range,
			WeaponName = 'WeaponCast',
			ProjectileName = args.ProjectileName,
			DamageMultiplier = args.DamageMultiplier,
			InitialDelay = 0,
			Delay = 0.1,
			Count = 1,
		})

	elseif strike.Style == 'projectile' then
		game.CreateProjectileFromUnit({
			Name = args.ProjectileName,
			Id = game.CurrentRun.Hero.ObjectId,
			DestinationId = victim.ObjectId,
			DamageMultiplier = args.DamageMultiplier,
			FireFromTarget = true,
		})

	elseif strike.Style == 'burn' then
		local multiplier = game.CalculateDamageMultipliers(
			game.CurrentRun.Hero, victim, game.WeaponData.WeaponCast,
			{ SourceWeapon = 'WeaponCast', ExplicitMultipliersOnly = true })
		game.ApplyBurn(victim, {
			EffectName = args.EffectName,
			NumStacks = game.round(args.NumStacks * multiplier),
		}, triggerArgs)
	end
end

function cast_curse_stacks(triggerArgs)
	local damage = (triggerArgs and triggerArgs.DamageAmount) or 0
	return math.max(1, math.floor(damage * mod.tuning.RousingReception.DamageScaledCurseMultiplier))
end

function apply_cast_curse(victim, curse, triggerArgs)
	if curse.BonusDamageOnInflict and triggerArgs then
		local bonus = game.EffectData[curse.EffectName].BonusBaseDamageOnInflict or 0
		triggerArgs.DamageAmount = (triggerArgs.DamageAmount or 0) + bonus
	end

	if triggerArgs then
		if curse.DamageTextStartColor then
			triggerArgs.OverrideDamageTextStartColor = game.Color[curse.DamageTextStartColor]
		end
		if curse.DamageTextColor then
			triggerArgs.OverrideDamageTextColor = game.Color[curse.DamageTextColor]
		end
	end

	if curse.HitFx then
		if curse.HitSfx then
			game.PlaySound({ Name = curse.HitSfx, Id = victim.ObjectId, ManagerCap = 46 })
		end
		game.CreateAnimation({
			Name = curse.HitFx,
			DestinationId = victim.ObjectId,
			Angle = triggerArgs and triggerArgs.ImpactAngle,
		})
	end

	if curse.EffectName == 'DamageShareEffect' then
		apply_hitch(victim)
		return
	end

	if curse.Apply then
		local args = { EffectName = curse.EffectName }
		if curse.StacksFromDamage then
			args.NumStacks = cast_curse_stacks(triggerArgs)
		end
		game[curse.Apply](victim, args, triggerArgs)
		return
	end

	local dataProperties = game.EffectData[curse.EffectName].EffectData
	if curse.Overrides then
		dataProperties = game.MergeAllTables({ dataProperties, curse.Overrides })
	end

	game.ApplyEffect({
		DestinationId = victim.ObjectId,
		Id = game.CurrentRun.Hero.ObjectId,
		EffectName = curse.EffectName,
		DataProperties = dataProperties,
	})
end

---@diagnostic disable-next-line: unused-local
function mod.RousingReceptionCurse(victim, _victimId, triggerArgs)
	if not boon_edit_on('RousingReception') then return end

	if mod.tuning.RousingReception.HitchOnly then
		apply_hitch(victim)
		return
	end

	if mod.tuning.RousingReception.UseCastStrikes then
		for traitName, strike in pairs(cast_strikes) do
			if game.HeroHasTrait(traitName) then
				fire_cast_strike(victim, traitName, strike, triggerArgs)
				return
			end
		end
	end

	for traitName, curse in pairs(cast_curses) do
		if game.HeroHasTrait(traitName) then
			apply_cast_curse(victim, curse, triggerArgs)
		end
	end
end
