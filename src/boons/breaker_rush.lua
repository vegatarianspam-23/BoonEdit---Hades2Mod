---@meta _


local BREAKER_RUSH_WEAPONS = { 'WeaponBlink', 'WeaponSprint' }


once('BreakerRushWaves', function()
	if not boon_edit_on('BreakerRush') then return end

	local breaker = game.TraitData.PoseidonSprintBoon

	local wave = mod.tuning.BreakerRush.WaveProjectile
	local waveDamage = game.GetBaseDataValue({ Type = 'Projectile', Name = wave, Property = 'Damage' })
	if type(waveDamage) ~= 'number' or waveDamage <= 0 then
		waveDamage = 60
	end

	local vanillaRarity = breaker.RarityLevels

	breaker.RarityLevels = {}
	for rarity, damage in pairs(mod.tuning.BreakerRush.WaveDamage) do
		breaker.RarityLevels[rarity] = { Multiplier = damage / waveDamage }
	end

	breaker.OnWeaponFiredFunctions = {
		ValidWeapons = game.DeepCopyTable(BREAKER_RUSH_WEAPONS),
		ValidWeaponsLookup = game.ToLookup(BREAKER_RUSH_WEAPONS),
		ExcludeLinked = true,
		FunctionName = _PLUGIN.guid .. '.BreakerRushStart',
		FunctionArgs = {
			ProjectileName = wave,
			DamageMultiplier = {
				BaseValue = 1,
				DecimalPlaces = 3,

				AbsoluteStackValues = {
					[1] = mod.tuning.BreakerRush.PomDamage.First / waveDamage,
					[2] = mod.tuning.BreakerRush.PomDamage.Rest / waveDamage,
				},
			},
			ReportValues = { ReportedMultiplier = 'DamageMultiplier' },
		},
	}
	breaker.OnSprintEndAction = { FunctionName = _PLUGIN.guid .. '.BreakerRushEnd' }
	breaker.OnBlinkEndAction = {
		FunctionName = _PLUGIN.guid .. '.BreakerRushEnd',
		FunctionArgs = {
			CheckSprint = true,
			TraitName = 'PoseidonSprintBoon',
			Name = 'BreakerRushNoCooldown',
			Cooldown = 0,
		},
	}

	breaker.StatLines = { 'SplashDamageStatDisplay1' }
	breaker.ExtractValues = {
		{
			Key = 'ReportedMultiplier',
			ExtractAs = 'Damage',
			Format = 'MultiplyByBase',
			BaseType = 'Projectile',
			BaseName = wave,
			BaseProperty = 'Damage',
		},
	}

	local spend = breaker.OnEnemyDamagedAction
	spend.ValidProjectilesLookup = game.ToLookup(spend.ValidProjectiles)
	spend.Args.DamageMultiplier.CustomRarityMultiplier = vanillaRarity
end)


function fire_breaker_rush_wave(args, _triggerArgs)
	if rush_end_suppressed(args) then return end

	breaker_rush_splash()

	game.SessionMapState.BoonEditBreakerRushStarted = nil
end


function breaker_rush_caught(radius)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	local caught = {}
	if not hero then return caught end

	local nearby = game.GetClosestIds({
		Id = hero.ObjectId,
		DestinationName = 'EnemyTeam',
		IgnoreInvulnerable = true,
		StopsProjectiles = true,
		IgnoreHomingIneligible = true,
		IgnoreSelf = true,
		Distance = radius,
		PreciseCollision = true,
	}) or {}

	for _, id in pairs(nearby) do
		local unit = game.ActiveEnemies[id]
		if unit and not unit.IsDead and not boon_ignores(unit)
			and not is_allied_summon(unit) then
			table.insert(caught, unit)
		end
	end
	return caught
end


function breaker_rush_splash()
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local trait = game.GetHeroTrait('PoseidonSprintBoon')
	local traitArgs = trait and trait.OnWeaponFiredFunctions and trait.OnWeaponFiredFunctions.FunctionArgs
	if not traitArgs then return end

	local tuning = mod.tuning.BreakerRush
	local reach = tuning.ImpactRadius * tuning.RingScale

	local scale, count, graphic = poseidon_splash_cone()

	rush_impact_ring(tuning.ImpactFx, reach, tuning.ImpactPulses, tuning.ImpactPulseDelay)

	local caught = breaker_rush_caught(reach)
	if game.IsEmpty(caught) then return end

	arterial_spray_begin({ ProjectileName = traitArgs.ProjectileName })

	local ok, err = pcall(function()
		for _, unit in ipairs(caught) do
			local angle = game.GetAngleBetween({ DestinationId = unit.ObjectId, Id = hero.ObjectId })

			for i = 1, count do
				game.CreateProjectileFromUnit({
					Name = traitArgs.ProjectileName,
					Id = hero.ObjectId,
					Angle = angle,
					DestinationId = hero.ObjectId,
					FireFromTarget = true,
					DamageMultiplier = traitArgs.DamageMultiplier,
					ScaleMultiplier = scale,
					DataProperties = {
						StartFx = graphic,
						StartDelay = (i - 1) * mod.tuning.PoseidonSplash.WaveDelay,
					},
				})
			end

			game.ApplyForce({ Id = unit.ObjectId, Angle = angle, Speed = tuning.Knockback })
		end
	end)

	arterial_spray_end()
	if not ok then error(err) end
end


function mod.BreakerRushStart(weaponData, _args, _triggerArgs)
	if weaponData and weaponData.Name == 'WeaponSprint' then
		if game.CheckCooldown('BoonEditBreakerRushTrail', stutter_step_interval(mod.tuning.BreakerRush.TrailInterval)) then
			breaker_rush_splash()
		end
		return
	end

	if game.SessionMapState.BoonEditBreakerRushStarted then
		game.thread(function()
			game.wait(mod.tuning.BreakerRush.ChainDelay, game.RoomThreadName)
			breaker_rush_splash()
		end)
	end

	breaker_rush_splash()
	game.SessionMapState.BoonEditBreakerRushStarted = true
end

function mod.BreakerRushEnd(args, triggerArgs)
	if not game.SessionMapState.BoonEditBreakerRushStarted then return end
	fire_breaker_rush_wave(args, triggerArgs)
end
